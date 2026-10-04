#!/usr/bin/env bash
#
# install.sh
#
# Sets up this dotfiles repo on a fresh machine:
#   - Symlinks config folders into ~/.config
#   - Makes the wofi power menu script(s) executable
#   - Installs the Mojave-Dark-solid GTK theme, Kora icons and Mojave cursors
#   - Installs TLP and copies tlp.conf into /etc/tlp.conf (needs sudo)
#
# Safe to re-run: existing symlinks are replaced, real folders are backed up.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
THEMES_DIR="${HOME}/.themes"
ICONS_DIR="${HOME}/.local/share/icons"
BUILD_DIR="$(mktemp -d)"

# Always clean up the temp build directory, even if something fails
trap 'rm -rf "${BUILD_DIR}"' EXIT

FOLDERS=(
    "alacritty"
    "fastfetch"
    "gtk-3.0"
    "gtk-4.0"
    "sway"
    "waybar"
    "wofi"
)


# Helpers

info() { printf '\033[0;36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m ok\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m !!\033[0m %s\n' "$*"; }

# Detect the package manager once so the rest of the script can use it
detect_pkg_manager() {
    if   command -v pacman  >/dev/null 2>&1; then echo "pacman"
    elif command -v apt-get >/dev/null 2>&1; then echo "apt"
    elif command -v dnf     >/dev/null 2>&1; then echo "dnf"
    else echo "unknown"
    fi
}

PKG_MANAGER="$(detect_pkg_manager)"

# install_packages <arch-names> <debian-names> <fedora-names>
# Each argument is a space separated list of package names for that distro.
install_packages() {
    local arch_pkgs="$1" apt_pkgs="$2" dnf_pkgs="$3"

    case "${PKG_MANAGER}" in
        pacman) sudo pacman -S --needed --noconfirm ${arch_pkgs} ;;
        apt)    sudo apt-get install -y ${apt_pkgs} ;;
        dnf)    sudo dnf install -y ${dnf_pkgs} ;;
        *)
            warn "Unknown package manager. Please install manually: ${arch_pkgs}"
            return 1
            ;;
    esac
}

# Clone a repo shallowly into the temp build dir and print its path
clone_repo() {
    local url="$1" name="$2"
    git clone --depth=1 --quiet "${url}" "${BUILD_DIR}/${name}"
    echo "${BUILD_DIR}/${name}"
}

# 1. Symlink config folders

link_configs() {
    info "Linking config folders into ${CONFIG_DIR}"
    mkdir -p "${CONFIG_DIR}"

    local folder source target backup
    for folder in "${FOLDERS[@]}"; do
        source="${REPO_DIR}/${folder}"
        target="${CONFIG_DIR}/${folder}"

        if [ ! -d "${source}" ]; then
            warn "Skipping ${folder}: not found in repository"
            continue
        fi

        if [ -L "${target}" ]; then
            rm "${target}"
        elif [ -e "${target}" ]; then
            backup="${target}.bak"
            # Don't clobber an older backup
            if [ -e "${backup}" ]; then
                backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
            fi
            warn "Backing up existing ${folder} to ${backup}"
            mv "${target}" "${backup}"
        fi

        ln -s "${source}" "${target}"
        ok "${folder} -> ${target}"
    done
}

# 2. Make wofi scripts executable (power menu etc.)

make_wofi_scripts_executable() {
    info "Making wofi scripts executable"

    if [ ! -d "${REPO_DIR}/wofi" ]; then
        warn "No wofi folder found, skipping"
        return
    fi

    local count=0 script
    while IFS= read -r -d '' script; do
        chmod +x "${script}"
        ok "chmod +x ${script#"${REPO_DIR}/"}"
        count=$((count + 1))
    done < <(find "${REPO_DIR}/wofi" -type f \( -name '*.sh' -o -name '*.bash' \) -print0)

    if [ "${count}" -eq 0 ]; then
        warn "No .sh files found in wofi/"
    fi
}

# 3. Themes: GTK, icons, cursors

install_gtk_theme() {
    info "Installing Mojave-Dark-solid GTK theme"

    if [ -d "${THEMES_DIR}/Mojave-Dark-solid" ]; then
        ok "Mojave-Dark-solid already installed, skipping"
        return
    fi

    # Build dependencies for the theme's installer (needs sassc to compile)
    install_packages \
        "git sassc glib2 libxml2" \
        "git sassc libglib2.0-dev-bin libxml2-utils" \
        "git sassc glib2-devel libxml2" \
        || warn "Could not install build dependencies, the build may fail"

    local dir
    dir="$(clone_repo https://github.com/vinceliuice/Mojave-gtk-theme.git Mojave-gtk-theme)"

    mkdir -p "${THEMES_DIR}"
    # -c dark = Dark variant, -o solid = solid (non-transparent) variant
    (cd "${dir}" && ./install.sh -d "${THEMES_DIR}" -c dark -o solid)
    ok "Installed to ${THEMES_DIR}"
}

install_icon_theme() {
    info "Installing Kora icon theme"

    if [ -d "${ICONS_DIR}/kora" ]; then
        ok "Kora already installed, skipping"
        return
    fi

    local dir
    dir="$(clone_repo https://github.com/bikass/kora.git kora)"

    mkdir -p "${ICONS_DIR}"
    # The repo contains the "kora" folder (and "kora-pgrey" for grey folders)
    cp -r "${dir}/kora" "${ICONS_DIR}/"
    if [ -d "${dir}/kora-pgrey" ]; then
        cp -r "${dir}/kora-pgrey" "${ICONS_DIR}/"
    fi

    gtk-update-icon-cache -f -t "${ICONS_DIR}/kora" 2>/dev/null || true
    ok "Installed to ${ICONS_DIR}"
}

install_cursor_theme() {
    info "Installing Mojave cursors"

    # The upstream project is called McMojave-cursors and installs as
    # "McMojave Cursors".
    if [ -d "${ICONS_DIR}/McMojave-cursors" ]; then
        ok "Mojave cursors already installed, skipping"
        return
    fi

    local dir
    dir="$(clone_repo https://github.com/vinceliuice/McMojave-cursors.git McMojave-cursors)"

    mkdir -p "${ICONS_DIR}"
    # Run without sudo so it installs for the local user
    (cd "${dir}" && ./install.sh)
    ok "Installed to ${ICONS_DIR}"
}

# 4. TLP

install_tlp() {
    info "Installing TLP"

    if ! command -v tlp >/dev/null 2>&1; then
        install_packages "tlp" "tlp" "tlp" || {
            warn "TLP installation failed, skipping TLP setup"
            return
        }
    else
        ok "TLP already installed"
    fi

    # Copy the config, backing up any existing one first
    if [ -f "${REPO_DIR}/tlp.conf" ]; then
        if [ -f /etc/tlp.conf ]; then
            sudo cp /etc/tlp.conf "/etc/tlp.conf.bak"
            warn "Existing /etc/tlp.conf backed up to /etc/tlp.conf.bak"
        fi
        sudo cp "${REPO_DIR}/tlp.conf" /etc/tlp.conf
        ok "Copied tlp.conf to /etc/tlp.conf"
    else
        warn "No tlp.conf in repository, using TLP defaults"
    fi

    # systemd-based distros: start now and on boot
    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl enable --now tlp.service
        # TLP conflicts with power-profiles-daemon, so mask it if present
        if systemctl list-unit-files 2>/dev/null | grep -q '^power-profiles-daemon'; then
            warn "Masking power-profiles-daemon (conflicts with TLP)"
            sudo systemctl mask power-profiles-daemon.service
        fi
    fi

    # Apply the config immediately
    sudo tlp start >/dev/null 2>&1 || true
}

# Main

main() {
    echo "Installing dotfiles from ${REPO_DIR}"
    echo "Detected package manager: ${PKG_MANAGER}"
    echo ""

    if [ "${EUID}" -eq 0 ]; then
        warn "Don't run this as root. It uses sudo only where needed."
        exit 1
    fi

    link_configs
    echo ""
    make_wofi_scripts_executable
    echo ""
    install_gtk_theme
    echo ""
    install_icon_theme
    echo ""
    install_cursor_theme
    echo ""
    install_tlp
    echo ""

    info "Done."
    echo "Theme names to use in your configs:"
    echo "  GTK theme:    Mojave-Dark-solid"
    echo "  Icon theme:   kora"
    echo "  Cursor theme: McMojave Cursors"
}

main "$@"
