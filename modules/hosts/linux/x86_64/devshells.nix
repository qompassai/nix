# /qompassai/nix/devshells.nix
# Qompass AI NixOS Devshell Config
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  inputs,
  system,
}:
{
  default = pkgs.mkShell {
    packages = with pkgs; [
      alejandra
      nil
    ];
    shellHook = ''
      export NIX_CFLAGS_COMPILE="-march=native -O3 -pipe"
      export NIX_CXXFLAGS_COMPILE="$NIX_CFLAGS_COMPILE"
      export NIX_LDFLAGS="-Wl,-O1"
      trap "pkill -f nix; pkill -f cc1plus; pkill -f gfortran; pkill -f cc1" EXIT
    '';
  };

  lua51 = pkgs.mkShell {
    packages = [
      pkgs.lua5_1
    ]
    ++ (with pkgs.lua51Packages; [
      luaposix
      luasocket
      luarocks
    ]);
  };

  luajit = pkgs.mkShell {
    packages = [
      pkgs.luajit
    ]
    ++ (with pkgs.luajitPackages; [
      luaposix
      luarocks
      luasocket
    ]);
  };
  python311 = pkgs.mkShell {
    packages = [
      pkgs.python311
    ]
    ++ (with pkgs.python311Packages; [
      pip
      pytest
      black
      ipython
    ]);
  };
  python312 = pkgs.mkShell {
    packages = [
      pkgs.python312
    ]
    ++ (with pkgs.python312Packages; [
      aiosteamist
      black
      bluetooth-adapters
      cupy
      pip
      pytest
      ipython
      xdg
      xdg-base-dirs
    ]);
  };
  ruby = pkgs.mkShell {
    packages = with pkgs; [ ruby ];
  };
  rust = pkgs.mkShell {
    packages = with pkgs; [
      rustc
      cargo
    ];
  };
  zig = pkgs.mkShell {
    packages = with pkgs; [ zig ];
  };
}
