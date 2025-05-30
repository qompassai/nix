# /qompassai/nix/modules/2/mojo.nix
# --------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.mojo;
  inherit (lib) mkEnableOption mkOption types;
in {
  options.programming.mojo = {
    enable = mkEnableOption "Mojo development environment";
    projectRoot = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/dev/my_mojo_project";
    };
    withModo = mkEnableOption "Modo documentation generator";
  };

  config = lib.mkIf cfg.enable (let
    modoPkg = pkgs.buildGoModule rec {
      pname = "modo";
      version = "0.11.4";
      src = pkgs.fetchFromGitHub {
        owner = "modularml";
        repo = "modo";
        rev = "v${version}";
        hash = "sha256-0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5";
      };
      vendorHash = "sha256-0000000000000000000000000000000000000000000000000000";
    };

    mojoConfig = {
      MOJO_HOME = "${config.home.homeDirectory}/.modular";
      MOJO_BIN = "\${MOJO_HOME}/bin";
      MOJO_PROJECT_ROOT = cfg.projectRoot;
      MOJO_TOML = "\${MOJO_PROJECT_ROOT}/mojo.toml";
      MOJO_PROJECT_TOML = "\${MOJO_PROJECT_ROOT}/mojoproject.toml";
      PIXI_TOML = "\${MOJO_PROJECT_ROOT}/pixi.toml";
      MOJO_CACHE_DIR = "${config.xdg.cacheHome}/mojo";
      MOJO_RATTLER_CACHE_DIR = "${config.xdg.cacheHome}/mojo/rattler";
      MOJO_BUILD_THREADS = toString (pkgs.runtimeShell "nproc");
      MODO_THEME = "default";
      MODO_OUTPUT_DIR = "\${MOJO_PROJECT_ROOT}/docs";
      RATTLER_BUILD_BIN = "${pkgs.rattler-build}/bin/rattler-build";
    };
  in {
    environment.systemPackages = with pkgs; [
      modular
      pixi
      miniconda3
    ] ++ lib.optionals cfg.withModo [ modoPkg ];

    environment.variables = mojoConfig // {
      PATH = [
        "\${MOJO_BIN}"
        "${config.home.homeDirectory}/.pixi/bin"
        "${config.home.homeDirectory}/.modular/pkg/magic/bin"
        "${config.home.homeDirectory}/.modular/bin"
      ];
      LD_LIBRARY_PATH = [
        "${config.home.homeDirectory}/.local/lib/arch-mojo"
      ];
    };

    programs.bash.shellInit = ''
      eval "$(${pkgs.magic}/bin/magic completion --shell bash)"
    '';

    home.file.".modular/mojo_lsp.json".text = builtins.toJSON {
      mojo_path = "${pkgs.mojo}/bin";
      include_dirs = [ "/usr/include" ];
    };
  });
}

