# /qompassai/nix/flake.nix
# ------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  description = "Qompass AI Nix";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    nixpkgs.url = "https://flakehub.com/qompassai/NixOS/nixpkgs/*";
  };

  outputs = { self, flake-schemas, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      nixosModules = {
        languages = import ./modules/2/lang.nix;
      };

      schemas = flake-schemas.schemas;

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            curl
            git
            jq
            wget
            nixpkgs-fmt
          ];
        };
      });
    };
}

