# networking.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  platform,
  system ? pkgs.system,
  deviceType ? null,
  location ? null,
}:
let
  baseNetworking = {
    firewall.enable = true;
    networkmanager.enable = true;
    hostName = "generic-host";
    interfaces = { };
    dhcpcd.enable = true;
  };

  networkingTable = {
    "linux-x86_64-linux" = {
      firewall.allowedTCPPorts = [ 22 80 443 ];
      firewall.allowedUDPPorts = [ 53 123 ];
      interfaces.eth0.ipv4.addresses = [
        { address = "192.168.1.10"; prefixLength = 24; }
      ];
      hostName = "x86-server";
    };
    "linux-aarch64-linux" = {
      firewall.allowedTCPPorts = [ 22 8888 ];
      interfaces.eth0.ipv4.addresses = [
        { address = "10.0.0.20"; prefixLength = 24; }
      ];
      hostName = "jetson";
    };
    "darwin-x86_64-darwin" = {
      networkmanager.enable = false;
      hostName = "mac-host";
    };
    "vm-x86_64-linux" = {
      firewall.allowedTCPPorts = [ 22 ];
      hostName = "vm-host";
      networkmanager.dhcp = true;
    };
  };
  key = "${platform}-${system}";
  uniqueNetworking = if networkingTable ? key then networkingTable.${key} else {};
  deviceNetworking =
    if deviceType == "laptop" then { firewall.enable = false; }
    else if deviceType == "server" then { firewall.enable = true; }
    else {};
  locationNetworking =
    if location == "office" then { interfaces.eth0.ipv4.addresses = [
      { address = "10.1.1.2"; prefixLength = 24; }
    ]; }
    else if location == "home" then { interfaces.eth0.ipv4.addresses = [
      { address = "192.168.0.22"; prefixLength = 24; }
    ]; }
    else {};
  mergedNetworking = baseNetworking // uniqueNetworking // deviceNetworking // locationNetworking;
in
{
  networking = mergedNetworking;
}

