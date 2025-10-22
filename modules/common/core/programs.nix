# programs.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  platform,
  system ? pkgs.system,
}:
let
  programsTable = {
    "linux-x86_64-linux" = {
      zsh.enable = true;
      tmux.enable = true;
      vim.enable = true;
    };
    "linux-aarch64-linux" = {
      zsh.enable = true;
      vim.enable = true;
    };
    "darwin-x86_64-darwin" = {
      zsh.enable = true;
      tmux.enable = true;
      vim.enable = true;
    };
    "darwin-aarch64-darwin" = {
      zsh.enable = true;
      tmux.enable = true;
    };
    "nvidia-aarch64-linux" = {
      zsh.enable = true;
    };
    "vm-x86_64-linux" = {
      zsh.enable = true;
      tmux.enable = true;
      vim.enable = false;
    };
  };
  key = "${platform}-${system}";
  commonPrograms = {
    zsh.enable = true;
  };
  selectedPrograms = if programsTable ? key then programsTable.${key} else commonPrograms;
in
selectedPrograms
