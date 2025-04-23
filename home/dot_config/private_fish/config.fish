if status is-interactive
    fish_vi_key_bindings
    # git abbreviations
    abbr --add "g" "git"
    abbr --add "ga" "git add"
    abbr --add "gc" "git commit"
    abbr --add "gcl" "git clone"
    abbr --add "gcm" "git commit -m"
    abbr --add "gco" "git checkout"
    abbr --add "gpl" "git pull"
    abbr --add "gps" "git push"
    abbr --add "gs" "git status"
    abbr --add "gsw" "git switch"
end
