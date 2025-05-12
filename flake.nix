# ~/.dotfiles/flake.nix
# ---------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_LIB_HOME = "$HOME/.local/lib";
    XDG_RUNTIME_DIR = "/run/user/1000";
    XDG_STATE_HOME = "$HOME/.local/state";
    
    ANGLE_HOME = "${XDG_LIB_HOME}/angle";
    BEMENU_BACKEND = "wayland";
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    CLUTTER_BACKEND = "wayland";
    EDITOR = "nvim";
    EGL_PLATFORM = "wayland";
    GBM_BACKEND = "nvidia-drm";
    GDK_BACKEND = "wayland,x11";
    GTK_USE_PORTAL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    MESA_GLSL_CACHE_DIR = "${XDG_CACHE_HOME}/mesa_shader_cache";
    MESA_GLSL_CACHE_MAX_SIZE = "32G";
    MESA_SHADER_CACHE_DIR = "${XDG_CACHE_HOME}/mesa_shader_cache_db";
    MESA_VK_WSI_DISPLAY = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    OCL_ICD_VENDORS = "${XDG_CONFIG_HOME}/OpenCL/vendors";
    OZONE_PLATFORM = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_STYLE_OVERRIDE = "hyprland-quick-style";
    RUSTICL_DEVICE_TYPE = "gpu";
    RUSTICL_ENABLE = "iris,llvmpipe";
    RUSTICL_FEATURES = "fp16,fp64";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    SDL_VIDEODRIVER = "wayland,x11";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
    VISUAL = "nvim";
    WLR_NO_HARDWARE_CURSORS = "0";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_CURRENT_SESSION = "Hyprland";
    XDG_DESKTOP_DIR = "$HOME/.Desktop";
    XDG_DOWNLOAD_DIR = "$HOME/.Downloads";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    __GL_ALLOW_FLIPPING = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
  
  # Optional: Set up better SSH agent management via systemd
  programs.ssh.startAgent = true;
  
  # Optional: For NVIDIA-specific settings
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
  };
}


{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    
    nixos-hyprland = {
      url = "github:qompassai/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nixos-hyprland, ... }@inputs: {
    nixosConfigurations = {
      primo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.phaedrus = import ./home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "phaedrus@primo" = home-manager.lib.homeManagerConfiguration {  # Use "username@hostname" format
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}

