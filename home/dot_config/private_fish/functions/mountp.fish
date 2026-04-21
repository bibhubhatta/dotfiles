function mountp --description 'Pick a partition, mount it, and cd into it'
    if test (uname) != Linux
        echo "mountp: Linux only" >&2
        return 1
    end
    if not type -q gum
        echo "mountp: requires 'gum' — install it (e.g. sudo pacman -S gum / brew install gum)" >&2
        return 1
    end

    set -l rows
    set -l has_ntfs 0
    for line in (lsblk -rpno NAME,TYPE,SIZE,FSTYPE,LABEL,MOUNTPOINT)
        set -l p (string split ' ' -- $line)
        test (count $p) -ge 4; or continue
        test "$p[2]" = part; or continue
        set -l fstype $p[4]
        test -n "$fstype"; or continue
        test "$fstype" = swap; and continue

        set -l label (string replace -a '\x20' ' ' -- $p[5])
        set -l mp (string replace -a '\x20' ' ' -- $p[6])
        test -z "$label"; and set label '-'
        set -l tag ''
        test -n "$mp"; and set tag "→ $mp"

        if test "$fstype" = ntfs -o "$fstype" = ntfs3
            set has_ntfs 1
        end

        set rows $rows (printf '%-14s %7s  %-8s  %-20s %s' $p[1] $p[3] $fstype $label $tag)
    end

    if test (count $rows) -eq 0
        echo "mountp: no mountable partitions found" >&2
        return 1
    end

    if test $has_ntfs -eq 1; and not type -q ntfs-3g
        echo "mountp: NTFS partitions detected but 'ntfs-3g' is not installed" >&2
        return 1
    end

    set -l choice (printf '%s\n' $rows | gum choose --header "Mount which partition?")
    test -n "$choice"; or return 130

    set -l dev (string split -m1 ' ' -- $choice)[1]
    set -l existing_mp (lsblk -no MOUNTPOINT $dev | string collect | string split \n)[1]
    set -l fstype (lsblk -no FSTYPE $dev | string trim)
    set -l label (lsblk -no LABEL $dev | string trim)

    if test -n "$existing_mp"
        echo "Already mounted at $existing_mp"
        cd $existing_mp
        return
    end

    set -l slug
    if test -n "$label"
        set slug (string lower -- $label | string replace -ra '[^a-z0-9]+' '-' | string trim -c '-')
    end
    test -z "$slug"; and set slug (string replace '/dev/' '' $dev)
    set -l default_mp /mnt/$slug

    set -l mp (gum input --header "Mount point" --value $default_mp)
    test -n "$mp"; or return 130

    set -l uid (id -u)
    set -l gid (id -g)
    set -l mount_args
    switch $fstype
        case ntfs ntfs3
            set mount_args -t ntfs-3g -o "uid=$uid,gid=$gid,umask=022,big_writes"
        case vfat exfat
            set mount_args -o "uid=$uid,gid=$gid,umask=022"
    end

    echo "Mounting $dev ($fstype) at $mp"
    sudo mkdir -p $mp; or return 1
    if not sudo mount $mount_args $dev $mp
        if test "$fstype" = ntfs -o "$fstype" = ntfs3
            echo "mountp: if this is a Windows disk, disable Fast Startup and shut down cleanly (not hibernate) before mounting." >&2
        end
        return 1
    end
    cd $mp
end
