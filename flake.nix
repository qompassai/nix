{
  description = "Qompass AI NixOS configuration";
  inputs = {
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      ref = "master";
      type = "github";
      owner = "nix-community";
      repo = "disko";
    };
    dream2nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      ref = "main";
      repo = "dream2nix";
      owner = "nix-community";
      type = "github";
    };
    fenix = {
      type = "github";
      owner = "nix-community";
      repo = "fenix";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      ref = "main";
    };
    flake-schemas = {
      type = "github";
      owner = "DeterminateSystems";
      repo = "flake-schemas";
      ref = "main";
    };
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
    };
    hyprland = {
      type = "github";
      owner = "hyprwm";
      repo = "Hyprland";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      type = "github";
      owner = "hyprwm";
      repo = "hyprland-plugins";
      ref = "main";
      inputs.hyprland.follows = "hyprland";
    };
    impermanence = {
      type = "github";
      owner = "nix-community";
      repo = "impermanence";
      ref = "master";
    };
    kernel-overlay = {
      type = "github";
      owner = "andreoss";
      repo = "kernel-overlay";
      ref = "master";
    };
    lanzaboote = {
      type = "github";
      owner = "nix-community";
      repo = "lanzaboote";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      type = "git";
      url = "https://git.lix.systems/lix-project/lix";
    };
    lix-module = {
      type = "git";
      url = "https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    neovim = {
      type = "github";
      owner = "nix-community";
      repo = "neovim-nightly-overlay";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      type = "github";
      owner = "Mic92";
      repo = "nix-index-database";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      type = "github";
      owner = "nix-community";
      repo = "nixos-generators";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      type = "github";
      owner = "nixos";
      repo = "nixos-hardware";
    };
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";

    };
    nixvim = {
      inputs.nixpkgs.follows = "nixpkgs";
      owner = "nix-community";
      type = "github";
      repo = "nixvim";
      ref = "main";
    };
    nur = {
      type = "github";
      owner = "nix-community";
      repo = "nur";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    poetry2nix = {
      type = "github";
      owner = "nix-community";
      repo = "poetry2nix";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      type = "github";
      owner = "oxalica";
      repo = "rust-overlay";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ nixpkgs, self, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-android"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                (import ./overlays/default.nix { inherit inputs; })
              ];
            };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs, system, ... }:
        {
          default = import ./devshells.nix { inherit inputs pkgs system; };
          android = pkgs.mkShell {
            name = "android-dev";
            buildInputs = with pkgs; [
              jdk
              android-tools
              (pkgs.androidenv.composeAndroidPackages {
                cmdLineToolsVersion = "8.0";
                includeNDK = true;
                includePlatformTools = true;
                platformVersions = [
                  "33"
                  "35"
                ];
              }).androidsdk
            ];
            ANDROID_HOME = "${pkgs.androidenv.androidsdk}/libexec/android-sdk";
          };
        }
      );
      formatter = forAllSystems ({ pkgs, ... }: pkgs.callPackage ./treefmt.nix { });
      nixosConfigurations = {
        primo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit self inputs;
            username = "phaedrus";
          };
          modules = [ (import ./hosts/linux/x86_64) ];
        };
        armhost = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self inputs;
            username = "phaedrus";
          };
          modules = import ./modules/modules-list.nix { inherit inputs; } ++ [
            inputs.lix-module.nixosModules.default
          ];
        };
      };
    };
}
