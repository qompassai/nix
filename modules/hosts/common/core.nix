# core.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.qnix;
in
{
  options.qnix = {
    enable = mkEnableOption "Qompass AI NixOS system configuration";
    user = mkOption {
      type = types.str;
      default = "user";
      description = "Primary user for the system";
      example = "john";
    };
    theme = mkOption {
      type = types.enum [
        "tokyo-night"
        "catppuccin"
        "gruvbox"
        "nord"
        "everforest"
        "rose-pine"
        "kanagawa"
      ];
      default = "tokyo-night";
      description = "System theme - changes colors, wallpaper, and overall look";
      example = "catppuccin";
    };
    darkMode = mkOption {
      type = types.bool;
      default = true;
      description = "Use dark theme variant when available";
    };
    displayManager = mkOption {
      type = types.enum [
        "gdm"
        "tuigreet"
      ];
      default = "tuigreet";
      description = "Display manager to use for login";
    };
    colorScheme = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "Color scheme from nix-colors. If null, uses theme-specific colors.";
      example = "inputs.nix-colors.colorSchemes.tokyo-night-dark";
    };
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to wallpaper for automatic color generation";
    };
    features = {
      coding = mkEnableOption "Development tools, editors, and programming languages";
      containers = mkEnableOption "Docker and container support";
      gaming = mkEnableOption "Gaming support with Steam, Wine, and performance tools";
      media = mkEnableOption "Video players, image viewers, and media editing tools";
      office = mkEnableOption "Office suite, PDF viewers, and productivity apps";
      communication = mkEnableOption "Chat apps, email clients, and video conferencing";
      virtualization = mkEnableOption "VM support (VirtualBox, QEMU, etc.)";
      backup = mkEnableOption "Backup tools and cloud sync applications";
      customThemes = mkEnableOption "Advanced theming with nix-colors integration";
      wallpaperEffects = mkEnableOption "Dynamic wallpapers and color generation";
    };
    preset = mkOption {
      type = types.nullOr (
        types.enum [
          "minimal"
          "developer"
          "creator"
          "gamer"
          "office"
          "everything"
        ]
      );
      default = null;
    };
  };

  config = mkIf cfg.enable {
    qnix.features = mkMerge [
      (mkIf (cfg.preset == "minimal") {
      })
      (mkIf (cfg.preset == "developer") {
        coding = mkDefault true;
        containers = mkDefault true;
        customThemes = mkDefault true;
      })
      (mkIf (cfg.preset == "creator") {
        media = mkDefault true;
        office = mkDefault true;
        customThemes = mkDefault true;
        wallpaperEffects = mkDefault true;
      })
      (mkIf (cfg.preset == "gamer") {
        gaming = mkDefault true;
        media = mkDefault true;
        communication = mkDefault true;
      })
      (mkIf (cfg.preset == "office") {
        office = mkDefault true;
        communication = mkDefault true;
        backup = mkDefault true;
      })
      (mkIf (cfg.preset == "everything") {
        coding = mkDefault true;
        containers = mkDefault true;
        gaming = mkDefault true;
        media = mkDefault true;
        office = mkDefault true;
        communication = mkDefault true;
        virtualization = mkDefault true;
        backup = mkDefault true;
        customThemes = mkDefault true;
        wallpaperEffects = mkDefault true;
      })
    ];
    system.autoUpgrade = {
      enable = true;
      flake = "/etc/nixos#qnix";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      dates = "weekly";
    };
    documentation = {
      enable = true;
      man.enable = true;
      dev.enable = cfg.features.coding or false;
    };
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        extraRules = [
          {
            groups = [ "wheel" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/nixos-rebuild";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
      polkit.enable = true;
    };
    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      fstrim.enable = true;
      thermald.enable = true;
      power-profiles-daemon.enable = true;
      upower.enable = true;
      blueman.enable = true;
      gvfs.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          userServices = true;
        };
      };
      smartd = {
        enable = true;
        autodetect = true;
      };
    };
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };
    virtualisation = mkIf (cfg.features.containers or false) {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
    programs = {
      git = mkIf (cfg.features.coding or false) {
        enable = true;
        lfs.enable = true;
      };
      npm = mkIf (cfg.features.coding or false) {
        enable = true;
      };
      steam = mkIf (cfg.features.gaming or false) {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
      TERM = "xterm-256color";
      CARGO_HOME = "$HOME/.cargo";
      GOPATH = "$HOME/.go";
      NPM_CONFIG_PREFIX = "$HOME/.npm";
      NIX_ROOT = "/etc/nixos";
    };
    programs.bash = {
      interactiveShellInit = ''
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.npm/bin:$PATH"
        alias ll='eza -la'
        alias ls='eza'
        alias cat='bat'
        alias grep='rg'
        alias find='fd'
        alias vim='nvim'
        alias vi='nvim'
        alias sns='sudo nixos-rebuild switch --flake /etc/nixos#qnix'
        alias sncg='sudo nix-collect-garbage -d'
        alias nsn='nix search nixpkgs'
        qnix-theme() {
          local theme=$1
          if [ -z "$theme" ]; then
            echo "Available themes: tokyo-night, catppuccin, catppuccin-latte, gruvbox, nord, everforest, rose-pine, kanagawa, matte-black, osaka-jade, ristretto"
            return 1
          fi
          echo "Switching to theme: $theme"
          sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$theme\"/" /etc/nixos/configuration.nix
          sns
        }
      '';

      promptInit = ''
        if command -v starship &> /dev/null; then
          eval "$(starship init bash)"
        fi
      '';
    };
    environment.systemPackages = with pkgs; [
      coreutils
      curl
      findutils
      gnugrep
      gnused
      gawk
      htop
      nano
      neofetch
      tree
      wget
      vim
      git
      gnumake
      gcc
      nix-prefetch-git
      nixpkgs-fmt
      nil
    ];
  };
}
