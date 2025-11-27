# ~/.dotfiles/variables.nix
# ------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  username = "phaedrus";
  hostname = "primo";

  xdg = {
    cacheHome = ".cache";
    configHome = ".config";
    dataHome = ".local/share";
    libHome = ".local/lib";
    stateHome = ".local/state";
    desktopDir = ".Desktop";
    downloadDir = ".Downloads";
  };

  EDITOR = "nvim";
  VISUAL = "nvim";
  BEMENU_BACKEND = "wayland";
  GTK_USE_PORTAL = "1";

  mesaShaders = {
    glCacheSize = "32G";
    vkCacheSize = "10737418240";
  };

  wm = {
    currentDesktop = "Hyprland";
    sessionType = "wayland";
  };
}
