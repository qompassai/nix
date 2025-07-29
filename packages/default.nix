# default.nix
# Qompass AI Nix Defualt Packages
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  lib,
  newScope,
}:
lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    fake-secrets = callPackage ./fake-secrets.nix { };
    make-fake-secrets = callPackage ./make-fake-secrets { };
  }
)
