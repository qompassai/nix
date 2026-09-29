#!/usr/bin/env python3
"""repo-map prototype: compress a source tree into a ranked definition map.

Walks a repo, parses each file with tree-sitter, extracts definitions
(structs, enums, traits, fns, impls, type aliases, consts), then ranks them by
QUALIFIED reference counting:

- method `m` in `impl T`: counts `T::m(..)`, `self.m(..)`, `Self::m(..)` at full
  weight; bare `m(..)` calls split across every definition sharing the name.
- free fn `f` in module `p`: counts `p::f(..)` at full weight; bare `f(..)` split.
- type `T`: counts `type_identifier` occurrences (type positions only -- a
  variable named `evidence` no longer votes for `mod evidence`).
- `mod m`: counts `m::` path-segment occurrences.

This is what kills the common-word distortion of naive bare-name counting.
Emits the top of the ranking within a char budget, plus a file table of contents.

Usage: python3 repo_map.py /path/to/repo [--budget CHARS] [--out FILE]

Prototype scope: Rust only. Other languages = other tree-sitter grammars.
"""

import argparse
import os
import sys
from collections import Counter

import tree_sitter
import tree_sitter_rust

SKIP_DIRS = {".git", "target", "node_modules", "__pycache__", ".hg", ".svn"}
RUST_EXT = ".rs"
SIG_TRUNC = 220

_parser = tree_sitter.Parser(tree_sitter.Language(tree_sitter_rust.language()))
_TXT = lambda n: n.text.decode("utf-8", "replace")  # noqa: E731


def iter_rs_files(root):
    out = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for f in filenames:
            if f.endswith(RUST_EXT):
                out.append(os.path.join(dirpath, f))
    return sorted(out)


def is_pub(node):
    return any(c.type == "visibility_modifier" for c in node.children)


def def_name(node):
    for c in node.children:
        if c.type in ("identifier", "type_identifier"):
            return _TXT(c)
    return None


def impl_target(node):
    """The type an impl_item implements: last type-ish direct child."""
    cands = []
    for c in node.children:
        if c.type in ("type_identifier", "generic_type", "scoped_type_identifier"):
            cands.append(c)
    if not cands:
        return None
    last = cands[-1]
    if last.type == "generic_type":
        n = last.child_by_field_name("name")
        return _TXT(n) if n is not None else None
    if last.type == "scoped_type_identifier":
        n = last.child_by_field_name("name")
        return _TXT(n) if n is not None else _TXT(last)
    return _TXT(last)


def signature(node, src):
    end = node.end_byte
    for c in node.children:
        if c.type == "block":
            end = c.start_byte
            break
    sig = " ".join(src[node.start_byte : end].decode("utf-8", "replace").split())
    return sig if len(sig) <= SIG_TRUNC else sig[: SIG_TRUNC - 1] + "…"


def mod_segments(rel):
    """Rough module path for a file, e.g. crates/foo/src/bar/baz.rs -> [foo, bar, baz]."""
    parts = rel.split(os.sep)
    if "src" in parts:
        i = parts.index("src")
        crate = parts[i - 1]
        segs = [p[:-3] for p in parts[i + 1 :] if p.endswith(".rs")]
        segs = [s for s in segs if s not in ("lib", "main", "mod")]
        return [crate] + segs
    return [os.path.splitext(parts[-1])[0]]


def extract(path):
    """Return (definitions, refs) for one file.

    refs = {"call": Counter((name, qualifier|None)),
            "type": Counter(name), "path": Counter(segment),
            "ident": Counter(name)}
    """
    with open(path, "rb") as fh:
        src = fh.read()
    try:
        tree = _parser.parse(src)
    except Exception:
        return [], {"call": Counter(), "type": Counter(), "path": Counter(), "ident": Counter()}

    defs = []
    calls, type_refs, path_refs, ident_refs = Counter(), Counter(), Counter(), Counter()

    def visit_def(node, in_impl=None):
        t = node.type
        if t in (
            "function_item",
            "struct_item",
            "enum_item",
            "trait_item",
            "type_item",
            "const_item",
            "static_item",
            "mod_item",
        ):
            name = def_name(node)
            if name:
                defs.append(
                    {
                        "name": name,
                        "kind": "fn" if t == "function_item" else t.replace("_item", ""),
                        "pub": is_pub(node),
                        "sig": signature(node, src),
                        "impl": in_impl,
                    }
                )
        if t == "impl_item":
            target = impl_target(node)
            for c in node.children:
                visit_def(c, in_impl=target)
            return
        for c in node.children:
            visit_def(c, in_impl=in_impl)

    def visit_ref(node):
        t = node.type
        if t == "call_expression":
            callee = node.child_by_field_name("function")
            if callee is not None:
                if callee.type == "identifier":
                    calls[(_TXT(callee), None)] += 1
                elif callee.type == "scoped_identifier":
                    nm = callee.child_by_field_name("name")
                    ph = callee.child_by_field_name("path")
                    if nm is not None:
                        calls[(_TXT(nm), _TXT(ph) if ph is not None else None)] += 1
                elif callee.type == "field_expression":
                    f = callee.child_by_field_name("field")
                    v = callee.child_by_field_name("value")
                    if f is not None and v is not None:
                        vt = _TXT(v)
                        # only single-identifier receivers carry a usable qualifier
                        q = vt if v.type == "identifier" else None
                        calls[(_TXT(f), q)] += 1
        elif t == "type_identifier":
            type_refs[_TXT(node)] += 1
        elif t in ("scoped_identifier", "scoped_type_identifier"):
            ph = node.child_by_field_name("path")
            if ph is not None:
                for seg in _TXT(ph).split("::"):
                    path_refs[seg] += 1
        elif t == "identifier":
            ident_refs[_TXT(node)] += 1
        for c in node.children:
            visit_ref(c)

    visit_def(tree.root_node)
    visit_ref(tree.root_node)
    return defs, {"call": calls, "type": type_refs, "path": path_refs, "ident": ident_refs}


def main():
    ap = argparse.ArgumentParser(prog="repomap")
    ap.add_argument("root")
    ap.add_argument("--budget", type=int, default=12000)
    ap.add_argument("--out", default="-")
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    files = iter_rs_files(root)
    per_file = {}
    for p in files:
        rel = os.path.relpath(p, root)
        defs, refs = extract(p)
        per_file[rel] = (defs, refs, mod_segments(rel))

    # aggregate reference indexes, excluding each definition's home file
    name_df = Counter()
    for rel, (defs, _, _) in per_file.items():
        for d in defs:
            name_df[d["name"]] += 1

    def refs_outside(home_rel, kind, key):
        n = 0
        for rel, (_, refs, _) in per_file.items():
            if rel != home_rel:
                n += refs[kind].get(key, 0)
        return n

    ranked = []
    for rel, (defs, _, modpath) in per_file.items():
        for d in defs:
            name, kind = d["name"], d["kind"]
            df = name_df[name]
            if kind == "fn" and d["impl"]:
                t = d["impl"]
                q = (
                    refs_outside(rel, "call", (name, t))
                    + refs_outside(rel, "call", (name, "self"))
                    + refs_outside(rel, "call", (name, "Self"))
                )
                bare = refs_outside(rel, "call", (name, None))
                score = (q + bare) / df
            elif kind == "fn":
                last_seg = modpath[-1] if modpath else None
                q = refs_outside(rel, "call", (name, last_seg)) if last_seg else 0
                bare = refs_outside(rel, "call", (name, None))
                score = (q + bare) / df
            elif kind in ("struct", "enum", "trait"):
                score = refs_outside(rel, "type", name) / df
            elif kind == "type":
                # Associated `type X = …` inside an impl block is an
                # implementation detail of that impl, not an architectural
                # seam: downweight it hard.
                w = 0.1 if d["impl"] else 1.0
                score = w * refs_outside(rel, "type", name) / df
            elif kind == "mod":
                score = refs_outside(rel, "path", name) / df
            else:  # const, static
                score = refs_outside(rel, "ident", name) / df
            ranked.append((score, d["pub"], rel, d))

    ranked.sort(key=lambda r: (r[0], r[1]), reverse=True)

    n_defs = sum(len(d) for d, _, _ in per_file.values())
    lines = [
        f"# repo-map: {root}",
        f"# {len(files)} files, {n_defs} definitions, budget {args.budget} chars",
        "",
    ]
    used = sum(len(l) + 1 for l in lines)
    emitted = set()
    for score, pub, rel, d in ranked:
        if score <= 0 and emitted:
            break
        pub_s = "pub " if pub else ""
        impl_s = f" [impl {d['impl']}]" if d["impl"] else ""
        line = f"{rel}: {pub_s}{d['kind']} {d['name']}{impl_s} :: {d['sig']}  (score={score:.1f})"
        if used + len(line) + 1 > args.budget and emitted:
            break
        lines.append(line)
        used += len(line) + 1
        emitted.add(rel)

    lines += ["", f"# table of contents: {len(files)} files"]
    for rel in sorted(per_file):
        lines.append(f"#   {rel} ({len(per_file[rel][0])} defs)")

    out = "\n".join(lines) + "\n"
    if args.out == "-":
        sys.stdout.write(out)
    else:
        with open(args.out, "w") as fh:
            fh.write(out)
    sys.stderr.write(
        f"repo-map: {len(files)} files, {n_defs} defs, {len(emitted)} files in budget, "
        f"{len(out)} chars\n"
    )


if __name__ == "__main__":
    main()
