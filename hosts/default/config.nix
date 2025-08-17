# config.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
# ./default.nix
{ system ? builtins.currentSystem }:

let
  hosts = {
    "x86_64-linux" = import ./x86_64-linux;
    "aarch64-linux" = import ./aarch64-linux;
    "aarch64-jp"    = import ./aarch64-jp/device-pkgs/default.nix;
    "aarch64-droid" = import ./aarch64-droid/droid.nix;
  };
in
hosts.${system} or hosts."x86_64-linux"

