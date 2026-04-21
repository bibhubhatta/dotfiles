status is-interactive; or exit

type -q bat; and abbr --add cat bat
type -q fd; and abbr --add find fd
type -q rg; and abbr --add grep rg

if type -q eza
    abbr --add ls eza
    abbr --add e eza
    abbr --add ee "eza --all --long --git"
end
