#!/usr/bin/env bash
#
# install.sh
#
# Symlinks this repository's config folders into ~/.config
# Does NOT touch tlp.conf. That file affects system-wide power management
# My first attempt at making a bash file.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"

FOLDERS=(
    "alacritty"
    "gtk-3.0"
    "gtk-4.0"
    "sway"
    "waybar"
    "wofi"
)

mkdir -p "${CONFIG_DIR}"

echo "Installing dotfiles from ${REPO_DIR}"
echo "Target directory: ${CONFIG_DIR}"
echo ""

for folder in "${FOLDERS[@]}"; do
    SOURCE="${REPO_DIR}/${folder}"
    TARGET="${CONFIG_DIR}/${folder}"

    if [ ! -d "${SOURCE}" ]; then
        echo "Skipping ${folder}: not found in repository"
        continue
    fi

    if [ -L "${TARGET}" ]; then
        echo "Removing existing symlink: ${TARGET}"
        rm "${TARGET}"
    elif [ -e "${TARGET}" ]; then
        BACKUP="${TARGET}.bak"
        echo "Backing up existing ${folder} to ${BACKUP}"
        mv "${TARGET}" "${BACKUP}"
    fi

    ln -s "${SOURCE}" "${TARGET}"
    echo "Linked ${folder} -> ${TARGET}"
done

echo ""
echo "Done."
echo "Note: tlp.conf was not installed. It requires manual setup with root, just paste it yourself in /etc/."
