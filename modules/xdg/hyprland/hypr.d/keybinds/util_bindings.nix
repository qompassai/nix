# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/keybinds/util_bindings.nix
# --------------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  content = ''
    $mainMod = SUPER

    ##! Widgets
    bindr = Ctrl+Super, R, exec, killall ags agsv1 ydotool; agsv1 & # Restart widgets
    bindr = Ctrl+Super+Alt, R, exec, hyprctl reload; killall agsv1 ydotool; agsv1 & # [hidden]
    bind = Ctrl+Alt, Slash, exec, agsv1 run-js 'cycleMode();' # Cycle bar mode (normal, focus)
    bindir = Super, Super_L, exec, agsv1 -t 'overview' # Toggle overview/launcher
    bind = Super, Tab, exec, agsv1 -t 'overview' # [hidden]
    bind = Super, Slash, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t "cheatsheet""$i"; done # Show cheatsheet
    bind = Super, B, exec, agsv1 -t 'sideleft' # Toggle left sidebar
    bind = Super, A, exec, agsv1 -t 'sideleft' # [hidden]
    bind = Super, O, exec, agsv1 -t 'sideleft' # [hidden]
    bind = Super, N, exec, agsv1 -t 'sideright' # Toggle right sidebar
    bind = Super, Comma, exec, agsv1 run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);' # View color scheme and options
    bind = Super, K, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t "osk""$i"; done # Toggle on-screen keyboard
    bind = Ctrl+Alt, Delete, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t "session""$i"; done # Toggle power menu
    bind = Ctrl+Super, G, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t "crosshair""$i"; done # Toggle crosshair
    bindle=, XF86MonBrightnessUp, exec, agsv1 run-js 'brightness.screen_value += 0.05; indicator.popup(1);' # [hidden]
    bindle=, XF86MonBrightnessDown, exec, agsv1 run-js 'brightness.screen_value -= 0.05; indicator.popup(1);' # [hidden]
    bind = Ctrl+Super, Slash, exec, pkill anyrun || anyrun # Toggle fallback launcher: anyrun
    bind = Super+Alt, Slash, exec, pkill fuzzel || fuzzel # Toggle fallback launcher: fuzzel
  '';
}

