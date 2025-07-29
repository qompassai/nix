# /qompassai/nix/modules/hosts/common/default.nix
# Qompass AI Default Host Common Module
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ lib, ... }:
{
  imports = lib.custom.scanPaths ./.;
}
