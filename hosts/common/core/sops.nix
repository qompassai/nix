# /qompassai/nix/hosts/common/core/sops.nix
# Qompass AI Nix Host Common SOPs 
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  sopsFolder = builtins.toString inputs.nix-secrets + "/sops";
in
{
  sops = {
    #    defaultSopsFile = "${secretsFile}";
    defaultSopsFile = "${sopsFolder}/${config.hostSpec.hostName}.yaml";
    validateSopsFiles = false;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
  sops.secrets = lib.mkMerge [
    {
      "keys/age" = {
        owner = config.users.users.${config.hostSpec.username}.name;
        inherit (config.users.users.${config.hostSpec.username}) group;
        path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
      };
      "passwords/${config.hostSpec.username}" = {
        sopsFile = "${sopsFolder}/shared.yaml";
        neededForUsers = true;
      };
      "passwords/msmtp" = {
        sopsFile = "${sopsFolder}/shared.yaml";
      };
    }
    (lib.mkIf config.services.backup.enable {
      "passwords/borg" = {
        owner = "root";
        group = if pkgs.stdenv.isLinux then "root" else "wheel";
        mode = "0600";
        path = "/etc/borg/passphrase";
      };
    })
  ];
  system.activationScripts.sopsSetAgeKeyOwnership =
    let
      ageFolder = "${config.hostSpec.home}/.config/sops/age";
      user = config.users.users.${config.hostSpec.username}.name;
      group = config.users.users.${config.hostSpec.username}.group;
    in
    ''
      mkdir -p ${ageFolder} || true
      chown -R ${user}:${group} ${config.hostSpec.home}/.config
    '';
}
