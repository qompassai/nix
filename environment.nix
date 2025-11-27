# Qompsass AI Nix Environment
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ config, variables, ... }:
let 
  homeDir = config.users.users.user.home;
in {
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "${homeDir}/${variables.xdg.cacheHome}";
    XDG_CONFIG_HOME = "${homeDir}/${variables.xdg.configHome}";
    XDG_DATA_HOME = "${homeDir}/${variables.xdg.dataHome}";
    XDG_LIB_HOME = "${homeDir}/${variables.xdg.libHome}";
    XDG_STATE_HOME = "${homeDir}/${variables.xdg.stateHome}";
    XDG_DESKTOP_DIR = "${homeDir}/${variables.xdg.desktopDir}";
    XDG_DOWNLOAD_DIR = "${homeDir}/${variables.xdg.downloadDir}";
#######################################################################
    ANGLE_HOME = "${XDG_LIB_HOME}/angle";
    BEMENU_BACKEND = "wayland";
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    CLUTTER_BACKEND = "wayland";
    EGL_PLATFORM = "wayland";
    GDK_BACKEND = "wayland,x11";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    MESA_GLSL_CACHE_DIR = "${XDG_CACHE_HOME}/mesa_shader_cache";
    MESA_SHADER_CACHE_DIR = "${XDG_CACHE_HOME}/mesa_shader_cache_db";
    OCL_ICD_VENDORS = "${XDG_CONFIG_HOME}/OpenCL/vendors";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
    inherit (variables) EDITOR VISUAL BEMENU_BACKEND GTK_USE_PORTAL;
    inherit (variables.wm) XDG_CURRENT_DESKTOP XDG_SESSION_TYPE;
  };
}

