# ─────────────────────────────────────────────────────────────────────────────
# Declarative light/dark theming (gruvbox medium).
#
# Both palettes are defined here and built into the Nix store as per-app theme
# files. A runtime "active" selection (a tiny state file + a handful of symlinks
# the toggle owns) decides which one is live. Nothing is generated at runtime —
# the toggle only *selects* between the two declarative variants and reloads
# each program with its native mechanism.
#
# Super+i  -> theme-switch toggle   (bind lives in tiago.nix)
# ─────────────────────────────────────────────────────────────────────────────
{ config, pkgs, lib, ... }:
let
  # ── Palettes ───────────────────────────────────────────────────────────────
  # Semantic names. "b"-suffixed keys are the gruvbox "bright" accents (which in
  # the light theme are the faded/darker variants, so they stay readable).
  dark = {
    bg = "282828"; bg_h = "1d2021"; bg1 = "3c3836"; bg2 = "504945";
    bg3 = "665c54"; bg4 = "7c6f64";
    fg0 = "fbf1c7"; fg = "ebdbb2"; fg2 = "d5c4a1"; fg3 = "bdae93"; fg4 = "a89984";
    gray = "928374";
    red = "cc241d"; redb = "fb4934"; green = "98971a"; greenb = "b8bb26";
    yellow = "d79921"; yellowb = "fabd2f"; blue = "458588"; blueb = "83a598";
    purple = "b16286"; purpleb = "d3869b"; aqua = "689d6a"; aquab = "8ec07c";
    orange = "d65d0e"; orangeb = "fe8019";
  };
  light = {
    bg = "fbf1c7"; bg_h = "f9f5d7"; bg1 = "ebdbb2"; bg2 = "d5c4a1";
    bg3 = "bdae93"; bg4 = "a89984";
    fg0 = "282828"; fg = "3c3836"; fg2 = "504945"; fg3 = "665c54"; fg4 = "7c6f64";
    gray = "928374";
    red = "9d0006"; redb = "cc241d"; green = "79740e"; greenb = "98971a";
    yellow = "b57614"; yellowb = "d79921"; blue = "076678"; blueb = "458588";
    purple = "8f3f71"; purpleb = "b16286"; aqua = "427b58"; aquab = "689d6a";
    orange = "af3a03"; orangeb = "d65d0e";
  };

  # ── Per-app theme templates (palette p -> file text) ───────────────────────
  mkKitty = p: ''
    foreground            #${p.fg}
    background            #${p.bg}
    selection_foreground  #${p.bg}
    selection_background  #${p.fg}
    cursor                #${p.fg}
    cursor_text_color     #${p.bg}
    url_color             #${p.blueb}
    active_border_color   #${p.greenb}
    inactive_border_color #${p.bg3}
    bell_border_color     #${p.yellowb}
    active_tab_foreground   #${p.bg}
    active_tab_background   #${p.fg4}
    inactive_tab_foreground #${p.fg4}
    inactive_tab_background #${p.bg1}
    tab_bar_background      #${p.bg}
    color0  #${p.bg}
    color8  #${p.gray}
    color1  #${p.red}
    color9  #${p.redb}
    color2  #${p.green}
    color10 #${p.greenb}
    color3  #${p.yellow}
    color11 #${p.yellowb}
    color4  #${p.blue}
    color12 #${p.blueb}
    color5  #${p.purple}
    color13 #${p.purpleb}
    color6  #${p.aqua}
    color14 #${p.aquab}
    color7  #${p.fg4}
    color15 #${p.fg}
  '';

  mkWaybar = p: ''
    * {
        font-family: "JetBrains Mono Nerd Font";
        font-weight: bold;
        font-size: 15px;
    }

    #custom-notification {
      font-family: "JetBrains Mono Nerd Font";
      font-size: 17px;
      color: #${p.fg};
      margin: 2px 0px 0px 0px;
    }

    window#waybar {
        background: #${p.bg};
        border: 3px solid #${p.bg3};
        border-radius: 10px;
    }

    tooltip {
        background: #${p.bg1};
        color: #${p.fg};
        font-size: 13px;
        border-radius: 7px;
        border: 2px solid #${p.bg2};
    }

    #workspaces {
        background: rgba(0, 0, 0, 0.0);
        color: #${p.gray};
        border-radius: 9px;
        transition: 0.2s ease;
        padding-left: 4px;
        padding-right: 4px;
        padding-top: 1px;
    }

    #workspaces button {
        background: rgba(0, 0, 0, 0.0);
        color: #${p.fg};
        border-radius: 9px;
        transition: 0.2s ease;
        padding-left: 4px;
        padding-right: 4px;
    }

    #workspaces button.active {
        color: #${p.fg};
        transition: all 0.3s ease;
        padding-left: 4px;
        padding-right: 4px;
    }

    #workspaces button:hover {
        background: none;
        color: #${p.greenb};
        transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #custom-bitcoin,
    #custom-weather,
    #custom-date {
        color: #${p.fg};
        font-weight: normal;
        font-size: 15px;
        padding-left: 4px;
        padding-right: 4px;
    }

    #custom-spacer {
        opacity: 1.0;
        color: #${p.fg};
        font-weight: bold;
        padding-left: 2px;
        padding-right: 2px;
    }

    #custom-smallspacer { opacity: 0.0; }

    #backlight {
        color: #${p.blueb};
        background: rgba(0, 0, 0, 0.0);
        font-weight: normal;
        font-size: 19px;
        margin: 1px 0px 0px 0px;
        padding-left: 0px;
        padding-right: 2px;
    }

    #battery {
        font-weight: normal;
        font-size: 22px;
        color: #${p.greenb};
        background: rgba(0, 0, 0, 0.0);
    }

    #battery.charging, #battery.plugged { color: #${p.fg0}; }
    #battery.critical:not(.charging) { color: #${p.redb}; }

    #clock {
        color: #${p.fg};
        font-size: 15px;
        font-weight: 900;
        font-family: "JetBrains Mono Nerd Font";
        background: rgba(0, 0, 0, 0.0);
        margin: 3px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
    }

    #pulseaudio {
        font-weight: normal;
        font-size: 18px;
        color: #${p.purpleb};
        background: rgba(0, 0, 0, 0.0);
        padding-left: 3px;
        padding-right: 3px;
    }

    #network {
        color: #${p.fg};
        font-weight: normal;
        font-size: 19px;
        padding-right: 0px;
        padding-left: 4px;
    }

    #mpris {
        color: #${p.fg};
        font-size: 15px;
        font-weight: bold;
        animation-name: blink;
        animation-duration: 3s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    @keyframes blink {
        to { color: #${p.bg3}; }
    }

    #tray, #window {
        color: #${p.fg};
        font-family: "Martian Mono";
    }

    #custom-l_end,
    #custom-r_end,
    #upower {
        color: #${p.greenb};
    }

    #custom-l_end {
        border-radius: 7px 0px 0px 7px;
        margin-left: 1px;
        padding-left: 3px;
    }

    #custom-r_end {
        border-radius: 0px 7px 7px 0px;
        margin-right: 1px;
        padding-right: 3px;
    }

    #custom-menu {
        color: #${p.fg0};
        background: rgba(0, 0, 0, 0.0);
        opacity: 0.1;
    }

    #backlight-slider slider,
    #pulseaudio-slider slider {
        background-color: transparent;
        box-shadow: none;
        margin-right: 7px;
    }

    #backlight-slider trough,
    #pulseaudio-slider trough {
        margin-top: -3px;
        min-width: 90px;
        min-height: 10px;
        margin-bottom: -4px;
        border-radius: 8px;
        background: #${p.bg2};
    }

    #backlight-slider highlight,
    #pulseaudio-slider highlight {
        border-radius: 8px;
        background-color: #${p.blueb};
    }
  '';

  mkDunst = p: ''
    [global]
        monitor = 0
        follow = none
        width = 600
        height = (0, 300)
        origin = top-right
        offset = (10, 50)
        scale = 0
        notification_limit = 20
        progress_bar = true
        progress_bar_height = 10
        progress_bar_frame_width = 1
        progress_bar_min_width = 150
        progress_bar_max_width = 300
        progress_bar_corner_radius = 0
        progress_bar_corners = all
        icon_corner_radius = 0
        icon_corners = all
        indicate_hidden = yes
        transparency = 0
        separator_height = 2
        padding = 8
        horizontal_padding = 8
        text_icon_padding = 0
        frame_width = 3
        frame_color = "#${p.blue}"
        gap_size = 0
        separator_color = frame
        sort = yes
        font = Monospace 16
        line_height = 0
        markup = full
        format = "<b>%s</b>\n%b"
        alignment = left
        vertical_alignment = center
        show_age_threshold = 60
        ellipsize = middle
        ignore_newline = no
        stack_duplicates = true
        hide_duplicate_count = false
        show_indicators = yes
        enable_posix_regex = false
        enable_recursive_icon_lookup = true
        icon_theme = Adwaita
        icon_position = left
        min_icon_size = 32
        max_icon_size = 128
        sticky_history = yes
        history_length = 20
        dmenu = /usr/bin/dmenu -p dunst:
        browser = /usr/bin/xdg-open
        always_run_script = true
        title = Dunst
        class = Dunst
        corner_radius = 0
        corners = all
        ignore_dbusclose = false
        force_xwayland = false
        force_xinerama = false
        mouse_left_click = close_current
        mouse_middle_click = do_action, close_current
        mouse_right_click = close_all

    [experimental]
        per_monitor_dpi = false
        pause_on_mouse_over = false
        enable_pcre_regex = false

    [urgency_low]
        background = "#${p.bg}"
        foreground = "#${p.fg4}"
        frame_color = "#${p.bg3}"
        timeout = 10
        default_icon = dialog-information

    [urgency_normal]
        background = "#${p.bg}"
        foreground = "#${p.fg}"
        frame_color = "#${p.blue}"
        timeout = 10
        override_pause_level = 30
        default_icon = dialog-information

    [urgency_critical]
        background = "#${p.bg}"
        foreground = "#${p.redb}"
        frame_color = "#${p.redb}"
        timeout = 0
        override_pause_level = 60
        default_icon = dialog-warning
  '';

  mkFuzzel = p: ''
    [main]
    font=Cascadia Code:size=14
    terminal=kitty

    [colors]
    background=${p.bg}ff
    text=${p.fg}ff
    match=${p.greenb}ff
    selection=${p.bg2}ff
    selection-text=${p.fg}ff
    border=${p.blueb}ff
  '';

  # btop theme. theme_background is forced false in btop.conf so main_bg="" lets
  # btop inherit the (themed) terminal background.
  mkBtop = p: ''
    theme[main_bg]=""
    theme[main_fg]="#${p.fg}"
    theme[title]="#${p.fg}"
    theme[hi_fg]="#${p.blueb}"
    theme[selected_bg]="#${p.bg1}"
    theme[selected_fg]="#${p.fg}"
    theme[inactive_fg]="#${p.bg3}"
    theme[graph_text]="#${p.fg4}"
    theme[meter_bg]="#${p.bg1}"
    theme[proc_misc]="#${p.greenb}"
    theme[cpu_box]="#${p.bg3}"
    theme[mem_box]="#${p.bg3}"
    theme[net_box]="#${p.bg3}"
    theme[proc_box]="#${p.bg3}"
    theme[div_line]="#${p.bg2}"
    theme[temp_start]="#${p.greenb}"
    theme[temp_mid]="#${p.yellowb}"
    theme[temp_end]="#${p.redb}"
    theme[cpu_start]="#${p.greenb}"
    theme[cpu_mid]="#${p.yellowb}"
    theme[cpu_end]="#${p.redb}"
    theme[free_start]="#${p.blueb}"
    theme[free_mid]=""
    theme[free_end]=""
    theme[cached_start]="#${p.aquab}"
    theme[cached_mid]=""
    theme[cached_end]=""
    theme[available_start]="#${p.yellowb}"
    theme[available_mid]=""
    theme[available_end]=""
    theme[used_start]="#${p.redb}"
    theme[used_mid]=""
    theme[used_end]=""
    theme[download_start]="#${p.blueb}"
    theme[download_mid]="#${p.aquab}"
    theme[download_end]="#${p.greenb}"
    theme[upload_start]="#${p.purpleb}"
    theme[upload_mid]="#${p.orangeb}"
    theme[upload_end]="#${p.redb}"
    theme[process_start]="#${p.greenb}"
    theme[process_mid]="#${p.yellowb}"
    theme[process_end]="#${p.redb}"
  '';

  mkMpv = p: ''
    background-color="#${p.bg}"
  '';

  # btop.conf — theme-driven color_theme + writable (the toggle copies the
  # chosen variant in, and btop may rewrite it on exit).
  mkBtopConf = mode: ''
    color_theme = "gruvbox_${mode}"
    theme_background = false
    truecolor = true
    force_tty = false
    vim_keys = true
    disable_mouse = false
    rounded_corners = false
    terminal_sync = true
    graph_symbol = "block"
    shown_boxes = "cpu mem net proc"
    update_ms = 100
    proc_sorting = "cpu lazy"
    proc_reversed = true
    proc_tree = true
    proc_per_core = false
    proc_mem_bytes = true
    proc_cpu_graphs = true
    cpu_graph_upper = "Auto"
    cpu_graph_lower = "Auto"
    cpu_invert_lower = true
    cpu_single_graph = false
    show_uptime = true
    check_temp = true
    show_coretemp = true
    temp_scale = "celsius"
    show_cpu_freq = true
    clock_format = "%X"
    mem_graphs = true
    show_swap = true
    swap_disk = true
    show_disks = false
    only_physical = true
    use_fstab = true
    show_io_stat = true
    net_auto = true
    net_sync = true
    show_battery = true
    selected_battery = "Auto"
    log_level = "WARNING"
    save_config_on_exit = true
  '';

  # Per-mode wallpaper (rendered with swaybg).
  wallpaper = {
    dark  = "${config.home.homeDirectory}/projects/wallpaper1.png";
    light = "${config.home.homeDirectory}/projects/wallpaper3.png";
  };

  binPath = lib.makeBinPath [
    pkgs.coreutils pkgs.procps pkgs.glib pkgs.libnotify
    pkgs.dunst pkgs.waybar pkgs.hyprland pkgs.swaybg
  ];

  # gsettings needs the org.gnome.desktop.interface schema on XDG_DATA_DIRS,
  # otherwise `gsettings set` errors with "No such schema" and GTK/Firefox
  # theming silently does nothing.
  schemaDir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}";

  # theme-switch [toggle|dark|light|login]
  #   toggle/dark/light  full switch (used by Super+i) — re-themes every app
  #   login              apply only what boot can't (wallpaper, GTK/portal,
  #                      hyprland borders); the bars/terminals already come up
  #                      themed from the activation symlinks, so they're left
  #                      alone to avoid a restart flash.
  theme-switch = pkgs.writeShellScriptBin "theme-switch" ''
    set -euo pipefail
    export PATH=${binPath}:$PATH
    export XDG_DATA_DIRS="${schemaDir}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
    C="$HOME/.config"
    st="$HOME/.local/state/theme/mode"
    mkdir -p "$(dirname "$st")"
    cur=$(cat "$st" 2>/dev/null || echo dark)

    full=1
    case "''${1:-toggle}" in
      toggle)     [ "$cur" = dark ] && mode=light || mode=dark ;;
      dark|light) mode="$1" ;;
      login)      mode="$cur"; full=0 ;;
      *) echo "usage: theme-switch [toggle|dark|light|login]" >&2; exit 1 ;;
    esac

    # ── Things boot can't set itself (always applied) ────────────────────────
    # wallpaper (swaybg). On a full switch we always reconcile. At login we only
    # need to act for light mode — hyprland's own exec-once already brings up the
    # dark wallpaper — and we wait a moment so we replace it rather than race it.
    if [ "$mode" = dark ]; then wp="${wallpaper.dark}"; else wp="${wallpaper.light}"; fi
    if [ "$full" = 1 ] || [ "$mode" = light ]; then
      [ "$full" = 0 ] && sleep 1
      # NOTE: no `-x` — the nix-wrapped process is named ".swaybg-wrapped", so an
      # exact-name match would never hit it and we'd spawn duplicates.
      pkill swaybg 2>/dev/null || true
      (setsid swaybg -i "$wp" -m fill >/dev/null 2>&1 &) || true
    fi

    # hyprland window borders
    if [ "$mode" = dark ]; then
      hyprctl keyword general:col.active_border   "rgba(${dark.blueb}ff)" >/dev/null 2>&1 || true
      hyprctl keyword general:col.inactive_border "rgba(${dark.bg3}ff)"   >/dev/null 2>&1 || true
    else
      hyprctl keyword general:col.active_border   "rgba(${light.blueb}ff)" >/dev/null 2>&1 || true
      hyprctl keyword general:col.inactive_border "rgba(${light.bg3}ff)"   >/dev/null 2>&1 || true
    fi

    # GTK apps + Firefox (via xdg-desktop-portal appearance)
    if [ "$mode" = dark ]; then
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'  2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme    'Adwaita-dark' 2>/dev/null || true
    else
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme    'Adwaita'      2>/dev/null || true
    fi

    if [ "$full" = 1 ]; then
      # kitty: swap the included colour file, reload running instances live
      cp -f "$C/kitty/themes/$mode.conf" "$C/kitty/current-theme.conf"
      pkill -USR1 kitty 2>/dev/null || true

      # waybar: point style.css at the variant, then reload in place.
      # SIGUSR2 makes waybar re-read its config + CSS without spawning a new
      # process — so no flash and, crucially, no duplicate bars. (The process is
      # nix-wrapped as ".waybar-wrapped", so match without `-x`.) If none is
      # running, start one.
      ln -sf "$C/waybar/themes/$mode.css" "$C/waybar/style.css"
      pkill -USR2 waybar 2>/dev/null || (setsid waybar >/dev/null 2>&1 &) || true

      # dunst: swap config + live reload (dunstctl uses D-Bus; the pkill
      # fallback drops `-x` for the same wrapped-name reason).
      ln -sf "$C/dunst/themes/$mode" "$C/dunst/dunstrc"
      dunstctl reload 2>/dev/null || { pkill dunst 2>/dev/null || true; (setsid dunst >/dev/null 2>&1 &) || true; }

      # fuzzel / mpv / btop: picked up on next launch
      ln -sf "$C/fuzzel/themes/$mode.ini" "$C/fuzzel/fuzzel.ini"
      ln -sf "$C/mpv/themes/$mode.conf"   "$C/mpv/active.conf"
      cp -f "$C/btop/themes/$mode.conf"   "$C/btop/btop.conf"

      # helix: swap the inheriting theme (running editors: :config-reload)
      ln -sf "$C/helix/themes/current-$mode.toml" "$C/helix/themes/current.toml"

      echo "$mode" > "$st"
      notify-send -t 1500 "Theme" "$mode mode" 2>/dev/null || true
    fi
  '';
in
{
  home.packages = [
    theme-switch
    pkgs.btop
    pkgs.glib                 # gsettings
    pkgs.libnotify            # notify-send
    pkgs.gnome-themes-extra   # Adwaita / Adwaita-dark GTK theme
  ];

  # ── Declarative theme variants (read-only, in the Nix store) ───────────────
  xdg.configFile = {
    "kitty/themes/dark.conf".text  = mkKitty dark;
    "kitty/themes/light.conf".text = mkKitty light;

    "waybar/themes/dark.css".text  = mkWaybar dark;
    "waybar/themes/light.css".text = mkWaybar light;

    "dunst/themes/dark".text  = mkDunst dark;
    "dunst/themes/light".text = mkDunst light;

    "fuzzel/themes/dark.ini".text  = mkFuzzel dark;
    "fuzzel/themes/light.ini".text = mkFuzzel light;

    "btop/themes/gruvbox_dark.theme".text  = mkBtop dark;
    "btop/themes/gruvbox_light.theme".text = mkBtop light;
    "btop/themes/dark.conf".text  = mkBtopConf "dark";
    "btop/themes/light.conf".text = mkBtopConf "light";

    "mpv/themes/dark.conf".text  = mkMpv dark;
    "mpv/themes/light.conf".text = mkMpv light;

    "helix/themes/current-dark.toml".text  = ''inherits = "gruvbox"'';
    "helix/themes/current-light.toml".text = ''inherits = "gruvbox_light"'';

    # Disable the static, single-mode files defined in tiago.nix so the toggle
    # can own these paths at runtime (swapped between the variants above).
    "waybar/style.css".enable  = lib.mkForce false;
    "dunst/dunstrc".enable     = lib.mkForce false;
    "fuzzel/fuzzel.ini".enable = lib.mkForce false;
    "btop/btop.conf".enable    = lib.mkForce false;
  };

  # kitty.conf includes the toggle-owned colour file last (after settings), so
  # it overrides the hard-coded colours; reloaded live via SIGUSR1.
  programs.kitty.extraConfig = "include current-theme.conf";

  # helix: point at the "current" theme, which is symlinked to gruvbox
  # light/dark by the toggle.
  programs.helix.settings.theme = lib.mkForce "current";

  # mpv: pull the per-mode background colour from the toggle-owned file.
  programs.mpv.config.include =
    "${config.home.homeDirectory}/.config/mpv/active.conf";

  # Super+i toggles; the saved mode is applied at login (wallpaper, GTK/portal
  # scheme and borders — the bars/terminals already start themed).
  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER, I, exec, theme-switch toggle
    exec-once = theme-switch login
  '';

  # ── Initialise the active selection on rebuild ─────────────────────────────
  # Creates the toggle-owned symlinks/copies (defaulting to dark) so waybar,
  # dunst, fuzzel, etc. have a valid config the first time they start.
  home.activation.themeInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    C="$HOME/.config"
    st="$HOME/.local/state/theme/mode"
    run mkdir -p "$(dirname "$st")"
    mode=$(cat "$st" 2>/dev/null || echo dark)
    run ln -sf "$C/waybar/themes/$mode.css"            "$C/waybar/style.css"
    run ln -sf "$C/dunst/themes/$mode"                 "$C/dunst/dunstrc"
    run ln -sf "$C/fuzzel/themes/$mode.ini"            "$C/fuzzel/fuzzel.ini"
    run ln -sf "$C/mpv/themes/$mode.conf"              "$C/mpv/active.conf"
    run ln -sf "$C/helix/themes/current-$mode.toml"    "$C/helix/themes/current.toml"
    run cp -f  "$C/kitty/themes/$mode.conf"            "$C/kitty/current-theme.conf"
    run cp -f  "$C/btop/themes/$mode.conf"             "$C/btop/btop.conf"
    run sh -c "echo $mode > $st"
  '';
}
