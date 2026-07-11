{ pkgs, pkgs-unstable }:

with pkgs; [
  git
  vim
  wget
  curl
  gh
  ffmpeg
  pkgs-unstable.yt-dlp
  helix
  zathura
  baobab
  nautilus
  systemd
  audacity
  qbittorrent
  man
  newsboat
  audacious
  aerc
  khard
  openssl
  ani-cli
  rnote
  azpainter
  pkgs-unstable.localsend
  imagemagick
  zed-editor
  go
  gopls
  libresprite
  aseprite

  # ── Moved here from home-manager (2026-07-10) ──────────────────────────────
  # Wayland / Hyprland ecosystem
  swaybg
  hyprpaper
  fuzzel
  grimblast
  cliphist
  wl-clipboard
  waybar

  # Audio / brightness / media control
  pamixer
  pavucontrol
  brightnessctl
  playerctl
  upower
  pulseaudio          # pactl CLI (used by audio-status/toggle-sink scripts)

  # System tools
  udiskie

  # Apps
  firefox
  obsidian
  yazi
  cmus
  fastfetch
  kitty
  neovim
  mpv
  btop
  mpd                 # user service unit lives in ~/.config/systemd/user

  # Notifications
  dunst
  mako
  swaynotificationcenter

  # CLI tools (used by yazi keymaps)
  ripgrep
  fd
  feh
  python3

  # Theming (theme-switch script + cursor)
  glib                      # gsettings
  libnotify                 # notify-send
  gnome-themes-extra        # Adwaita / Adwaita-dark GTK theme
  gsettings-desktop-schemas # org.gnome.desktop.interface schema for gsettings
  nordzy-cursor-theme

  pkgs-unstable.claude-code
]
