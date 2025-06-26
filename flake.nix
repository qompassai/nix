# /qompassai/nix/flake.nix
# ------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  description = "Qompass AI Nix";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    nixpkgs.url = "https://flakehub.com/qompassai/NixOS/nixpkgs/*";
  };
  outputs = {
    self,
    flake-schemas,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {inherit system;};
            inherit system;
          }
      );
  in {
    nixosModules = {
      languages = import ./modules/dev/lang.nix;
      hyprlandConfig = import ./modules/hyprland-config.nix;
    };

    inherit (flake-schemas) schemas;
    nixosConfigurations = {
      primo-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/boot/boot.nix
          ./hosts/default/config.nix
          ./modules/hardware/hardware.nix
          ./modules/hyprland-config.nix
        ];
        specialArgs = {inherit self nixpkgs;};
      };

      primo-arm64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/default/config.nix
          ./modules/boot/boot.nix
          ./modules/hardware/hardware.nix
          ./modules/hardware/nvidia.nix
          ./modules/hyprland-config.nix
        ];
        specialArgs = {inherit self nixpkgs;};
      };
    };
    devShells = forEachSupportedSystem ({
      pkgs,
      system,
    }: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          curl
          git
          jq
          wget
          nixpkgs-fmt
        ];
        shellHook = ''
          echo "Dev shell for ${system}"
        '';
      };
    });
  };
}
