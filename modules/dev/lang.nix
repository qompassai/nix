# /qompassai/nix/modules/2/lang.nix
# --------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{...}: {
  imports = [
    ./c.nix
    ./cpp.nix
    ./dotnet.nix
    ./git.nix
    ./go.nix
    ./haskell.nix
    ./js.nix
    ./jula.nix
    ./lua.nix
    ./markdown.nix
    ./ts.nix
    ./lua.nix
    ./mojo.nix
    ./ocamlnix
    ./perl.nix
    ./php.nix
    ./python.nix
    ./rust.nix
    ./scala.nix
    ./zig.nix
  ];
}
