# debian-dotfiles

Personal collection of configuration files for a Sway desktop on Debian. Catppuccin Mauve themed.

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
- alacritty
- tlp (only needed if you plan to use tlp.conf)

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

TLP configuration lives in `/etc/tlp.conf` and requires root privileges. Review the file
first, then copy it manually:

```
sudo cp tlp.conf /etc/tlp.conf
sudo systemctl restart tlp
```

## Uninstalling

To remove the symlinks created by install.sh, delete them from your `~/.config` directory
and restore your backups if needed. Backups are created with a `.bak` suffix in the same
location as the original file.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
