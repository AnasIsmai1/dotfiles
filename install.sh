#!/bin/bash

set -e

is_stow_installed() {
    command -v stow >/dev/null 2>&1
}

install_stow() {
    echo "Stow not found. Attempting to install..."

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v brew >/dev/null 2>&1; then
        brew install stow
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y stow
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm stow
    else
        echo "Unsupported package manager. Please install GNU Stow manually."
        exit 1
    fi
}

if ! is_stow_installed; then
    install_stow
else
    echo "Stow is already installed."
fi

echo "Running: stow ."
stow .
