# homebrew
# https://github.com/orgs/Homebrew/discussions/4412#discussioncomment-8651316
if test -d /home/linuxbrew/.linuxbrew # Linux
	set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
	set -gx HOMEBREW_PREFIX "/opt/homebrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end
if test -d "$HOMEBREW_PREFIX"
	fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin";
	! set -q MANPATH; and set MANPATH ''; set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH;
	! set -q INFOPATH; and set INFOPATH ''; set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH;
end


if status is-interactive
    # source tools
    zoxide init fish | source
    atuin init fish --disable-up-arrow | source
    ## fzf.fish plugin is installed, so no need to source it
    # fzf --fish | source

    # git abbreviations
    abbr --add "g" "git"
    abbr --add "ga" "git add"
    abbr --add "gc" "git commit"
    abbr --add "gcl" "git clone"
    abbr --add --set-cursor "gcm" "git commit -m \"%\"" 
    abbr --add "gco" "git checkout"
    abbr --add "gpl" "git pull"
    abbr --add "gps" "git push"
    abbr --add "gs" "git status"
    abbr --add "gsw" "git switch"

    # eza
    abbr --add "e" "eza"

    # format help with bat
    abbr --add --position anywhere -- "--help" "--help | bat --language=help --style=plain"
    abbr --add --position anywhere -- "-h" "-h | bat --language=help --style=plain"

    # replacements for common commands
    abbr --add "cat" "bat"
    abbr --add "cd" "z"
    abbr --add "find" "fd"
    abbr --add "grep" "rg"
    abbr --add "ls" "eza"

    # macOS specific abbreviations
    if test (uname) = "Darwin"
        abbr --add "o" "open"
        abbr --add "pbc" "pbcopy"
    end

    # helper functions
    function mkcd
        set -l dir $argv[1]
        if test -z "$dir"
            echo "Usage: mkcd <directory>"
            return 1
        end
        mkdir -p $dir
        cd $dir
    end
end
