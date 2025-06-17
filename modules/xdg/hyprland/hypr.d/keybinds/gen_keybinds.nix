# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/keybinds/gen_keybinds.nix
# -------------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  content = ''
    $mainMod = SUPER
    bind = , escape, submap, reset
    bind = $mainMod, C, killactive,
    #bind = $mainMod, down, movefocus, d
    bind = $mainMod, I, pin
    #bind = $mainMod, left, movefocus, l
    bind = $mainMod, P, pseudo,
    #bind = $mainMod, right, movefocus, r
    bind = $mainMod, Space, togglefloating,
    bind = $mainMod, R, submap, resize
    #bind = $mainMod, up, movefocus, u
    bind = $mainMod, V, togglefloating,
    bind = ALT, F4, killactive,
    bind = ALT, Q, killactive,
    bind = ALT, Tab, togglesplit,
    bind = Ctrl+Alt_L, V, submap, passthrough
    bind = Ctrl+Alt_L, V, submap, reset
    #binde = , right, resizeactive, 10 0
    #binde = , left, resizeactive, -10 0
    #binde = , up, resizeactive, 0 -10
    #binde = , down, resizeactive, 0 10
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
    submap = resize
    submap = reset
    bind = $mainMod, P, pin
    bind = Alt, Tab, cyclenext # [hidden] sus keybind
    bind = Alt, Tab, bringactivetotop, # [hidden] bring it to the top
    bind = Ctrl+$mainMod, Backslash, resizeactive, exact 640 480 # [hidden]
    bind = $mainMod, A, layoutmsg, cycleprev
    bind = $mainMod, D, layoutmsg, cyclenext
    bind = $mainMod, S, layoutmsg, swapwithmaster
    bind = , Print, exec, screenshot fullscreen
    bind = , Print, exec, hyprshot -m region
    bindl  = , XF86AudioMute, exec, agsv1 run-js 'indicator.popup(1);' # [hidden]
    bindl  = $mainMod+Shift,M,   exec, agsv1 run-js 'indicator.popup(1);' # [hidden]
    bind = $mainMod+Alt, f12, exec, notify-send 'Test notification' "Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a 'Shell' -A "Test1=I got it!" -A "Test2=Another action" -t 5000 # [hidden]
    bind = $mainMod+Alt, Equal, exec, notify-send "Urgent notification" "Ah hell no" -u critical -a 'Hyprland keybind' # [hidden]
    # bind = SuperAlt, f12, exec, notify-send "Hyprland version: $(hyprctl version | head -2 | tail -1 | cut -f2 -d ' ')" "owo" -a 'Hyprland keybind'
    # bind = Super+Alt, f12, exec, notify-send "Millis since epoch" "$(date +%s%N | cut -b1-13)" -a 'Hyprland keybind'
    bind = ALT, SPACE, exec, wofi --show drun --allow-images
    bind = $mainMod+SHIFT, C, exec, nwg-clipman
    bind = ALT, D, exec, pkill -10 nwg-dock
    bind = ALT, F1, exec, $launcher
    bind = $mainMod, b, exec, $browser
    bind = $mainMod, D, exec, $editor
    bind = $mainMod, F1, exec, nwg-shell-help
    bind = $mainMod, f, exec, wtype '🔥'
    bind = $mainMod, G, exec, $terminal -e nvim
    bind = $mainMod, L, exec, nwg-lock
    bind = $mainMod, S, exec, $filemanager
    bind = $mainMod, T, exec, $term
    bind = $mainMod, Z, exec, Zed # Launch Zed (editor)
    bind = $mainMod+Alt, E, exec, thunar # [hidden]
    bind = $mainMod+Shift, W, exec, wps # Launch WPS Office
  '';
}

