# programs.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ inputs, pkgs, ... }:
{
  programs = {
    bash = {
      completion.enable = true;
      enable = true;
    };
    captive-browser = {
      bindInterface = true;
      enable = true;
      interface = "wlan0";
    };
    ccache.enable = true;
    dconf = {
      enable = true;
      profiles = {
        user = {
          databases = [
            {
              settings."org/gnome/desktop/interface" = {
                gtk-theme = "Adwaita";
                icon-theme = "Flat-Remix-Red-Dark";
                font-name = "Noto Sans Medium 11";
                document-font-name = "Noto Sans Medium 11";
                monospace-font-name = "Noto Sans Mono Medium 11";
              };
            }
          ];
        };
      };
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    firefox.enable = true;
    fish = {
      enable = true;
      generateCompletions = true;
      package = pkgs.fish;
      useBabelfish = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
    fuse.userAllowOther = true;
    fzf.fuzzyCompletion = true;
    git = {
      enable = true;
      lfs = {
        enable = true;
        enablePureSSHTransfer = true;
      };
      prompt.enable = true;
    };
    gnupg = {
      agent = {
        enable = true;
        enableBrowserSocket = true;
        enableExtraSocket = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-all;
      };
      dirmngr.enable = true;
    };
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
    java.enable = true;
    mtr.enable = true;
    neovim = {
      defaultEditor = true;
      enable = true;
      withPython3 = true;
      withRuby = true;
    };
    nh = {
      clean.enable = true;
      enable = true;
    };
    nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      package = pkgs.nix-index;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        clang
        cmake
        glibc
        libGL
        openssl
        zlib
      ];
    };
    nix-required-mounts = {
      enable = true;
      presets.nvidia-gpu.enable = true;
    };
    nm-applet.indicator = true;
    schroot = {
      enable = true;
    };
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };
    seahorse.enable = true;
    ssh = {
      startAgent = false;
    };
    steam = {
      dedicatedServer.openFirewall = true;
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo
        mousepad
        thunar-archive-plugin
        thunar-volman
        tumbler
      ];
    };
    virt-manager.enable = true;
    waybar.enable = true;
    xwayland.enable = true;
    zoxide = {
      enable = true;
    };
  };
}
