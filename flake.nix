{
  description = "Qompass AI Nix Flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    qjp.url = "github:QompassAI/QJP";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas?ref=main";
    nix-on-droid.url = "github:nix-community/nix-on-droid";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , nixpkgs-unstable
    , qjp
    , flake-schemas
    , nix-on-droid
    , ...
    }:
    let
      flakePartsOutputs = flake-parts.lib.mkFlake { inherit inputs; } (
        let
          nixosModules = {
            boot = import ./modules/boot/boot.nix;
            hardware = import ./modules/hardware/hardware.nix;
            hyprlandConfig = import ./modules/hyprland-config.nix;
            nvidia = import ./modules/hardware/nvidia.nix;
            languages = import ./modules/dev/lang.nix;
          };
          hardwareConfigs = {
            orin-agx-devkit = {
              som = "orin-agx";
              carrierBoard = "devkit";
            };
            orin-nx-devkit = {
              som = "orin-nx";
              carrierBoard = "devkit";
            };
            orin-nano-devkit = {
              som = "orin-nano";
              carrierBoard = "devkit";
            };
            orin-nx-devkit-super = {
              som = "orin-nx";
              carrierBoard = "devkit";
              super = true;
            };
            orin-nano-devkit-super = {
              som = "orin-nano";
              carrierBoard = "devkit";
              super = true;
            };
          };
          mkJetsonConfig = { name, som, carrierBoard, super ? false }:
            nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [
                ./modules/common.nix
                qjp.nixosModules.default
                {
                  hardware.nvidia-jetpack.enable = true;
                  hardware.nvidia-jetpack.som = som;
                  hardware.nvidia-jetpack.carrierBoard = carrierBoard;
                  hardware.nvidia-jetpack.super = super;
                  networking.hostName = name;
                }
              ];
              specialArgs = { nixpkgs = nixpkgs; };
            };
          jetsonConfigs =
            nixpkgs.lib.mapAttrs (n: cfg: mkJetsonConfig ({ name = n; } // cfg))
              hardwareConfigs;
        in
        {
          systems = [ "x86_64-linux" "aarch64-linux" ];
          perSystem = { system, pkgs, ... }:
            let
              unstable = import nixpkgs-unstable { inherit system; };
              mkBasePackages = with pkgs; [
                blender
                btop
                cava
                chezmoi
                cmake
                conda
                curl
                direnv
                docker
                dunst
                easyeffects
                firejail
                fish
                fuzzel
                fzf
                gpg
                gh
                git
                jq
                khal
                libreoffice
                lua
                maven
                mypaint
                neomutt
                neovim
                nix
                nixpkgs-fmt
                nodejs
                nvfetcher
                nvimpager
                pgadmin4
                pip
                pipewire
                pnpm
                postgresql
                python3
                python3Packages.pytest
                qt5ct
                qt6ct
                R
                rage
                sass
                sops
                sqlite
                steam
                tor-browser-bundle-bin
                unbound
                waybar
                wget
                wireguard-tools
                wofi
                zig
                zls
                unstable.nil
              ];
            in
            {
              devShells.default = pkgs.mkShell {
                packages = mkBasePackages;
                shellHook = ''
                  export NIX_CFLAGS_COMPILE="-march=native"
                  echo "✅ Qompass AI DevShell Loaded for ${system}"
                '';
              };
              packages.default = pkgs.buildEnv {
                name = "qompassai-env";
                paths = mkBasePackages;
              };
            };
          nixosConfigurations = jetsonConfigs // {
            x86_64-linux = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                nixosModules.boot
                ./hosts/x86_64-linux/config.nix # <-- FIXED PATH HERE
                nixosModules.hardware
                nixosModules.hyprlandConfig
              ];
              specialArgs = { nixpkgs = nixpkgs; };
            };
            aarch64-linux = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [
                ./hosts/aarch64-linux/config.nix # <-- FIXED PATH HERE
                nixosModules.boot
                nixosModules.hardware
                nixosModules.nvidia
                nixosModules.hyprlandConfig
              ];
              specialArgs = { nixpkgs = nixpkgs; };
            };
          };
          flake = { inherit (flake-schemas) schemas; };
        }
      );
    in
    flakePartsOutputs // {
      nix-on-droid = {
        configurations = {
          default = {
            modules = [ ./nix-on-droid.nix ];
            specialArgs = {
              nixpkgs = nixpkgs;
              androidPackages = with nixpkgs.legacyPackages.aarch64-linux; [
                btop
                curl
                git
                jq
                neomutt
                nixpkgs-fmt
                python3
                sops
                wget
                wireguard-tools
                zls
              ];
            };
          };
        };
      };
    };
}


