# declarative-jobsets.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ nixpkgs, pulls, ... }:
let
  pkgs = import nixpkgs { };
  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets = pkgs.lib.mapAttrs (num: info: {
    enabled = 1;
    hidden = false;
    description = "PR ${num}: ${info.title}";
    checkinterval = 300;
    schedulingshares = 20;
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    type = 1;
    flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/merge-requests/${info.iid}/head";
  }) prs;
  mkFlakeJobset = branch: {
    description = "Build ${branch} branch of Simple NixOS MailServer";
    checkinterval = 300;
    enabled = "1";
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
    hidden = false;
    type = 1;
    flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/${branch}";
  };
  desc = prJobsets // {
    "master" = mkFlakeJobset "master";
    "nixos-24.11" = mkFlakeJobset "nixos-24.11";
    "nixos-25.05" = mkFlakeJobset "nixos-25.05";
  };
  log = {
    pulls = prs;
    jobsets = desc;
  };
in
{
  jobsets = pkgs.runCommand "spec-jobsets.json" { } ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
    # This is to get nice .jobsets build logs on Hydra
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}
