status is-interactive; or exit
functions -q fzf_configure_bindings; or exit

# File search on Ctrl+F; Ctrl+Alt+R for fzf history (Ctrl+R is atuin).
fzf_configure_bindings --directory=\cf \
    --history=\e\cr \
    --git_log=\cg \
    --git_status=\cs \
    --processes=\cp
