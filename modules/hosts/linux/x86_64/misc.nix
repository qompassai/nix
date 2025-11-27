# fonts.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ pkgs, ... }:
{
  console = {
    font = "Lat2-Terminus16";
    packages = with pkgs; [ terminus_font ];
  };
  fonts = {
    fontconfig = {
      cache32Bit = true;
      enable = true;
      includeUserConf = true;
      allowBitmaps = false;
      allowType1 = true;
      useEmbeddedBitmaps = false;
      antialias = true;
      hinting = {
        autohint = true;
        enable = true;
        style = "full";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        serif = [
          "DaddyTimeMono Nerd Font"
          "Victor Mono"
        ];
        sansSerif = [
          "DaddyTimeMono Nerd Font"
          "Noto Sans"
        ];
        monospace = [
          "DaddyTimeMono Nerd Font"
          "Fira Code"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    fontDir = {
      enable = true;
    };
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      font-awesome
      material-symbols
      inter
      noto-fonts
      noto-fonts-cjk-sans
      terminus_font
      nerd-fonts.daddy-time-mono
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.terminess-ttf
      victor-mono
    ];
  };
  gtk = {
    iconCache.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "kvantum";
  };
}
