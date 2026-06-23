# Hardware: Intel i5-10310U, Intel UHD, Wayland/Hyprland, ext4
# Deploy: sudo nixos-rebuild switch --flake .#tiago
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tiago";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "pt_BR.UTF-8";

  # ABNT2 keyboard for TTY and greeter
  console.keyMap = "br-abnt2";
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  hardware.graphics.enable = true;

  # PipeWire (replaces PulseAudio)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.hyprland.enable = true;

  # add PATH
  environment.localBinInPath = true;

  # Display manager — starts Hyprland on login
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet --time --greeting 'gm' --cmd Hyprland";
  };

  # Drawing tablet
  hardware.opentabletdriver.enable = true;

  # XDG portals for screen sharing, file picker
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    cascadia-code
    (nerdfonts.override { fonts = [ "JetBrainsMono" "CascadiaCode" ]; })
  ];

  users.users.tiago = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "video" ];
    shell = pkgs.bash;
  };

  environment.systemPackages =
  import ./packages.nix { inherit pkgs; };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
