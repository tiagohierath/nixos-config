# NixOS Config — Notes

Repo: `/etc/nixos` (git, remote `git@github.com:tiagohierath/nixos-config.git`, branch `main`).
**Everything is declarative. Never configure imperatively.** No `nix-env -i`, no hand-edited
dotfiles in `~/.config` (Home Manager owns them). Change the `.nix` files, then rebuild.

## How it's wired (flakes)

- **`flake.nix`** — entry point.
  - Inputs: `nixpkgs` (release `nixos-24.11`), `nixpkgs-unstable` (`nixos-unstable`),
    `home-manager` (`release-24.11`, follows `nixpkgs`).
  - Builds `pkgs-unstable` as a separate import with `allowUnfree = true`, passes it down
    via `specialArgs` (system) and `home-manager.extraSpecialArgs` (HM). This is the pattern
    for pulling individual packages from unstable while staying on 24.11 (e.g. `claude-code`,
    `yt-dlp`).
  - Single host: `nixosConfigurations.tiago` (system `x86_64-linux`).
  - Home Manager runs as a NixOS module: `useGlobalPkgs`, `useUserPackages`,
    `backupFileExtension = "bak"`, user `tiago` →
    `imports = [ ./home/tiago.nix ./theme.nix ]`.
- **`flake.lock`** — pins all three inputs. Update with `nix flake update` (or `update <input>`).

## Deploy / rebuild

```
cd /etc/nixos
sudo nixos-rebuild switch --flake .#tiago
```
(Host attr is `tiago`.) After changing inputs, `nix flake update` first.

## File map

- `configuration.nix` — system config. Imports `hardware-configuration.nix`. System packages
  come from `import ./packages.nix { inherit pkgs pkgs-unstable; }`.
- `packages.nix` — function `{ pkgs, pkgs-unstable }:` returning a system package list.
- `hardware-configuration.nix` — generated, **do not edit** (ext4 root, vfat /boot, swap, intel).
- `home/tiago.nix` — Home Manager: user packages + all program/dotfile config (large file).

## System (configuration.nix) highlights

- Hardware: Intel i5-10310U, Intel UHD graphics, Wayland.
- `nix.settings.experimental-features = [ "nix-command" "flakes" ]`.
- Boot: `systemd-boot` + EFI.
- Networking: NetworkManager, hostname `tiago`.
- Locale: timezone `America/Sao_Paulo`, locale `pt_BR.UTF-8`, `LC_TIME` pt_BR.
- Keyboard: ABNT2 (`console.keyMap = br-abnt2`, xkb `br`/`abnt2`).
- Audio: **PipeWire** (PulseAudio disabled), rtkit, ALSA + 32-bit + pulse compat.
- `programs.hyprland.enable = true` (Wayland compositor).
- Login: **greetd + tuigreet** starts Hyprland (no graphical DM).
- `hardware.opentabletdriver.enable` (drawing tablet).
- xdg portals: gtk portal for screensharing/file picker.
- Fonts: cascadia-code, nerdfonts (JetBrainsMono, CascadiaCode).
- User `tiago`: normal user, groups wheel/networkmanager/input/video, shell bash.
- `allowUnfree = true`; `system.stateVersion = "24.11"` (don't change casually).

## System packages (packages.nix)

git, vim, wget, curl, gh, ffmpeg, yt-dlp, helix, zathura, baobab, nautilus, systemd,
audacity, qbittorrent, man, aerc, newsboat, audacious, and `pkgs-unstable.claude-code`.

## Home Manager (home/tiago.nix) highlights

- `home.stateVersion = "24.11"`. sessionVariables for hyprcursor; sessionPath adds
  `~/.local/bin`. `programs.bash` also exports it via initExtra.
- **Packages**: Wayland/Hypr (swww, hyprpaper, fuzzel, grimblast, cliphist, wl-clipboard),
  media/brightness (pamixer, brightnessctl, playerctl), udiskie, waypaper, firefox, obsidian,
  yazi, cmus, fastfetch, dunst, mako, swaynotificationcenter, ripgrep, fd, feh, curl,
  `pkgs-unstable.claude-code`.
- **Hyprland** (`wayland.windowManager.hyprland`, big `extraConfig`):
  - Monitors: eDP-1 preferred; HDMI mirror of eDP-1 at 0.8 scale.
  - mainMod = SUPER. Terminal kitty, file mgr yazi, browser firefox, menu/launcher fuzzel.
  - Workspaces bound to H/J/K/L (1-4); SHIFT+ moves window. caps:swapescape. br/abnt2 input.
  - Animations & blur disabled, gaps 3/7, dwindle layout, rounding 7.
  - exec-once: mako, udiskie, firefox, waybar, opentabletdriver, swww-daemon + wallpaper,
    cliphist watcher, dunst, mpv Windows-7 startup sound.
  - Custom binds: SUPER+S sats notify, SUPER+T cliphist picker, SUPER+Print grimblast area.
- Managed program configs (all declarative via HM modules / `xdg.configFile`):
  - **kitty** (Cascadia Code 14, Catppuccin Latte inline; extra Asuka theme file).
  - **waybar** — enabled; full `config` + `style.css` written via xdg.configFile
    (custom bitcoin price, wttr.in weather for Espírito Santo do Pinhal, etc).
  - **helix** (gruvbox_dark_soft, relative lines, soft-wrap, C-p file picker).
  - **neovim** (defaultEditor; init.lua bootstraps lazy.nvim + mason + nvim-cmp, ts_ls/svelte
    LSP — note: this pulls plugins imperatively at runtime via lazy.nvim, not pure Nix).
  - **mpv** (loop inf), **yt-dlp** (unstable pkg), **zathura** (best-fit, fullscreen on f),
    **git** (ignores `**/.claude/settings.local.json`), **mpd** (PipeWire out,
    musicDirectory `/home/tiago/MEDIA/MUSIC`).
  - xdg.configFile for: hypridle, hyprpaper, btop, dunst, fuzzel, cmus, waypaper, yazi.
  - **yazi**: openers (feh/zathura/mpv/hx), show_hidden, ripgrep+fzf (S) and fd→helix (F) binds.
  - **xdg.mimeApps**: defaults — pdf→zathura, web/http(s)/html→firefox, mp4→mpv,
    discord→vesktop, mailto/rfc822→thunderbird. (Note: vesktop/thunderbird referenced in
    mime defaults but not in any package list — declared handlers without installed apps.)

## Theming — light/dark switch (`theme.nix`)

Declarative gruvbox **medium** light/dark, toggled with **Super+i** (`theme-switch toggle`).
Both palettes live in `theme.nix`; per-app theme files are built into the store, and a tiny
runtime selection (state file + a few toggle-owned symlinks) picks which is live. **No pywal** —
it can't coexist with HM owning the dotfiles; this gives the same result declaratively.

- `theme-switch [toggle|dark|light|login]` (a `writeShellScriptBin` on PATH).
  - State: `~/.local/state/theme/mode`. `home.activation.themeInit` seeds it (default `dark`)
    and creates the toggle-owned symlinks so apps start themed on first boot.
  - `login` (hyprland `exec-once`) only applies what boot can't: wallpaper, GTK/portal
    scheme, hyprland borders — it does **not** restart the bars (no flash).
- How each app switches: **kitty** `include current-theme.conf` + `SIGUSR1`; **waybar**
  `style.css` symlink + restart; **dunst** `dunstrc` symlink + `dunstctl reload`; **helix**
  `theme = "current"` → symlinked inheriting theme; **fuzzel/mpv/btop** symlink, next launch;
  **hyprland** borders via `hyprctl keyword`; **GTK/Firefox** via `gsettings`
  `color-scheme`/`gtk-theme` (needs `programs.dconf.enable` in configuration.nix).
- `theme.nix` overrides `tiago.nix` rather than editing it: disables the old single-mode files
  with `xdg.configFile.<f>.enable = mkForce false`, `mkForce`s the helix theme, appends the
  kitty include / mpv include / hyprland binds. So the themed bits in `tiago.nix` are now dead.
- Wallpaper: dark = `~/projects/wallpaper1.png` (hyprland's own `exec-once`), light =
  `~/projects/wallpaper3.png`.

## Gotchas / observations

- Mixed stable/unstable via `pkgs-unstable` passed through specialArgs — the intended way to
  cherry-pick newer packages.
- `hardware-configuration.nix` is auto-generated; never hand-edit.
- neovim's lazy.nvim/mason setup is the one non-pure escape hatch (downloads at runtime).
- A few mime handlers (vesktop, thunderbird) point to apps not declared in packages.
