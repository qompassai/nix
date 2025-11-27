# /qompassai/nix/hosts/linux/x86_64/programs.nix
# Qompass AI Linux X86_64 Programs Config
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ inputs, pkgs, ... }:
{
  programs = {
    bash = {
      completion = {
        enable = true;
        package = pkgs.bash-completion;
      };
      enable = true;
      enableLsColors = true;
      vteIntegration = true;
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
    fuse = {
      enable = true;
      userAllowOther = true;
    };
    fzf.fuzzyCompletion = true;
    git = {
      enable = true;
      lfs = {
        enable = true;
        enablePureSSHTransfer = true;
      };
      prompt.enable = true;
    };
    gdk-pixbuf = {
      modulePackages = [ pkgs.librsvg ];
    };
    gnupg = {
      agent = {
        enable = true;
        enableBrowserSocket = true;
        enableExtraSocket = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-all;
        settings = {
          allow-loopback-pinentry = true;
          allow-preset-passphrase = true;
          "debug-level" = "guru";
          "default-cache-ttl" = 86400;
          "default-cache-ttl-ssh" = 14400;
          disable-scdaemon = true;
          enable-extended-key-format = true;
          enable-ssh-support = true;
          ignore-cache-for-signing = true;
          "log-file" = "/home/phaedrus/.gnupg/gpg-agent.log";
          "max-cache-ttl" = 604800;
          no-allow-external-cache = true;
          no-allow-mark-trusted = true;
          "scdaemon-program" = "/dev/null";
          "ssh-fingerprint-digest" = "SHA256";
        };
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
    msmtp = {
      setSendmail = true;
    };
    mtr.enable = true;
    neovim = {
      defaultEditor = true;
      enable = true;
      withNodeJs = true;
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
    noisetorch = {
      enable = true;
      package = pkgs.noisetorch;
    };
    schroot = {
      enable = true;
    };
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
    looking-glass-obs
    obs-3d-effect
    obs-backgroundremoval
    obs-browser-transition
    obs-composite-blur
    obs-gstreamer
    input-overlay
    obs-markdown
    obs-media-controls
    obs-noise
    obs-pipewire-audio-capture
    obs-recursion-effect
    obs-rgb-levels
    obs-scale-to-sound
    obs-source-record
    obs-source-switcher
    obs-text-pthread
    obs-vkcapture
    obs-vaapi
    obs-vnc
    waveform
  ];
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
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
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
    ydotool.enable = true;
    zoom-us.enable = true;
    zoxide = {
      enable = true;
    };
  };
}
