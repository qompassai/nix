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
      enable = true;
      includeUserConf = true;
      allowBitmaps = false;
      allowType1 = true;
      useEmbeddedBitmaps = false;
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
        autohint = true;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      cache32Bit = true;
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
}
