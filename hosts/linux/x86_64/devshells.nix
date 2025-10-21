# devshells.nix
# Qompass AI NixOS Devshell Config
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  inputs,
  system,
  ...
}:
{
  default = pkgs.mkShell {
    packages = with pkgs; [
      alejandra
      nil
    ];
    buildInputs = [ pkgs ];
    shellHook = ''
      export NIX_CFLAGS_COMPILE="-march=native -O3 -pipe"
      export NIX_CXXFLAGS_COMPILE="$NIX_CFLAGS_COMPILE"
      export NIX_LDFLAGS="-Wl,-O1"
    '';
  };
  dotnet8 = pkgs.mkShell {
    packages = with pkgs; [ dotnet-sdk_8 ];
  };
  dotnet7 = pkgs.mkShell {
    packages = with pkgs; [ dotnet-sdk_7 ];
  };
  dotnet6 = pkgs.mkShell {
    packages = with pkgs; [ dotnet-sdk_6 ];
  };
  lua51 = pkgs.mkShell {
    packages = with pkgs.lua51Packages; [
      lua51
      luaposix
      luasocket
      luarocks
      magick
    ];
  };
  luajit = pkgs.mkShell {
    packages = with pkgs.luajitPackages; [
      luajit
      luaposix
      luarocks
      luasocket
      magick
    ];
  };
  python39 = pkgs.mkShell {
    packages = with pkgs.python39Packages; [
      black
      ipython
      python
      pip
      ruff
      uv
    ];
  };
  python311 = pkgs.mkShell {
    packages = with pkgs.python311Packages; [
      black
      ipython
      python
      pip
      ruff
      uv
    ];
  };
  python312 = pkgs.mkShell {
    packages = with pkgs.python312Packages; [
      black
      bluetooth-adapters
      cupy
      python
      pip
      ipython
      xdg
      xdg-base-dirs
    ];
  };
  ruby = pkgs.mkShell { packages = with pkgs; [ ruby ]; };
  mojo = pkgs.mkShell { packages = with inputs.rules-mojo.packages.${system}; [ mojo ]; };
  rust = pkgs.mkShell {
    packages = with pkgs; [
      rustc
      cargo
    ];
  };
  zig = pkgs.mkShell {
    packages = with pkgs; [
      zig
      zls
    ];
  };
  zig014 = pkgs.mkShell {
    packages = with pkgs; [
      zig_0_11
      zls
    ];
  };
  zig015 = pkgs.mkShell {
    packages = with pkgs; [
      zig_0_10
      zls
    ];
  };
}
