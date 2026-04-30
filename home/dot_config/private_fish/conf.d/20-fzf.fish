status is-interactive; or exit
type -q fzf; or exit

# Stands in for the conf.d/fzf.fish of PatrickF1/fzf.fish v11.0. Its functions/ and
# completions/ files are vendored unchanged, so upgrading is a copy from upstream.

# Read before _fzf_search_variables runs so it sees the shell's variables as they are.
set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'

# File search on Ctrl+F; Ctrl+Alt+R for fzf history, so Ctrl+R stays with atuin (20-tool-init.fish).
fzf_configure_bindings --directory=\cf \
    --history=\e\cr \
    --git_log=\cg \
    --git_status=\cs \
    --processes=\cp
