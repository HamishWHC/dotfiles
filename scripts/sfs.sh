if command -v sshfs >/dev/null; then
    sfs() {
        if [ "$#" -ne 1 ]; then
            echo "Usage: sfs <target>"
            return 1
        fi

        target="$1"

        mkdir -p $HOME/mounts/${target}
        umount -f $HOME/mounts/${target}
        sshfs -o idmap=user -C ${target}: $HOME/mounts/${target}
    }

    usfs() {
        if [ "$#" -ne 1 ]; then
            echo "Usage: usfs <target>"
            return 1
        fi

        target="$1"
        umount -f $HOME/mounts/${target}
    }
fi
