# /qompassai/nix/nixos-installer/flake.nix
# Qompass AI NixOS Minimal Installer
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  description = "Qompass AI Minimal NixOS Installer";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      minimalSpecialArgs = {
        inherit inputs outputs;
        lib = nixpkgs.lib.extend (self: super: { custom = import ../lib { inherit (nixpkgs) lib; }; });
      };
      newConfig =
        name: disk: swapSize: useLuks: useImpermanence:
        (
          let
            diskSpecPath =
              if useLuks && useImpermanence then
                ../hosts/common/disks/btrfs-luks-impermanence-disk.nix
              else if !useLuks && useImpermanence then
                ../hosts/common/disks/btrfs-impermanence-disk.nix
              else
                ../hosts/common/disks/btrfs-disk.nix;
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = minimalSpecialArgs;
            modules = [
              inputs.disko.nixosModules.disko
              diskSpecPath
              {
                _module.args = {
                  inherit disk;
                  withSwap = swapSize > 0;
                  swapSize = builtins.toString swapSize;
                };
              }
              ./minimal-configuration.nix
              ../hosts/nixos/${name}/hardware-configuration.nix

              { networking.hostName = name; }
            ];
          }
        );
    in
    {
      nixosConfigurations = {
        # host = newConfig "name" disk" "swapSize" "useLuks" "useImpermanence"
        genoa = newConfig "genoa" "/dev/nvme0n1" 16 true true;
        grief = newConfig "grief" "/dev/vda" 0 false false;
        guppy = newConfig "guppy" "/dev/vda" 0 false false;
        gusto = newConfig "gusto" "/dev/nvme0n1" 8 false false;
        ghost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = minimalSpecialArgs;
          modules = [
            inputs.disko.nixosModules.disko
            ../hosts/common/disks/ghost.nix
            ./minimal-configuration.nix
            { networking.hostName = "ghost"; }
            ../hosts/nixos/ghost/hardware-configuration.nix
          ];
        };
      };
    };
}
