status is-interactive; or exit
type -q bat; or exit

abbr --add --position anywhere -- --help "--help | bat --language=help --style=plain"
abbr --add --position anywhere -- -h "-h | bat --language=help --style=plain"
abbr --add --set-cursor man "man % | bat --language=man --style=plain"
