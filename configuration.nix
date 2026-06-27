# Hardware: Intel i5-10310U, Intel UHD, Wayland/Hyprland, ext4
# Deploy: sudo nixos-rebuild switch --flake .#tiago
{ config, pkgs, pkgs-unstable, planit, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tiago";
  networking.networkmanager.enable = true;

  # OpenSSH server: accept incoming SSH, KEY-ONLY (no password). Opens port 22
  # (openFirewall defaults to true). Authorize client keys declaratively with
  # users.users.tiago.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Keep the fifine as the ONLY microphone: never auto-switch a bluetooth
  # headphone into the headset (HFP/HSP) profile. It stays in A2DP (output only,
  # for music/video), so it never exposes a mic and never steals the default
  # source from the fifine.
  services.pipewire.wireplumber.extraConfig."51-bluez-no-mic" = {
    "monitor.bluez.properties" = {
      "bluez5.autoswitch-profile" = false;
    };
  };

  # Bluetooth — the headphone connects over A2DP for music/video. Experimental
  # enables BLE battery reporting (shown in the waybar audio tooltip via UPower);
  # AutoEnable powers the adapter on boot so trusted devices reconnect.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
      Policy.AutoEnable = true;
    };
  };
  services.blueman.enable = true;

  # UPower daemon: exposes battery info (incl. the bluetooth headphone) over
  # D-Bus, read by the waybar audio module for its tooltip.
  services.upower.enable = true;

  programs.hyprland.enable = true;

  # dconf backs the gsettings keys (color-scheme / gtk-theme) that the
  # theme-switch script sets, and that xdg-desktop-portal exposes to Firefox.
  programs.dconf.enable = true;

  # add PATH
  environment.localBinInPath = true;

  # Display manager — starts Hyprland on login
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --greeting 'gm' --cmd start-hyprland";
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
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
  ];

  users.users.tiago = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "video" ];
    shell = pkgs.bash;
  };

  environment.systemPackages =
  import ./packages.nix { inherit pkgs pkgs-unstable; } ++ [ planit ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
