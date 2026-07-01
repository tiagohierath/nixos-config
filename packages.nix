{ pkgs, pkgs-unstable }:

with pkgs; [
  git
  vim
  wget
  curl
  gh
  ffmpeg
  yt-dlp
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
  mypaint
  pkgs-unstable.claude-code
]

