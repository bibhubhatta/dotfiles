#!/bin/bash

set -eufo pipefail

echo "Installing rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
    dua-cli \
    du-dust \
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
    yazi-cli \
    yazi-fm \
    zellij \
    zoxide
