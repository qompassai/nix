# systemd.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ ... }:
{
  systemd.services.postfix = {
    serviceConfig = {
      User = "postfix";
      Group = "postfix";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_CHOWN CAP_DAC_OVERRIDE";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelModules = true;
      RestrictSUIDSGID = true;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };
}
