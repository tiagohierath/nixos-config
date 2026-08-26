# Hardware: Intel i5-10310U, Intel UHD, Wayland/Hyprland, ext4
# Deploy: sudo nixos-rebuild switch --flake .#tiago
{ config, pkgs, pkgs-unstable, pkgs-aseprite, planit, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = "weekly";
  };

  # MyPaint 2.0.1 crashes on startup with pygobject >= 3.51: plain (non-GType)
  # GLib enums like GLib.UserDirectory no longer have .value_name. Only used
  # in a debug log line, so log the enum itself instead.
  nixpkgs.overlays = [
    (final: prev: {
      mypaint = prev.mypaint.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace lib/glib.py --replace-fail "k.value_name," "k,"
        '';
      });
    })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Early KMS: GPU driver loads in the initrd, so console/greeter come up at
  # native resolution instead of after the root switch
  boot.initrd.kernelModules = [ "i915" ];

  # ext4 defaults to relatime, which writes metadata on reads; noatime skips
  # that (merges into the fileSystems."/" from hardware-configuration.nix)
  fileSystems."/".options = [ "noatime" ];

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
  i18n.defaultLocale = "en_US.UTF-8";

  # ABNT2 keyboard for TTY and greeter
  console.keyMap = "br-abnt2";
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # VA-API hardware video decode/encode on the UHD 620 (iHD driver). mpv picks
  # it up with hwdec=auto-safe; Firefox needs media.ffmpeg.vaapi.enabled=true.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  # Proactive thermal management for the U-series CPU — keeps sustained clocks
  # higher under load instead of hitting firmware throttle cliffs
  services.thermald.enable = true;

  # Energy profiles (power-saver / balanced / performance), switched with the
  # p1/p2/p3 bash aliases (see home/tiago.nix) or powerprofilesctl directly
  services.power-profiles-daemon.enable = true;

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

  # gvfs backs Nautilus's virtual filesystems: trash://, MTP, network mounts.
  # Without it "Move to Trash" is missing/greyed out in the file manager.
  services.gvfs.enable = true;

  programs.hyprland.enable = true;
  # Keep Hyprland available while adding Niri as an alternative scrolling
  # session. tuigreet lets the user choose either one at login.
  programs.niri.enable = true;

  # dconf backs the gsettings keys (color-scheme / gtk-theme) that the
  # theme-switch script sets, and that xdg-desktop-portal exposes to Firefox.
  programs.dconf.enable = true;

  # Expose gsettings schemas at /run/current-system/sw/share/gsettings-schemas
  # so ~/.local/bin/theme-switch can put them on XDG_DATA_DIRS (gsettings
  # errors with "No such schema" otherwise).
  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # add PATH
  environment.localBinInPath = true;

  # Display manager — boot into Niri by default; F3 can still select Hyprland.
  # Keep remembering the username, but do not let the last selected compositor
  # override Niri on the next boot.
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --greeting 'gm' --remember --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd niri-session";
  };
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter -"
  ];

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
  import ./packages.nix { inherit pkgs pkgs-unstable pkgs-aseprite; } ++ [ planit ];

  # Auto shutdown at 9pm: one root service handles warnings, the
  # cancellation check, and the final poweroff. Touch
  # /run/user/1000/shutdown-cancel any time before 9pm to cancel that
  # night's shutdown. Notify failures (e.g. no active session) must
  # not block the poweroff, hence the `|| true`.
  systemd.services.nightly-shutdown = {
    description = "Warn, then power off the machine at 9pm (cancellable)";
    serviceConfig.Type = "oneshot";
    script = ''
      cancel_flag=/run/user/1000/shutdown-cancel
      start_epoch=$(date +%s)
      max_drift=300

      notify() {
        ${pkgs.util-linux}/bin/runuser -u tiago -- \
          env XDG_RUNTIME_DIR=/run/user/1000 \
              DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
              ${pkgs.libnotify}/bin/notify-send "$1" || true
      }
      check_cancel() {
        if [ -e "$cancel_flag" ]; then
          notify "Shutdown cancelled"
          rm -f "$cancel_flag"
          exit 0
        fi
      }
      # Bail out (no notify, no poweroff) if the wall clock has
      # jumped further than expected since we started, which happens
      # when the machine was suspended (lid closed) mid-sequence and
      # only just woke up. This stops a lid reopen at 2am from
      # triggering the sequence hours late.
      check_drift() {
        expected=$1
        now=$(date +%s)
        elapsed=$((now - start_epoch))
        diff=$((elapsed - expected))
        [ "$diff" -lt 0 ] && diff=$((-diff))
        if [ "$diff" -gt "$max_drift" ]; then
          exit 0
        fi
      }
      # Bail if the current time-of-day has drifted outside the
      # shutdown window. `sleep` pauses during suspend and resumes
      # counting on wake, so check_drift's elapsed-time math alone
      # can't reliably catch a suspend that spans into the next
      # morning: a resume timed just right can still land within
      # the expected drift budget and let the sequence complete
      # while you're back at the machine. Re-validate the actual
      # clock at every stage, not just total elapsed time.
      check_window() {
        now_hm=$((10#$(date +%H%M)))
        if [ "$now_hm" -lt 2025 ] || [ "$now_hm" -gt 2110 ]; then
          exit 0
        fi
      }
      check_window

      notify "Shutdown in 30 minutes (touch $cancel_flag to cancel)"
      sleep 900
      check_drift 900
      check_window
      check_cancel
      notify "Shutdown in 15 minutes"
      sleep 840
      check_drift 1740
      check_window
      check_cancel
      notify "Shutdown in 1 minute"
      sleep 60
      check_drift 1800
      check_window
      check_cancel

      systemctl poweroff
    '';
  };

  systemd.timers.nightly-shutdown = {
    description = "Trigger nightly-shutdown at 8:30pm";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 20:30:00";
      Persistent = false;
    };
  };

  # Sunset dimming: at 7pm, switch to dark theme (waybar, wallpaper,
  # GTK, kitty, etc. via theme-switch, same as Super+I) and drop the
  # backlight to its lowest usable level. theme-switch needs the
  # user's Wayland/D-Bus session env to reach hyprctl/gsettings/waybar.
  systemd.services.sunset-dim = {
    description = "Switch to dark theme and dim screen at sunset";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.util-linux pkgs.procps pkgs.gnugrep pkgs.gawk ];
    script = ''
      hypr_pid=$(pgrep -x Hyprland | head -1)
      if [ -n "$hypr_pid" ]; then
        wayland_display=$(tr '\0' '\n' < /proc/$hypr_pid/environ | grep -m1 '^WAYLAND_DISPLAY=' | cut -d= -f2-)
        hypr_sig=$(tr '\0' '\n' < /proc/$hypr_pid/environ | grep -m1 '^HYPRLAND_INSTANCE_SIGNATURE=' | cut -d= -f2-)
        runuser -u tiago -- \
          env XDG_RUNTIME_DIR=/run/user/1000 \
              WAYLAND_DISPLAY="$wayland_display" \
              HYPRLAND_INSTANCE_SIGNATURE="$hypr_sig" \
              DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
              /home/tiago/.local/bin/theme-switch dark || true
      fi
      ${pkgs.brightnessctl}/bin/brightnessctl set 1%
    '';
  };

  systemd.timers.sunset-dim = {
    description = "Trigger sunset-dim at 7pm";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 19:00:00";
      Persistent = false;
    };
  };

  # Morning reset: undo sunset-dim so the screen isn't stuck dark,
  # whether the laptop stayed on overnight or was rebooted (NixOS's
  # systemd-backlight service would otherwise restore the dimmed
  # level on every boot).
  systemd.services.sunrise-brighten = {
    description = "Switch to light theme and restore full brightness in the morning";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.util-linux pkgs.procps pkgs.gnugrep pkgs.gawk ];
    script = ''
      ${pkgs.brightnessctl}/bin/brightnessctl set 100%
      hypr_pid=$(pgrep -x Hyprland | head -1)
      if [ -n "$hypr_pid" ]; then
        wayland_display=$(tr '\0' '\n' < /proc/$hypr_pid/environ | grep -m1 '^WAYLAND_DISPLAY=' | cut -d= -f2-)
        hypr_sig=$(tr '\0' '\n' < /proc/$hypr_pid/environ | grep -m1 '^HYPRLAND_INSTANCE_SIGNATURE=' | cut -d= -f2-)
        runuser -u tiago -- \
          env XDG_RUNTIME_DIR=/run/user/1000 \
              WAYLAND_DISPLAY="$wayland_display" \
              HYPRLAND_INSTANCE_SIGNATURE="$hypr_sig" \
              DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
              /home/tiago/.local/bin/theme-switch light || true
      fi
    '';
  };

  systemd.timers.sunrise-brighten = {
    description = "Trigger sunrise-brighten at 7am";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 07:00:00";
      Persistent = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
