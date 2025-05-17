# ~/.dotfiles/modules/0/nvidia-drivers.nix
# --------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.drivers.nvidia;
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    
  hardware.graphics = {
  	enable = true;
  	enable32Bit = true;
	  extraPackages = with pkgs; [
	    vaapiVdpau
  	  libvdpau
  	  libvdpau-va-gl 
  	  nvidia-vaapi-driver
  	  vdpauinfo
	    libva
 		  libva-utils	
    	];
  	};

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = true;
    dynamicBoost.enable = true;
    nvidiaPersistenced = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
}
