# /qompassai/nix/modules/2/python.nix
# --------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.python;
  inherit (lib) mkEnableOption mkOption types mkIf optionals;
in {
  options.programming.python = {
    enable = mkEnableOption "Python development environment";
    versions = mkOption {
  type = types.listOf (types.enum [
    "3.8" "3.10" "3.11" "3.12" "3.13" "3.14" "3.14-gilfree"
    ]);
    default = [ "3.11" ];
    description = "List of Python versions to install";
    };
    withNeovim = mkEnableOption "Enable Neovim integration";
    withAI = mkEnableOption "Include popular AI/ML packages";
    withPoetry = mkEnableOption "Enable Poetry for project management";
  };

  config = mkIf cfg.enable (let
  pythonMap = {
    "3.8" = pkgs.python38;
    "3.10" = pkgs.python310;
    "3.11" = pkgs.python311;
    "3.12" = pkgs.python312;
    "3.13" = pkgs.python313;
    "3.14" = pkgs.python314;
    "3.14-gilfree" = pkgs.python314-freethreaded;
  };

    selectedVersions = map (v: pythonMap.${v}) cfg.versions;

    aiPackages = python:
      python.withPackages (ps: with ps; [
        numpy pandas scipy matplotlib scikit-learn
        jax jaxlib
        tensorflow
        torch torchvision torchaudio
        transformers
        sentence-transformers
        accelerate uv
      ]);

    devTools = [
      pkgs.poetry
      pkgs.pipx
      pkgs.python3Packages.virtualenv
      pkgs.python3Packages.debugpy
    ];

    lintersAndFormatters = with pkgs; [
      ruff
      black
      isort
      pyright
    ];

    neovimPythonWrapper = pkgs.wrapNeovim pkgs.neovim-nightly {
      configure = {
        packages.python = lintersAndFormatters;
        customRC = ''
          autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
        '';
      };
    };
  in {
    environment.systemPackages =
      (optionals cfg.withAI (map aiPackages selectedVersions))
      ++ (optionals cfg.withPoetry devTools)
      ++ lintersAndFormatters
      ++ optionals cfg.withNeovim [ neovimPythonWrapper ];

    programs.neovim = mkIf cfg.withNeovim {
      enable = true;
      package = neovimPythonWrapper;
      extraPackages = lintersAndFormatters;
    };

    environment.variables = {
      PYTHONBREAKPOINT = "ipdb.set_trace";
      PYTHONSTARTUP = "${config.xdg.configHome}/python/startup.py";
    };

    xdg.configFile."python/startup.py".text = ''
      try:
          import readline
      except ImportError:
          pass
      else:
          import rlcompleter
          readline.parse_and_bind("tab: complete")
      import atexit
      import os
      import sys
      print("🐍 Python shell initialized with Qompass AI profile")
    '';
  });
}
