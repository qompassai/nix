# default.nix
# Qompass AI Host Common Core Default Core Services
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  lib,
  ...
}:
{
  imports = (lib.custom.scanPaths ./.);
}
