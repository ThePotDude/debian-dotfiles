# debian-dotfiles

Personal collection of configuration files for a Sway desktop Catppuccin-inspired rice on Debian, or for any other imperative distro.

## Contents

| Folder     | Purpose                                  |
|------------|-------------------------------------------|
| alacritty  | Terminal emulator configuration           |
| gtk-3.0    | GTK 3 theme and appearance settings       |
| gtk-4.0    | GTK 4 theme and appearance settings       |
| sway       | Sway window manager configuration         |
| waybar     | Status bar configuration                  |
| wofi       | Application launcher configuration        |
| tlp.conf   | Power management configuration (TLP)      |

## Requirements

These configs assume the following are already installed:

- sway
- waybar
- wofi
- swaybg (paste your preferred wallpaper in ~/Pictures/)
- alacritty
- tlp (only needed if you plan to use tlp.conf)
- smartmontools (optional if using tlp)

The GTK configs also reference the following theme, icon theme, and cursor theme.
None of these are installed automatically. See the Themes section below.

- Catppuccin Macchiato Mauve (GTK theme)
- Tela Circle (icon theme)
- Bibata Modern Classic (cursor theme)

## Installation

Clone the repository:

```
git clone https://github.com/ThePotDude/debian-dotfiles.git
cd debian-dotfiles
```

Run the install script to symlink the configs into place:

```
./install.sh
```

This will back up any existing configuration files before creating symlinks.

Note: `install.sh` does not touch `tlp.conf`. TLP configuration affects system-wide power
management, so it is left out of the automated install on purpose. See the section below
if you want to use it.

## Applying tlp.conf manually

Heavily personal and opinionated configuration, tuned exactly for my hardware. TLP configuration lives in `/etc/tlp.conf` and requires root privileges. Review the file
first, then copy it manually:

```
sudo cp tlp.conf /etc/tlp.conf
sudo systemctl restart tlp
```

## Themes

The `gtk-3.0` and `gtk-4.0` configs point to specific theme, icon, and cursor packages.
These are not installed by `install.sh` and must be installed manually.

### Catppuccin Macchiato Mauve (GTK theme)

Source: https://github.com/catppuccin/gtk

Download or build the `catppuccin-macchiato-mauve-standard+default` release and place it in
`~/.themes/`.

### Tela Circle (icon theme)

Source: https://github.com/vinceliuice/Tela-icon-theme

Clone the repository and run their install script with the circle flag:

```
git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme
./install.sh -c
```

This installs the `Tela-circle` icon theme into `~/.local/share/icons/` or `~/.icons/`.

### Bibata Modern Classic (cursor theme)

Source: https://github.com/ful1e5/Bibata_Cursor

Download the `Bibata-Modern-Classic` release and place it in `~/.icons/`.

After installing all three, log out and back in (or restart Sway) for the changes to apply.

## Uninstalling

To remove the symlinks created by install.sh, delete them from your `~/.config` directory
and restore your backups if needed. Backups are created with a `.bak` suffix in the same
location as the original file.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
