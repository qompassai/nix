# config.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ pkgs, lib, ... }:
{
  nixpkgs = {
    config = {
      allowAliases = true;
      allowBroken = false;
      allowUnfree = true;
      allowUnsupportedSystem = false;
      allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
        ];
      checkMeta = true;
      cudaSupport = true;
      enableParallelBuildingByDefault = true;
      hashedMirrors = [
        "https://tarballs.nixos.org"
      ];
      howDerivationWarnings = [ "maintainerless" ];
      permittedInsecurePackages = [ ];
      preferLocalBuild = true;
      restrictEvaluations = false;
      strictDepsByDefault = true;
      structuredAttrsByDefault = true;
      warnUndeclaredOptions = true;
    };
  };
  environment = {
    shellAliases = {
      "nix" = "nix --log-format bar-with-logs";
      "nix-build" = "nix-build --fast --log-format bar-with-logs";
      "nixos-rebuild" = "nixos-rebuild  --fast --log-format bar-with-logs";
      "nix-profile" = "nix profile install --log-format bar-with-logs";
      "nix-top" = "nix store --gc --optimise; nix-store --verify --check-contents";
      "nix-why" = "nix why-depends";
    };
    variables = {
      NIX_REMOTE = "daemon";
      NIX_USE_CCACHE = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      TMPDIR = "/dev/shm";
    };
  };
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  networking = {
    hostName = "primo";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      22
      2342
      5432
      6379
    ];
    firewall.enable = true;
  };
  programs = {
    bash.enable = true;
    dconf.enable = true;
    firefox.enable = true;
    fish.enable = true;
    fuse.userAllowOther = true;
    git.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mtr.enable = true;
    neovim.enable = true;
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
    nm-applet.indicator = true;
    seahorse.enable = false;
    steam = {
      dedicatedServer.openFirewall = true;
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
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
  };
  security = {
    apparmor.enable = true;
    audit.enable = true;
    polkit.enable = true;
    rtkit.enable = true;
    sudo.enable = true;
    sudo.wheelNeedsPassword = true;
  };
  services = {
    blueman.enable = true;
    dbus.enable = true;
    dbus.implementation = "broker";
    fstrim.enable = true;
    gvfs.enable = true;
    inputplumber.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      extraConfig.pipewire."context.properties" = {
        "default.clock.quantum" = 16;
        "default.clock.min-quantum" = 8;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-bluez-codecs" = {
            "monitor.bluez.properties" = {
              "bluez5.codecs" = [
                "aac"
                "aptx"
                "aptx_hd"
                "faststream"
                "ldac"
                "msbc"
                "sbc"
                "sbc_xq"
              ];
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [
                "a2dp_sink"
                "a2dp_source"
                "bap_sink"
                "bap_source"
                "hfp_ag"
                "hfp_hf"
                "hsp_hs"
                "hsp_ag"
              ];
            };
          };
        };
      };
    };
    openssh = {
      enable = true;
      ports = [
        22
        2342
      ];
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [ "phaedrus" ];
      };
    };
    pulseaudio.enable = false;
    tumbler.enable = true;
    xserver = {
      enable = false;
      xkb = {
        layout = "us";
        variant = "";
      };
      videoDrivers = [
        "nvidia"
        "modesetting"
        "intel"
      ];
    };
    libinput.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = false;
    xdgOpenUsePortal = true;
    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-shana
      pkgs.xdg-desktop-portal-termfilechooser
    ];
  };
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
    };
    stateVersion = "25.11";
  };
  time.timeZone = "America/Los_Angeles";
  users.users.phaedrus = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "libvirtd"
      "lp"
      "scanner"
      "render"
      "video"
      "wheel"
    ];
    group = "phaedrus";
  };
}
