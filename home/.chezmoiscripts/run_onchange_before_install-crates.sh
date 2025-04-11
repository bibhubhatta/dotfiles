#!/bin/bash

set -eufo pipefail

echo "Checking for Rust installation..."
if ! command -v cargo &> /dev/null; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo "Rust is already installed"
fi
# shellcheck source=/dev/null
source "$HOME/.cargo/env"

echo "Installing cargo-binstall..."
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

echo "Installing crates..."
cargo binstall -y \
    bandwhich \
    bat \
    broot \
    cargo-binstall \
    du-dust \
    dua-cli \
    erdtree \
    eza \
    fd-find \
    git-delta \
    gping \
    grex \
    just \
    mise \
    mprocs \
    ouch \
    procs \
    ripgrep \
    sd \
    starship \
    tealdeer \
    topgrade \
    yazi-cli \
    yazi-fm \
    zellij \
    zoxide
