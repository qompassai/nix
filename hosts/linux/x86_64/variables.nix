# Qompass AI NixOS variables module
{
  config,
  lib,
  ...
}: {
  config = {
    environment.sessionVariables.XDG_DATA_DIRS = lib.mkForce "/run/current-system/sw/share:/home/phaedrus/.nix-profile/share:/home/phaedrus/.local/share:/usr/local/share:/usr/share";
  };
  options = {
    browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
      example = "firefox";
      description = "Default browser for the system.";
    };
    clock24h = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = true;
      description = "Use 24-hour clock format.";
    };
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default text/code editor.";
    };
    extraMonitorSettings = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra monitor settings (if any).";
    };
    gitUsername = lib.mkOption {
      type = lib.types.str;
      default = "phaedrus";
      example = "phaedrus";
      description = "Git username for this system.";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "map@qompass.ai";
      example = "map@qompass.ai";
      description = "Git email address for this system.";
    };
    gtkTheme = lib.mkOption {
      type = lib.types.str;
      default = "adwaita";
      description = "Default GTK theme for graphical sessions.";
    };
    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "adwaita";
      description = "Default icon theme.";
    };
    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      example = "us";
      description = "Keyboard layout for the system.";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "System locale.";
    };
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
      example = "ghostty";
      description = "Preferred terminal emulator.";
    };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "Time zone.";
    };
  };
}
