#!/bin/bash

set -eufo pipefail

echo "Checking for Rust installation..."
if ! command -v cargo &>/dev/null; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
else
    echo "Rust is already installed"
fi

echo "Installing cargo-binstall..."
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

echo "Installing crates..."
cargo binstall \
    --no-confirm \
    --disable-strategies compile \
    --continue-on-failure \
    bandwhich \
    bat \
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

echo "Installing crates that don't work well with cargo-binstall..."
curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
