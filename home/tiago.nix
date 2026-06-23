{ config, pkgs, pkgs-unstable, lib, ... }:
{
  home.username = "tiago";
  home.homeDirectory = "/home/tiago";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    HYPRCURSOR_THEME = "Nordzy-hyprcursors";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
  };

  home.packages = with pkgs; [
    # Wayland / Hyprland ecosystem
    swww
    hypridle
    hyprpaper
    fuzzel
    grimblast
    cliphist
    wl-clipboard

    # Audio / brightness / media control
    pamixer
    brightnessctl
    playerctl

    # System tools
    udiskie
    waypaper

    # Apps
    firefox
    obsidian
    yazi
    cmus
    fastfetch
    lazygit

    # Notifications
    dunst
    mako
    swaynotificationcenter

    # CLI tools (used by yazi keymaps)
    ripgrep
    fd
    feh

    curl

    pkgs-unstable.claude-code
  ];

  # ── Hyprland ──────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    extraConfig = ''
      monitor=eDP-1,preferred,auto,1
      monitor=HDMI-A-1,preferred,auto,0.8,mirror,eDP-1

      xwayland {
          force_zero_scaling = true
      }

      $terminal = kitty
      $fileManager = yazi
      $menu = dmenu --show drun
      $browser = firefox
      $drawing = krita

      exec-once = mako & udiskie & firefox &
      exec-once = sleep 1 &
      exec-once = waybar
      exec-once = hypridle &
      exec-once = systemctl --user start opentabletdriver.service
      exec-once = swww-daemon
      exec-once = swww img /home/tiago/Pictures/hmhm.jpg
      exec-once = wl-paste --watch cliphist store
      exec-once = dunst
      exec-once = mpv --really-quiet /home/tiago/Downloads/windows-7-startup.mp3

      env = HYPRCURSOR_THEME,Nordzy-hyprcursors
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      env = fileManager,yazi

      binds {
          workspace_back_and_forth = false
      }

      general {
          gaps_in = 3
          gaps_out = 7
          border_size = 2
          col.active_border = 0x80FFFFFF
          col.inactive_border = 0xFF000000
          resize_on_border = true
          allow_tearing = false
          layout = dwindle
      }

      decoration {
          rounding = 7
          active_opacity = 1
          inactive_opacity = 1

          shadow {
              enabled = false
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }

          blur {
              enabled = no
              size = 10
              passes = 1
              vibrancy = 0.1696
          }
      }

      animations {
          enabled = false
          bezier = niercurve, 0.4, 0, 0.2, 1
          animation = windows,      1, 1, niercurve, slide
          animation = windowsOut,   1, 1, niercurve, slide
          animation = fade,         1, 1, niercurve
          animation = workspaces,   1, 1, niercurve, slidevert
      }

      dwindle {
          preserve_split = true
      }

      master {
          new_status = master
      }

      misc {
          force_default_wallpaper = -1
          disable_hyprland_logo = false
      }

      input {
          kb_layout = br
          kb_variant = abnt2
          kb_options = caps:swapescape
          follow_mouse = 1
          sensitivity = 0.0

          touchpad {
              natural_scroll = false
          }

          tablet {
              relative_input = false
          }

          accel_profile = adaptive
      }

      device {
          name = epic-mouse-v1
          sensitivity = -0.5
      }

      $mainMod = SUPER

      bind = $mainMod, RETURN, exec, $terminal
      bind = $mainMod, Q, killactive,
      bind = $mainMod, E, exec, kitty -e "yazi"
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, fuzzel
      bind = $mainMod, Y, exec, $browser
      bind = ALT, Tab, cyclenext,
      bind = Alt, Tab, bringactivetotop,
      bind = $mainMod, U, exec, obsidian

      bind = SUPER, S, exec, sh -c 'notify-send "Sats" "$(sat "$(wl-paste -p)")"'
      bind = SUPER, T, exec, sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'
      bind = SUPER, Print, exec, grimblast --freeze copysave area

      bind = $mainMod, H, workspace, 1
      bind = $mainMod, J, workspace, 2
      bind = $mainMod, K, workspace, 3
      bind = $mainMod, L, workspace, 4

      bind = , F7, exec, brightnessctl set +5%
      bind = , F6, exec, brightnessctl set 5%-
      bind = , F8, exec, brightnessctl -d dell::kbd_backlight set +1
      bind = , F9, exec, brightnessctl -d dell::kbd_backlight set 1-
      bind = , F2, exec, pamixer -d 5
      bind = , F3, exec, pamixer -i 5
      bind = , F1, exec, pamixer -t

      bind = $mainMod SHIFT, H, movetoworkspace, 1
      bind = $mainMod SHIFT, J, movetoworkspace, 2
      bind = $mainMod SHIFT, K, movetoworkspace, 3
      bind = $mainMod SHIFT, L, movetoworkspace, 4

      bind = $mainMod, mouse_up, workspace, e+1
      bind = $mainMod, mouse_down, workspace, e-1

      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
      bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
    '';
  };

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = echo lock
    }

    listener {
        timeout = 30
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }
  '';

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = /home/tiago/violet1.avif
    wallpaper = eDP-1,/home/tiago/violet1.avif
    ipc = on
  '';

  # ── Kitty ─────────────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    font = {
      name = "Cascadia Code";
      size = 14;
    };
    settings = {
      modify_font = "cell_height 120%";
      disable_ligatures = "never";
      bold_font = "auto";
      italic_font = "auto";
      window_padding_width = 0;
      confirm_os_window_close = 0;
      cursor_trail = 100;
      cursor_trail_start_threshold = 0;
      cursor_trail_decay = "0.001 0.05";
      cursor_shape = "block";
      cursor_blink = true;
      enable_audio_bell = true;

      # Catppuccin Latte
      foreground = "#4C4F69";
      background = "#EFF1F5";
      selection_foreground = "#EFF1F5";
      selection_background = "#DC8A78";
      cursor = "#DC8A78";
      cursor_text_color = "#EFF1F5";
      url_color = "#DC8A78";
      active_border_color = "#7287FD";
      inactive_border_color = "#9CA0B0";
      bell_border_color = "#DF8E1D";
      active_tab_foreground = "#EFF1F5";
      active_tab_background = "#8839EF";
      inactive_tab_foreground = "#4C4F69";
      inactive_tab_background = "#9CA0B0";
      tab_bar_background = "#BCC0CC";
      color0 = "#5C5F77";
      color8 = "#6C6F85";
      color1 = "#D20F39";
      color9 = "#D20F39";
      color2 = "#40A02B";
      color10 = "#40A02B";
      color3 = "#DF8E1D";
      color11 = "#DF8E1D";
      color4 = "#1E66F5";
      color12 = "#1E66F5";
      color5 = "#EA76CB";
      color13 = "#EA76CB";
      color6 = "#179299";
      color14 = "#179299";
      color7 = "#ACB0BE";
      color15 = "#BCC0CC";
    };
  };

  xdg.configFile."kitty/themes/asuka.conf".text = ''
    ## name: Asuka
    ## author: Leon Jude Gonsalves
    ## blurb: "God's in His heaven. All's right with the world."

    foreground                      #ff5555
    background                      #1a1a1a
    selection_foreground            #000000
    selection_background            #50fa7b

    cursor                          #ff5555
    cursor_text_color               #000000

    url_color                       #ff5555

    wayland_titlebar_color          #1a1a1a

    color0 #1a1a1a
    color8 #6272a4
    color1 #ff5555
    color9 #ff6e6e
    color2  #50fa7b
    color10 #69ff94
    color3  #f1fa8C
    color11 #ffffa5
    color4  #bd93f9
    color12 #d6acff
    color5  #ff79c6
    color13 #ff92df
    color6  #8be9fd
    color14 #a4ffff
    color7  #f8f8f2
    color15 #ffffff
  '';

  # ── MPV ───────────────────────────────────────────────────────────────────
  programs.mpv = {
    enable = true;
    config = {
      loop = "inf";
      "background-color" = "#454545";
    };
  };

  # ── yt-dlp ────────────────────────────────────────────────────────────────
  programs.yt-dlp.enable = true;

  # ── Zathura ───────────────────────────────────────────────────────────────
  programs.zathura = {
    enable = true;
    options = {
      adjust-open = "best-fit";
      pages-per-row = 1;
      scroll-page-aware = true;
      smooth-scroll = true;
      scroll-full-overlap = "0.01";
      scroll-step = 50;
      zoom-min = 10;
      guioptions = "";
    };
    extraConfig = ''
      unmap f
      map f toggle_fullscreen
      map [fullscreen] f toggle_fullscreen
    '';
  };

  # ── Waybar ────────────────────────────────────────────────────────────────
  programs.waybar.enable = true;

  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top",
        "position": "top",
        "mod": "dock",
        "margin-left": 10,
        "margin-right": 10,
        "margin-top": 7,
        "margin-bottom": 0,
        "exclusive": true,
        "passthrough": false,
        "gtk-layer-shell": true,
        "reload_style_on_change": true,

        "modules-left": ["custom/smallspacer","custom/oscomputer","hyprland/workspaces","custom/spacer","hyprland/window"],
        "modules-center": ["custom/padd","custom/l_end","custom/r_end","mpris","custom/padd"],
        "modules-right": ["custom/padd","custom/l_end","group/expand","custom/spacer","custom/bitcoin","custom/spacer","custom/weather","custom/spacer","network","custom/spacer","group/expand-3","custom/spacer","group/expand-2","custom/spacer","group/expand-4","custom/spacer","custom/date","custom/spacer","clock","custom/spacer","custom/notification","custom/padd"],

        "custom/smallspacer": { "format": " " },

        "mpris": {
            "format": "{player_icon} {dynamic}",
            "format-paused": "<span color='grey'>{status_icon} {dynamic}</span>",
            "max-length": 50,
            "player-icons": { "default": "⏸", "mpv": "🎵" },
            "status-icons": { "paused": "▶" }
        },

        "tray": { "icon-size": 16, "rotate": 0, "spacing": 3 },

        "group/expand": {
            "orientation": "horizontal",
            "drawer": {
                "transition-duration": 600,
                "children-class": "not-power",
                "transition-to-left": true
            },
            "modules": ["custom/menu","custom/spacer","tray"]
        },

        "custom/menu": { "format": "󰅃", "rotate": 90 },

        "custom/notification": {
            "tooltip": false,
            "format": "{icon}",
            "format-icons": {
                "notification": "󰅸", "none": "󰂜",
                "dnd-notification": "󰅸", "dnd-none": "󱏨",
                "inhibited-notification": "󰅸", "inhibited-none": "󰂜",
                "dnd-inhibited-notification": "󰅸", "dnd-inhibited-none": "󱏨"
            },
            "return-type": "json",
            "exec-if": "which swaync-client",
            "exec": "swaync-client -swb",
            "on-click-right": "swaync-client -d -sw",
            "on-click": "swaync-client -t -sw",
            "escape": true
        },

        "hyprland/window": {
            "format": "<span weight='bold'>{class}</span>",
            "max-length": 120,
            "icon": false,
            "icon-size": 13
        },

        "custom/spacer": { "format": "|" },

        "custom/oscomputer": { "format": "󰟀 ", "tooltip": false },

        "custom/bitcoin": {
            "exec": "price=$(curl -sf --max-time 5 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd' | grep -o '[0-9]*' | head -1); [ -n \"$price\" ] && printf '🪙 %s' \"$(printf '%s' \"$price\" | sed ':a;s/\\B[0-9]\\{3\\}\\>/.&/;ta')\"",
            "format": "{}",
            "interval": 300,
            "tooltip-format": "Bitcoin price (USD)"
        },

        "custom/weather": {
            "exec": "curl -sf --max-time 5 'https://wttr.in/Espirito+Santo+do+Pinhal?format=%c%t' | tr -d '+'",
            "format": "{}",
            "interval": 600,
            "tooltip-format": "Espírito Santo do Pinhal, SP"
        },

        "custom/date": {
            "exec": "LC_TIME=en_US.UTF-8 date '+%A, %-d %B'",
            "format": "📅 {}",
            "interval": 60,
            "tooltip": false
        },

        "hyprland/workspaces": {
            "format": "{name}",
            "persistent-workspaces": { "*": [1, 2, 3, 4] },
            "ignore-workspaces": ["5","6","7","8","9","10"]
        },

        "upower": {
            "icon-size": 20,
            "format": "",
            "format-alt": "{}<span color='orange'>[{time}]</span>",
            "tooltip": true,
            "tooltip-spacing": 20
        },

        "upower#headset": {
            "format": " {percentage}",
            "native-path": "/org/freedesktop/UPower/devices/headset_dev_A6_98_9A_0D_D3_49",
            "show-icon": false,
            "tooltip": false
        },

        "group/expand-4": {
            "orientation": "horizontal",
            "drawer": {
                "transition-duration": 600,
                "children-class": "not-power",
                "transition-to-left": true,
                "click-to-reveal": true
            },
            "modules": ["upower","upower#headset"]
        },

        "idle_inhibitor": {
            "format": "{icon}",
            "format-icons": { "activated": "󰥔", "deactivated": "" }
        },

        "clock": {
            "format": "🕐 {:%I:%M %p}",
            "tooltip-format": "<tt>{calendar}</tt>",
            "calendar": {
                "mode": "month",
                "mode-mon-col": 3,
                "on-scroll": 1,
                "on-click-right": "mode",
                "format": {
                    "months": "<span color='#ffead3'><b>{}</b></span>",
                    "weekdays": "<span color='#ffcc66'><b>{}</b></span>",
                    "today": "<span color='#ff6699'><b>{}</b></span>"
                }
            },
            "actions": {
                "on-click-right": "mode",
                "on-click-forward": "tz_up",
                "on-click-backward": "tz_down",
                "on-scroll-up": "shift_up",
                "on-scroll-down": "shift_down"
            }
        },

        "battery": {
            "states": { "good": 95, "warning": 30, "critical": 20 },
            "format": "🔋 {capacity}%",
            "format-charging": "⚡",
            "format-plugged": "🔌",
            "format-icons": ["󰝦","󰪞","󰪟","󰪠","󰪡","󰪢","󰪣","󰪤","󰪥"]
        },

        "backlight": {
            "device": "intel_backlight",
            "format": "🔆",
            "format-icons": ["󰃞", "󰃝", "󰃟", "󰃠"],
            "scroll-step": 1,
            "smooth-scrolling-threshold": 4
        },

        "group/expand-2": {
            "orientation": "horizontal",
            "drawer": {
                "transition-duration": 600,
                "children-class": "not-power",
                "transition-to-left": true,
                "click-to-reveal": true
            },
            "modules": ["backlight","backlight/slider","custom/smallspacer"]
        },

        "group/expand-3": {
            "orientation": "horizontal",
            "drawer": {
                "transition-duration": 600,
                "children-class": "not-power",
                "transition-to-left": true
            },
            "modules": ["pulseaudio","pulseaudio/slider"]
        },

        "network": {
            "tooltip": true,
            "format-wifi": "📶",
            "format-ethernet": "🌐",
            "format-linked": "🌐 {ifname} (No IP)",
            "format-disconnected": "❌",
            "tooltip-format": "Network: <big><b>{essid}</b></big>\nSignal: <b>{signaldBm}dBm ({signalStrength}%)</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>",
            "interval": 2
        },

        "pulseaudio": {
            "format": "🔊 {volume}%",
            "format-muted": "🔇",
            "tooltip-format": "{icon} {desc} // {volume}%",
            "scroll-step": 1,
            "smooth-scrolling-threshold": 4,
            "format-icons": {
                "headphone": "", "hands-free": "", "headset": "",
                "phone": "", "portable": "", "car": "",
                "default": ["", "", ""]
            }
        },

        "backlight/slider": {
            "min": 5, "max": 100,
            "device": "intel_backlight",
            "scroll-step": 1,
            "smooth-scrolling-threshold": 4
        },

        "pulseaudio/slider": {
            "min": 5, "max": 100,
            "scroll-step": 1,
            "smooth-scrolling-threshold": 4
        },

        "custom/l_end": { "format": " ", "interval": "once", "tooltip": false },
        "custom/r_end": { "format": " ", "interval": "once", "tooltip": false },
        "custom/padd": { "format": "  ", "interval": "once", "tooltip": false }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
        font-family: "JetBrains Mono Nerd Font";
        font-weight: bold;
        font-size: 15px;
    }

    #custom-notification {
      font-family: "JetBrains Mono Nerd Font";
      font-size: 17px;
      color: #A1BDCE;
      margin: 2px 0px 0px 0px;
    }

    window#waybar {
        background: #0F0F17;
        border: 3px solid rgba(255, 255, 255, 0.1);
        border-radius: 10px;
    }

    tooltip {
        background: #171717;
        color: #A1BDCE;
        font-size: 13px;
        border-radius: 7px;
        border: 2px solid #101a24;
    }

    #workspaces {
        background: rgba(23, 23, 23, 0.0);
        color: #888789;
        border-radius: 9px;
        transition: 0.2s ease;
        padding-left: 4px;
        padding-right: 4px;
        padding-top: 1px;
    }

    #workspaces button {
        background: rgba(23, 23, 23, 0.0);
        color: #A1BDCE;
        border-radius: 9px;
        transition: 0.2s ease;
        padding-left: 4px;
        padding-right: 4px;
    }

    #workspaces button.active {
        color: #A1BDCE;
        transition: all 0.3s ease;
        padding-left: 4px;
        padding-right: 4px;
    }

    #workspaces button:hover {
        background: none;
        color: #72D792;
        transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #custom-bitcoin,
    #custom-weather,
    #custom-date {
        color: #A1BDCE;
        font-weight: normal;
        font-size: 15px;
        padding-left: 4px;
        padding-right: 4px;
    }

    #custom-spacer {
        opacity: 1.0;
        color: #A1BDCE;
        font-weight: bold;
        padding-left: 2px;
        padding-right: 2px;
    }

    #custom-smallspacer { opacity: 0.0; }

    #backlight {
        color: #2096C0;
        background: rgba(23, 23, 23, 0.0);
        font-weight: normal;
        font-size: 19px;
        margin: 1px 0px 0px 0px;
        padding-left: 0px;
        padding-right: 2px;
    }

    #battery {
        font-weight: normal;
        font-size: 22px;
        color: #a6d189;
        background: rgba(23, 23, 23, 0.0);
    }

    #battery.charging, #battery.plugged { color: #E8EDF0; }
    #battery.critical:not(.charging) { color: red; }

    #clock {
        color: #A1BDCE;
        font-size: 15px;
        font-weight: 900;
        font-family: "JetBrains Mono Nerd Font";
        background: rgba(23, 23, 23, 0.0);
        margin: 3px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
    }

    #pulseaudio {
        font-weight: normal;
        font-size: 18px;
        color: #6F8FDB;
        background: rgba(22, 19, 32, 0.0);
        padding-left: 3px;
        padding-right: 3px;
    }

    #network {
        color: #A1BDCE;
        font-weight: normal;
        font-size: 19px;
        padding-right: 0px;
        padding-left: 4px;
    }

    #mpris {
        color: white;
        font-size: 15px;
        font-weight: bold;
        animation-name: blink;
        animation-duration: 3s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    @keyframes blink {
        to { color: #4a4a4a; }
    }

    #tray, #window {
        color: #A1BDCE;
        font-family: "Martian Mono";
    }

    #custom-l_end,
    #custom-r_end,
    #upower {
        color: #a6d189;
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
        color: #E8EDF0;
        background: rgba(23, 23, 23, 0.0);
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
        background: #343434;
    }

    #backlight-slider highlight,
    #pulseaudio-slider highlight {
        border-radius: 8px;
        background-color: #2096C0;
    }
  '';

  # ── Helix ─────────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;
    settings = {
      theme = "base16_default";
      editor = {
        "line-number" = "relative";
        mouse = true;
        cursorline = true;
        scrolloff = 999;
        "color-modes" = true;
        "auto-save" = false;
        "auto-completion" = true;
        "text-width" = 80;
        "auto-format" = false;
        statusline = {
          left = [ "mode" "file-name" "read-only-indicator" "file-modification-indicator" ];
          right = [ "position-percentage" "position" "file-type" ];
        };
        "soft-wrap" = { enable = true; };
        "cursor-shape" = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        search = { "smart-case" = true; };
      };
      keys.normal."C-p" = "file_picker";
    };
  };

  # ── Neovim ────────────────────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim/init.lua".text = ''
    vim.opt.termguicolors = true
    vim.g.mapleader = " "

    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
      },
    })

    require("mason").setup()
    require("mason-lspconfig").setup({ ensure_installed = { "ts_ls", "svelte" } })

    local cmp = require("cmp")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = { { name = "nvim_lsp" } },
    })

    vim.lsp.config("ts_ls", { capabilities = capabilities })
    vim.lsp.config("svelte", { capabilities = capabilities })
    vim.lsp.enable({ "ts_ls", "svelte" })
  '';

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    ignores = [ "**/.claude/settings.local.json" ];
  };

  # ── MPD ───────────────────────────────────────────────────────────────────
  services.mpd = {
    enable = true;
    musicDirectory = "/home/tiago/MEDIA/MUSIC";
    extraConfig = ''
      audio_output {
          type "pipewire"
          name "PipeWire"
      }
    '';
  };

  # ── Btop ──────────────────────────────────────────────────────────────────
  xdg.configFile."btop/btop.conf".text = ''
    color_theme = "Default"
    theme_background = false
    truecolor = true
    force_tty = false
    vim_keys = true
    disable_mouse = false
    rounded_corners = false
    terminal_sync = true
    graph_symbol = "block"
    graph_symbol_cpu = "default"
    graph_symbol_gpu = "default"
    graph_symbol_mem = "default"
    graph_symbol_net = "default"
    graph_symbol_proc = "default"
    shown_boxes = "cpu mem net proc"
    update_ms = 100
    proc_sorting = "cpu lazy"
    proc_reversed = true
    proc_tree = true
    proc_colors = true
    proc_gradient = true
    proc_per_core = false
    proc_mem_bytes = true
    proc_cpu_graphs = true
    proc_info_smaps = false
    proc_left = false
    proc_filter_kernel = false
    proc_follow_detailed = true
    proc_aggregate = false
    keep_dead_proc_usage = false
    cpu_graph_upper = "Auto"
    cpu_graph_lower = "Auto"
    show_gpu_info = "Auto"
    cpu_invert_lower = true
    cpu_single_graph = false
    cpu_bottom = false
    show_uptime = true
    show_cpu_watts = true
    check_temp = true
    cpu_sensor = "Auto"
    show_coretemp = true
    cpu_core_map = ""
    temp_scale = "celsius"
    base_10_sizes = false
    show_cpu_freq = true
    freq_mode = "first"
    clock_format = "%X"
    background_update = true
    custom_cpu_name = ""
    disks_filter = ""
    mem_graphs = true
    mem_below_net = false
    zfs_arc_cached = true
    show_swap = true
    swap_disk = true
    show_disks = false
    only_physical = true
    use_fstab = true
    zfs_hide_datasets = false
    disk_free_priv = false
    show_io_stat = true
    io_mode = false
    io_graph_combined = false
    io_graph_speeds = ""
    swap_upload_download = false
    net_download = 100
    net_upload = 100
    net_auto = true
    net_sync = true
    net_iface = ""
    base_10_bitrate = "Auto"
    show_battery = true
    selected_battery = "Auto"
    show_battery_watts = true
    log_level = "WARNING"
    save_config_on_exit = true
    nvml_measure_pcie_speeds = true
    rsmi_measure_pcie_speeds = true
    gpu_mirror_graph = true
    shown_gpus = "nvidia amd intel"
  '';

  # ── Dunst ─────────────────────────────────────────────────────────────────
  xdg.configFile."dunst/dunstrc".text = ''
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
        frame_color = "#aaaaaa"
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
        background = "#222222"
        foreground = "#888888"
        timeout = 10
        default_icon = dialog-information

    [urgency_normal]
        background = "#285577"
        foreground = "#ffffff"
        timeout = 10
        override_pause_level = 30
        default_icon = dialog-information

    [urgency_critical]
        background = "#900000"
        foreground = "#ffffff"
        frame_color = "#ff0000"
        timeout = 0
        override_pause_level = 60
        default_icon = dialog-warning
  '';

  # ── Fastfetch ─────────────────────────────────────────────────────────────
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": { "type": "small", "padding": { "top": 1 } },
        "display": { "separator": " " },
        "modules": [
            { "key": "╭───────────╮", "type": "custom" },
            { "key": "│ {#31} user    {#keys}│", "type": "title", "format": "{user-name}" },
            { "key": "│ {#32}󰇅 hname   {#keys}│", "type": "title", "format": "{host-name}" },
            {
                "type": "command",
                "key": "│ {#33}󱦟 os age  {#keys}│",
                "text": "printf \"\\e[0m%s days\\e[0m\" \"$(( ($(date +%s) - $(stat -c %W /)) / 86400 ))\""
            },
            { "key": "│ {#34}󰅐 uptime  {#keys}│", "type": "uptime" },
            { "key": "│ {#34}{icon} distro  {#keys}│", "type": "os" },
            { "key": "│ {#35} kernel  {#keys}│", "type": "kernel" },
            { "key": "│ {#36} wm      {#keys}│", "type": "wm" },
            { "key": "│ {#36}󰇄 desktop {#keys}│", "type": "de" },
            { "key": "│ {#31} term    {#keys}│", "type": "terminal" },
            { "key": "│ {#32} shell   {#keys}│", "type": "shell" },
            { "key": "│ {#33}󰍛 cpu     {#keys}│", "type": "cpu", "showPeCoreCount": true },
            { "key": "│ {#33}󰢮 gpu     {#keys}│", "type": "gpu" },
            { "key": "│ {#34}󰉉 disk    {#keys}│", "type": "disk", "folders": "/" },
            { "key": "│ {#36} memory  {#keys}│", "type": "memory" },
            { "key": "├───────────┤", "type": "custom" },
            { "key": "│ {#39} colors  {#keys}│", "type": "colors", "symbol": "circle" },
            { "key": "╰───────────╯", "type": "custom" }
        ]
    }
  '';

  # ── Fuzzel ────────────────────────────────────────────────────────────────
  # (noctalia theme removed; using fuzzel defaults)
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=Cascadia Code:size=14
    terminal=kitty

    [colors]
    background=0F0F17ff
    text=A1BDCEff
    match=72D792ff
    selection=1E1E2Eff
    selection-text=A1BDCEff
    border=A1BDCE33
  '';

  # ── cmus ──────────────────────────────────────────────────────────────────
  xdg.configFile."cmus/rc".text = ''
    :set softvol=true
    :set repeat_current=false
    :set repeat=true
    :set shuffle=false
    :set follow=true
    :set show_hidden=false
  '';

  # ── Waypaper ──────────────────────────────────────────────────────────────
  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ~/wallpapers
    monitors = All,eDP-1
    wallpaper = ~/wallpapers/Screenshot 2025-09-30 at 01-20-21 Serious Girl Live Wallpaper.png,~/wallpapers/Screenshot 2025-09-30 at 01-20-21 Serious Girl Live Wallpaper.png
    show_path_in_tooltip = True
    backend = swww
    fill = fill
    sort = name
    color = #ffffff
    subfolders = False
    all_subfolders = False
    show_hidden = False
    show_gifs_only = False
    zen_mode = False
    post_command =
    number_of_columns = 3
    swww_transition_type = any
    swww_transition_step = 90
    swww_transition_angle = 0
    swww_transition_duration = 2
    swww_transition_fps = 60
    mpvpaper_sound = False
    mpvpaper_options =
    use_xdg_state = False
  '';

  # ── Yazi ──────────────────────────────────────────────────────────────────
  xdg.configFile."yazi/yazi.toml".text = ''
    [opener]
    image = [{ run = "feh %s", block = false, for = "unix" }]
    pdf   = [{ run = "zathura %s", block = false, for = "unix" }]
    video = [{ run = "mpv --no-terminal %s", block = true, for = "unix" }]
    text  = [{ run = "hx %s", block = true, for = "unix" }]
    play  = [{ run = "mpv --no-terminal %s", block = true, for = "unix" }]

    [open]
    prepend_rules = [
      { mime = "image/*",        use = "image" },
      { mime = "application/pdf", use = "pdf"  },
      { mime = "video/*",        use = "video" },
      { mime = "text/*",         use = "text"  },
      { mime = "audio/opus",     use = "play"  },
      { mime = "audio/mpeg",     use = "play"  },
      { mime = "audio/flac",     use = "play"  },
    ]

    [manager]
    show_hidden = true
    sort_dir_first = true

    [keymap.manager]
    prepend_keymap = [
      { on = "S", run = 'shell --block --confirm "rg --line-number --color=always . | fzf"', desc = "ripgrep + fzf search" },
      { on = "F", run = 'shell --block --confirm "fd . | fzf | xargs -r hx"', desc = "fzf → open in helix" },
    ]
  '';

  # ── MIME apps ─────────────────────────────────────────────────────────────
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf"              = "org.pwmt.zathura-pdf-mupdf.desktop";
      "x-scheme-handler/http"        = "firefox.desktop";
      "x-scheme-handler/https"       = "firefox.desktop";
      "x-scheme-handler/chrome"      = "firefox.desktop";
      "text/html"                    = "firefox.desktop";
      "application/x-extension-htm"  = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/xhtml+xml"        = "firefox.desktop";
      "image/png"                    = "firefox.desktop";
      "image/jpeg"                   = "firefox.desktop";
      "video/mp4"                    = "mpv.desktop";
      "x-scheme-handler/discord"     = "vesktop.desktop";
      "x-scheme-handler/mailto"      = "thunderbird.desktop";
      "message/rfc822"               = "thunderbird.desktop";
    };
    associations.added = {
      "application/pdf"        = [ "firefox.desktop" "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "x-scheme-handler/http"  = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "text/html"              = [ "firefox.desktop" ];
      "application/rss+xml"    = [ "firefox.desktop" ];
    };
  };
}
