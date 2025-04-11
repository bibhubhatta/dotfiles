#!/bin/bash

set -eufo pipefail

# Install eget
if ! command -v eget &> /dev/null; then
    echo "Installing eget..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://zyedidia.github.io/eget.sh | bash
    ./eget zyedidia/eget --to /usr/local/bin/eget
    rm ./eget
else
    echo "eget is already installed"
fi

# Install go tools
eget --upgrade-only FiloSottile/age --to /usr/local/bin/age
eget --upgrade-only boyter/scc --to /usr/local/bin/scc
eget --upgrade-only cli/cli --to /usr/local/bin/gh
eget --upgrade-only getsops/sops --to /usr/local/bin/sops
eget --upgrade-only jesseduffield/lazydocker --to /usr/local/bin/lazydocker
eget --upgrade-only jesseduffield/lazygit --to /usr/local/bin/lazygit
eget --upgrade-only junegunn/fzf --to /usr/local/bin/fzf
eget --upgrade-only muesli/duf --to /usr/local/bin/duf
eget --upgrade-only nektos/act --to /usr/local/bin/act
eget --upgrade-only simonwhitaker/gibo --to /usr/local/bin/gibo
eget --upgrade-only twpayne/chezmoi --to /usr/local/bin/chezmoi
