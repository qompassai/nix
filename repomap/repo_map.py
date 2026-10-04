#!/usr/bin/env python3
"""repo-map prototype: compress a source tree into a ranked definition map.

Walks a repo, extracts structure from each file, then ranks Rust definitions
by QUALIFIED reference counting:

- method `m` in `impl T`: counts `T::m(..)`, `self.m(..)`, `Self::m(..)` at full
  weight; bare `m(..)` calls split across every definition sharing the name.
- free fn `f` in module `p`: counts `p::f(..)` at full weight; bare `f(..)` split.
- type `T`: counts `type_identifier` occurrences (type positions only -- a
  variable named `evidence` no longer votes for `mod evidence`).
- `mod m`: counts `m::` path-segment occurrences.

Non-Rust files get shallow structure extraction (headers, top-level bindings,
etc.) and appear in the table of contents. Every text file in the repo is
indexed -- not just .rs.

Emits the top of the ranking within a char budget, plus a file table of contents.

Usage: python3 repo_map.py /path/to/repo [--budget CHARS] [--out FILE]
"""

import argparse
import os
import re
import sys
from collections import Counter

import tree_sitter
import tree_sitter_rust

SKIP_DIRS = {
    ".git", "target", "node_modules", "__pycache__", ".hg", ".svn",
    ".venv", "venv", "dist", "build", ".next", ".nuxt", "vendor",
}
# Binary/non-text extensions to skip (not exhaustive; we also check for null bytes)
SKIP_EXTS = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".bmp", ".svg",
    ".pdf", ".zip", ".tar", ".gz", ".bz2", ".xz", ".7z",
    ".mp3", ".mp4", ".wav", ".ogg", ".webm",
    ".ttf", ".otf", ".woff", ".woff2", ".eot",
    ".exe", ".dll", ".so", ".dylib", ".a", ".o",
    ".pyc", ".pyo", ".class",
    ".db", ".sqlite", ".sqlite3",
}
RUST_EXT = ".rs"
SIG_TRUNC = 220
MAX_FILE_SIZE = 1024 * 1024  # 1MB -- skip larger files (probably generated)

_parser = tree_sitter.Parser(tree_sitter.Language(tree_sitter_rust.language()))
_TXT = lambda n: n.text.decode("utf-8", "replace")  # noqa: E731


def is_text_file(path):
    """Check if a file is text (not binary) by reading the first chunk."""
    try:
        with open(path, "rb") as fh:
            chunk = fh.read(8192)
            if b"\x00" in chunk:
                return False
            return True
    except (OSError, IOError):
        return False


def iter_all_files(root):
    """Walk all text files in the repo, skipping build dirs and binaries."""
    out = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for f in filenames:
            # Skip hidden files, lock files are OK (they're text)
            if f.startswith(".") and f not in (".env.example",):
                # Allow .gitignore, .repomap.txt etc but skip .DS_Store
                if f in (".DS_Store", ".gitkeep"):
                    continue
            ext = os.path.splitext(f)[1].lower()
            if ext in SKIP_EXTS:
                continue
            full = os.path.join(dirpath, f)
            try:
                if os.path.getsize(full) > MAX_FILE_SIZE:
                    continue
            except OSError:
                continue
            if is_text_file(full):
                out.append(full)
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


def extract_rust(path, src):
    """Full tree-sitter extraction for Rust files. Returns (defs, refs)."""
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
                        "lang": "rust",
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


def extract_markdown(text):
    """Extract headers from Markdown files."""
    defs = []
    for line in text.splitlines():
        m = re.match(r"^(#{1,6})\s+(.+)$", line.strip())
        if m:
            level = len(m.group(1))
            title = m.group(2).strip()
            # Strip markdown formatting
            title = re.sub(r"[*_`\[\]()#]", "", title).strip()
            if title:
                defs.append({
                    "name": title,
                    "kind": f"h{level}",
                    "pub": True,
                    "sig": f"{'#' * level} {title}",
                    "impl": None,
                    "lang": "markdown",
                })
    return defs


def extract_nix(text):
    """Extract top-level bindings from Nix files (shallow)."""
    defs = []
    # Match top-level `name =` or `name ?` patterns (not indented deeply)
    for i, line in enumerate(text.splitlines()[:200]):  # first 200 lines
        # Top-level attrs are usually at indent 0-2
        m = re.match(r"^(\s{0,4})([a-zA-Z_][a-zA-Z0-9_\-']*)\s*=\s*", line)
        if m:
            name = m.group(2)
            # Skip common noise
            if name not in ("inherit",):
                sig = line.strip()[:100]
                defs.append({
                    "name": name,
                    "kind": "attr",
                    "pub": True,
                    "sig": sig,
                    "impl": None,
                    "lang": "nix",
                })
        # Also catch function args: { pkgs, lib, ... }:
        if i < 5:
            m2 = re.match(r"^\s*\{\s*([^}]+)\s*\}", line)
            if m2 and ":" in text.splitlines()[i] if i < len(text.splitlines()) else False:
                pass  # Function args, skip for now
    return defs[:30]  # Cap at 30


def extract_python_lua(text, lang):
    """Extract def/class/function from Python/Lua via regex (shallow)."""
    defs = []
    if lang == "python":
        pattern = r"^(?:async\s+)?def\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\("
        class_pattern = r"^class\s+([a-zA-Z_][a-zA-Z0-9_]*)"
    else:  # lua
        pattern = r"^(?:local\s+)?function\s+([a-zA-Z_][a-zA-Z0-9_.:]*)"
        class_pattern = None
    
    for line in text.splitlines():
        stripped = line.strip()
        m = re.match(pattern, stripped)
        if m:
            name = m.group(1)
            defs.append({
                "name": name,
                "kind": "fn",
                "pub": not name.startswith("_"),
                "sig": stripped[:100],
                "impl": None,
                "lang": lang,
            })
        if class_pattern:
            m2 = re.match(class_pattern, stripped)
            if m2:
                defs.append({
                    "name": m2.group(1),
                    "kind": "class",
                    "pub": True,
                    "sig": stripped[:100],
                    "impl": None,
                    "lang": lang,
                })
    return defs[:50]


def extract_ruby_fastlane(text):
    """Extract lanes and key blocks from Fastlane/Ruby files."""
    defs = []
    for line in text.splitlines():
        stripped = line.strip()
        # Fastlane: lane :name do, platform :ios do
        m = re.match(r"(?:private_)?lane\s+:([a-zA-Z_][a-zA-Z0-9_]*)", stripped)
        if m:
            defs.append({
                "name": m.group(1),
                "kind": "lane",
                "pub": not stripped.startswith("private_"),
                "sig": stripped[:100],
                "impl": None,
                "lang": "ruby",
            })
        m2 = re.match(r"platform\s+:([a-zA-Z_][a-zA-Z0-9_]*)", stripped)
        if m2:
            defs.append({
                "name": m2.group(1),
                "kind": "platform",
                "pub": True,
                "sig": stripped[:100],
                "impl": None,
                "lang": "ruby",
            })
        # Ruby defs
        m3 = re.match(r"def\s+([a-zA-Z_][a-zA-Z0-9_?!]*)", stripped)
        if m3:
            defs.append({
                "name": m3.group(1),
                "kind": "fn",
                "pub": True,
                "sig": stripped[:100],
                "impl": None,
                "lang": "ruby",
            })
    return defs[:50]


def extract_generic(text, lang, rel):
    """Fallback: return file metadata as a single pseudo-definition."""
    lines = text.splitlines()
    non_empty = sum(1 for l in lines if l.strip())
    return [{
        "name": os.path.basename(rel),
        "kind": "file",
        "pub": True,
        "sig": f"{len(lines)} lines, {non_empty} non-empty",
        "impl": None,
        "lang": lang,
    }]


def extract(path, rel):
    """Dispatch extraction by file extension. Returns (defs, refs, lang)."""
    ext = os.path.splitext(path)[1].lower()
    basename = os.path.basename(path).lower()
    
    try:
        with open(path, "rb") as fh:
            src = fh.read()
        text = src.decode("utf-8", "replace")
    except (OSError, IOError):
        return [], {"call": Counter(), "type": Counter(), "path": Counter(), "ident": Counter()}, "unknown"

    empty_refs = {"call": Counter(), "type": Counter(), "path": Counter(), "ident": Counter()}

    # Rust: full tree-sitter extraction
    if ext == RUST_EXT:
        defs, refs = extract_rust(path, src)
        return defs, refs, "rust"
    
    # Markdown: headers
    if ext in (".md", ".markdown", ".mdown"):
        return extract_markdown(text), empty_refs, "markdown"
    
    # Nix
    if ext == ".nix":
        return extract_nix(text), empty_refs, "nix"
    
    # Python
    if ext in (".py", ".pyi"):
        return extract_python_lua(text, "python"), empty_refs, "python"
    
    # Lua
    if ext == ".lua":
        return extract_python_lua(text, "lua"), empty_refs, "lua"
    
    # Ruby / Fastlane
    if ext in (".rb", ".rake") or basename in ("fastfile", "appfile", "deliverfile", "gymfile", "matchfile", "scanfile", "snapfile"):
        return extract_ruby_fastlane(text), empty_refs, "ruby"
    
    # Starlark / BUILD (Buildifier)
    if basename in ("build", "workspace") or ext in (".bzl", ".bazel"):
        # BUILD files: extract rule names
        defs = []
        for line in text.splitlines():
            m = re.match(r'\s*name\s*=\s*["\']([^"\']+)["\']', line)
            if m:
                defs.append({
                    "name": m.group(1),
                    "kind": "target",
                    "pub": True,
                    "sig": line.strip()[:100],
                    "impl": None,
                    "lang": "starlark",
                })
        return defs[:30] if defs else extract_generic(text, "starlark", rel), empty_refs, "starlark"
    
    # TOML: top-level keys and table headers
    if ext == ".toml":
        defs = []
        for line in text.splitlines():
            stripped = line.strip()
            m = re.match(r"^\[([^\]]+)\]", stripped)
            if m:
                defs.append({
                    "name": m.group(1),
                    "kind": "table",
                    "pub": True,
                    "sig": stripped[:100],
                    "impl": None,
                    "lang": "toml",
                })
        return defs[:30] if defs else extract_generic(text, "toml", rel), empty_refs, "toml"
    
    # YAML: top-level keys
    if ext in (".yaml", ".yml"):
        defs = []
        for line in text.splitlines():
            m = re.match(r"^([a-zA-Z_][a-zA-Z0-9_\-]*)\s*:", line)
            if m:
                defs.append({
                    "name": m.group(1),
                    "kind": "key",
                    "pub": True,
                    "sig": line.strip()[:100],
                    "impl": None,
                    "lang": "yaml",
                })
        return defs[:30] if defs else extract_generic(text, "yaml", rel), empty_refs, "yaml"
    
    # JSON: top-level keys (if small enough)
    if ext == ".json" and len(text) < 50000:
        try:
            import json as js
            data = js.loads(text)
            if isinstance(data, dict):
                defs = [{
                    "name": k,
                    "kind": "key",
                    "pub": True,
                    "sig": f'"{k}": ...',
                    "impl": None,
                    "lang": "json",
                } for k in list(data.keys())[:30]]
                return defs, empty_refs, "json"
        except:
            pass
        return extract_generic(text, "json", rel), empty_refs, "json"
    
    # Shell scripts: function definitions
    if ext in (".sh", ".bash", ".zsh") or basename.startswith("run") or basename.endswith(".sh"):
        defs = []
        for line in text.splitlines():
            stripped = line.strip()
            m = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)", stripped)
            if m:
                defs.append({
                    "name": m.group(1),
                    "kind": "fn",
                    "pub": True,
                    "sig": stripped[:100],
                    "impl": None,
                    "lang": "shell",
                })
            m2 = re.match(r"^function\s+([a-zA-Z_][a-zA-Z0-9_]*)", stripped)
            if m2:
                defs.append({
                    "name": m2.group(1),
                    "kind": "fn",
                    "pub": True,
                    "sig": stripped[:100],
                    "impl": None,
                    "lang": "shell",
                })
        return defs[:30] if defs else extract_generic(text, "shell", rel), empty_refs, "shell"
    
    # Generic fallback: file metadata
    lang = ext[1:] if ext else "text"
    return extract_generic(text, lang, rel), empty_refs, lang


def main():
    ap = argparse.ArgumentParser(prog="repomap")
    ap.add_argument("root")
    ap.add_argument("--budget", type=int, default=12000)
    ap.add_argument("--out", default="-")
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    files = iter_all_files(root)
    per_file = {}
    for p in files:
        rel = os.path.relpath(p, root)
        defs, refs, lang = extract(p, rel)
        # Only Rust files get module path segments for ranking
        modpath = mod_segments(rel) if lang == "rust" else []
        per_file[rel] = (defs, refs, modpath, lang)

    # aggregate reference indexes (Rust only), excluding each definition's home file
    name_df = Counter()
    for rel, (defs, _, _, lang) in per_file.items():
        if lang == "rust":
            for d in defs:
                name_df[d["name"]] += 1

    def refs_outside(home_rel, kind, key):
        n = 0
        for rel, (_, refs, _, _) in per_file.items():
            if rel != home_rel:
                n += refs[kind].get(key, 0)
        return n

    ranked = []
    for rel, (defs, _, modpath, lang) in per_file.items():
        if lang != "rust":
            continue
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
                w = 0.1 if d["impl"] else 1.0
                score = w * refs_outside(rel, "type", name) / df
            elif kind == "mod":
                score = refs_outside(rel, "path", name) / df
            else:  # const, static
                score = refs_outside(rel, "ident", name) / df
            ranked.append((score, d["pub"], rel, d))

    ranked.sort(key=lambda r: (r[0], r[1]), reverse=True)

    # Count by language
    lang_counts = Counter()
    for _, (_, _, _, lang) in per_file.items():
        lang_counts[lang] += 1
    lang_summary = ", ".join(f"{l}:{c}" for l, c in sorted(lang_counts.items()))

    n_defs = sum(len(d) for d, _, _, _ in per_file.values())
    n_rust_defs = sum(len(d) for d, _, _, lang in per_file.values() if lang == "rust")
    lines = [
        f"# repo-map: {root}",
        f"# {len(files)} files, {n_defs} definitions ({n_rust_defs} rust), budget {args.budget} chars",
        f"# languages: {lang_summary}",
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

    # Non-Rust highlights: show top structure from each non-Rust file (budget permitting)
    lines += ["", "# non-rust structure:"]
    for rel in sorted(per_file):
        defs, _, _, lang = per_file[rel]
        if lang == "rust" or not defs:
            continue
        # Show up to 5 defs per file
        for d in defs[:5]:
            line = f"{rel}: [{d['lang']}] {d['kind']} {d['name']} :: {d['sig']}"
            if used + len(line) + 1 > args.budget:
                break
            lines.append(line)
            used += len(line) + 1
        else:
            continue
        break

    lines += ["", f"# table of contents: {len(files)} files"]
    for rel in sorted(per_file):
        defs, _, _, lang = per_file[rel]
        lines.append(f"#   {rel} [{lang}] ({len(defs)} defs)")

    out = "\n".join(lines) + "\n"
    if args.out == "-":
        sys.stdout.write(out)
    else:
        with open(args.out, "w") as fh:
            fh.write(out)
    sys.stderr.write(
        f"repo-map: {len(files)} files, {n_defs} defs, {len(emitted)} rust files in budget, "
        f"{len(out)} chars\n"
    )


if __name__ == "__main__":
    main()
