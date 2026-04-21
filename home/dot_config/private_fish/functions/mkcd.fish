function mkcd --description 'mkdir -p + cd'
    set -l dir $argv[1]
    if test -z "$dir"
        echo "Usage: mkcd <directory>" >&2
        return 1
    end
    mkdir -p -- $dir; and cd -- $dir
end
