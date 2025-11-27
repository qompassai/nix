# environment.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ pkgs, ... }:
{
  environment = {
    etc = {
      "OpenCL/vendors/intel.icd" = {
        text = "${pkgs.intel-compute-runtime}/lib/libigdrcl.so";
      };
      "level-zero.conf" = {
        text = ''
          ${pkgs.level-zero}/lib/libze_loader.so.1
        '';
      };
    };
    shellAliases = {
      "nix" = "nix --log-format bar-with-logs";
      "nix-build" = "nix-build --fast --log-format bar-with-logs";
      "nixos-rebuild" = "nixos-rebuild  --fast --log-format bar-with-logs";
      "nix-profile" = "nix profile add --log-format bar-with-logs";
      "nix-top" = "nix store --gc --optimise; nix-store --verify --check-contents";
      "nix-why" = "nix why-depends";
    };
    sessionVariables = {
      GDK_BACKEND = "wayland,x11,*";
      NIXOS_OZONE_WL = "1";
    };
    variables = {
      NIX_REMOTE = "daemon";
      NIX_USE_CCACHE = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      TMPDIR = "/dev/shm";
    };
  };
}
