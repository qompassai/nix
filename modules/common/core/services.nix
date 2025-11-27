# services.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  platform,
  system ? pkgs.system,
}:
let
  servicesTable = {
    "linux-x86_64-linux" = {
      fwupd.enable = true;
      openssh.enable = true;
      timesyncd.enable = true;
    };
    "linux-aarch64-linux" = {
      openssh.enable = true;
      timesyncd.enable = true;
    };
    "darwin-x86_64-darwin" = {
      openssh.enable = true;
    };
    "nvidia-aarch64-linux" = {
      openssh.enable = true;
      jetsonFanControl.enable = true;
    };
    "vm-x86_64-linux" = {
      openssh.enable = true;
      qemuGuest.enable = true;
    };
  };
  key = "${platform}-${system}";

  commonServices = {
    openssh.enable = true;
  };
  selectedServices = if servicesTable ? key then servicesTable.${key} else commonServices;
in
selectedServices
