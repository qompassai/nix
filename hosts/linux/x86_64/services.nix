# /qompassai/nix/hosts/linux/x86_64/services.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  lib,
  pkgs,
  ...
}:
{
  services = {
    blueman.enable = true;
    dbus = {
      enable = true;
      implementation = "broker";
    };
    fstrim.enable = true;
    fwupd.enable = true;
    gvfs.enable = true;
    inputplumber.enable = true;
    libinput.enable = true;
    passSecretService.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 16;
          "default.clock.min-quantum" = 8;
          "default.clock.max-quantum" = 8192;
        };
      };
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
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
    postfix = {
      enable = true;
      setSendmail = true;
      user = "postfix";
      group = "postfix";
      setgidGroup = "postdrop";
      package = pkgs.postfix;
      #settings = {
      #myhostname = "mail.example.org";
      #mydomain = "example.org";
      #myorigin = "$mydomain";
      #inet_interfaces = "loopback-only";
      #smtpd_banner = "$myhostname ESMTP";
      #home_mailbox = "Maildir/";
      # };
    };
    power-profiles-daemon.enable = false;
    pulseaudio.enable = false;
    seatd.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        USB_AUTOSUSPEND = 0;
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };
    tumbler.enable = true;
    udev = {
      enable = true;
      extraRules = ''
        SUBSYSTEM=="usb", ATTR{power/control}="on"
        SUBSYSTEM=="usb", ATTR{power/autosuspend}="-1"
        KERNEL=="nvidia*", GROUP="video", MODE="0664"
        KERNEL=="card*", GROUP="video", MODE="0664"
        KERNEL=="renderD*", GROUP="render", MODE="0664"
        SUBSYSTEM=="drm", KERNEL=="card*", ATTRS{vendor}=="0x8086", GROUP="video", MODE="0664"
        SUBSYSTEM=="drm", KERNEL=="renderD*", ATTRS{vendor}=="0x8086", GROUP="render", MODE="0664"
        SUBSYSTEM=="drm", KERNEL=="renderD*", ATTRS{vendor}=="0x8086", TAG+="uaccess"
      '';
    };
    xserver = {
      enable = false;
      xkb.layout = "us";
      xkb.variant = "";
      videoDrivers = [
        "nvidia"
        "modesetting"
        "intel"
      ];
      windowManager = {
        hypr.enable = true;
      };
    };
  };
  xdg = {
    autostart.enable = true;
    icons.enable = true;
    menus.enable = true;
    mime.enable = true;
    sounds.enable = true;
    terminal-exec.enable = true;
    portal = {
      enable = true;
      wlr.enable = lib.mkForce false;
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
      configPackages = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal
      ];
    };
  };
}
