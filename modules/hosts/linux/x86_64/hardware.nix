# /etc/nixos/hosts/linux/x86_64/hardware.nix
# Qompass AI NixOS Linux x86_64 Hardware Config
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  lib,
  pkgs,
  ...
}:
{
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };
    cpu = {
      intel = {
        updateMicrocode = true;
      };
    };
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    firmwareCompression = "zstd";
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        ab-av1
        adaptivecppWithCuda
        dxvk_2
        envision
        furmark
        gpu-viewer
        gpufetch
        gpustat
        gputils
        # gtk2
        #gtk3
        #gtk3-x11
        gtk4
        gtkhash
        gtkmm2
        gtk-engine-murrine
        gtk_engines
        gtk-layer-shell
        gtk4-layer-shell
        guile-sdl2
        hdr10plus
        hdr10plus_tool
        hm
        idrisPackages.sdl2
        imagemagick
        intel-compute-runtime
        intel-gpu-tools
        intel-media-driver
        intel-ocl
        kompute
        khronos-ocl-icd-loader
        #libappindicator-gtk3
        libdbusmenu-gtk3
        libgbm
        libGLU
        libGLX
        librealsenseWithCuda
        libva
        libva-utils
        libvdpau-va-gl
        libvpl
        livekit
        lsfg-vk
        lsfg-vk-ui
        #memtest_vulkan # broken
        mesa
        mesa-demos
        mesa_glu
        mesa-gl-headers
        nvidia-vaapi-driver
        nv-codec-headers
        nv-codec-headers-12
        ocl-icd
        oneDNN
        opencl-caps-viewer
        opencl-clhpp
        opencl-headers
        opencomposite
        opencv
        openpgl
        openvino
        openxray
        openxr-loader
        osl
        realcugan-ncnn-vulkan
        SDL_compat
        SDL_gfx
        SDL_mixer
        SDL_Pango
        SDL_stretch
        SDL2
        sdl2-compat
        SDL2_image
        SDL2_mixer
        SDL2_net
        SDL2_sound
        SDL2_ttf
        sdl3
        sdl3-image
        sdl3-ttf
        spirv-cross
        spirv-headers
        spirv-llvm-translator
        spirv-tools
        sweet
        #swiftshader
        vdpauinfo
        vk-cli
        vk-bootstrap
        #vkBasalt
        vkbasalt-cli
        vkd3d
        vkd3d-proton
        vkdevicechooser
        vkdisplayinfo
        vkdt
        #vkdt-wayland
        vkmark
        vlc
        volk
        vpl-gpu-rt
        vtk
        vulkan-caps-viewer
        vulkan-cts
        vulkan-extension-layer
        vulkan-hdr-layer-kwin6
        vulkan-headers
        vulkan-loader
        vulkan-tools
        vulkan-tools-lunarg
        vulkan-utility-libraries
        vulkan-validation-layers
        vulkan-volk
        wayland-utils
        wivrn
        wgpu-native
        wgpu-utils
        wlx-overlay-s
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libva
        libvdpau-va-gl
        mesa
        mesa-demos
      ];
    };
    intel-gpu-tools.enable = true;
    ksm.enable = true;
    nvidia = {
      dynamicBoost.enable = true;
      # enabled = true;
      forceFullCompositionPipeline = true;
      modesetting.enable = true;
      nvidiaSettings = false;
      open = true;
      powerManagement.enable = false;
      prime = {
        allowExternalGpu = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        reverseSync.enable = true;
      };
      videoAcceleration = true;
    };
  };
  systemd = {
    services = {
      "getty@tty1".enable = true;
      "autovt@tty1".enable = true;
    };
    defaultUnit = lib.mkForce "multi-user.target";
  };
}
