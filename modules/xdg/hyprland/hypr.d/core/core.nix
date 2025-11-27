# modules/desktop/hyprland/config/core.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktop.hyprland;
  primaryUser = builtins.head (
    builtins.filter (user: config.users.users.${user}.uid >= 1000)
    (builtins.attrNames config.users.users)
  );
  user = config.users.users.${primaryUser};
in {
  config = mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XMODIFIERS = "@im=fcitx";
    };
    home-manager.users.${primaryUser} = {
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          desktop = "${user.home}/.Desktop";
          documents = "${user.home}/.Documents";
          download = "${user.home}/.Downloads";
          music = "${user.home}/.Music";
          pictures = "${user.home}/.Pictures";
          publicShare = "${user.home}/.Public";
          templates = "${user.home}/.Templates";
          videos = "${user.home}/.Videos";
        };
      };
      wayland.windowManager.hyprland.settings = {
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XMODIFIERS,@im=fcitx"
          "XDG_MENU_PREFIX,nixos-"
          "XDG_RUNTIME_DIR,/run/user/${toString user.uid}"
          "XDG_SEAT,seat0"
          "XDG_VTNR,1"
        ];
        general = {
          allow_tearing = true;
          border_size = 2;
          "col.active_border" = "rgba(F7DCDE39)";
          "col.inactive_border" = "rgba(A58A8D30)";
          extend_border_grab_area = true;
          gaps_in = 5;
          gaps_out = 4;
          gaps_workspaces = 50;
          layout = "dwindle";
          no_focus_fallback = false;
          resize_corner = 0;
          resize_on_border = true;
          snap = {
            border_overlap = true;
            enabled = true;
            monitor_gap = 10;
            window_gap = 10;
          };
        };
        monitor = [
          ",preferred,auto,auto"
        ];
      };
    };
  };
}
