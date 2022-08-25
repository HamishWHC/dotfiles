# UNSW CSE SSHFS

# Your zID (change this)
_SSHFS_ZID=z5361056
# Your desired mountpoint for your CSE home directory
_SSHFS_CSE_MOUNT="$HOME/Documents/UNSW/cse-files"
_SSHFS_NAME="unsw"

alias csemnt="sshfs -o idmap=user -C ${_SSHFS_NAME}: ${_SSHFS_CSE_MOUNT}"
alias cseumount="umount ${_SSHFS_CSE_MOUNT}"

function cse() {
    # determine where we are relative to the mountpoint (thanks @ralismark)
    local rel=${PWD##${_SSHFS_CSE_MOUNT}}

    if [ -z "$1" ]; then
        # if we don't have arguments, we give the user a shell on the remote cse machine.
        if [ "$PWD" = "$rel" ]; then
            # in the case that we're not in our mountpoint, provide a shell in their home directory.
            ssh "${_SSHFS_NAME}"
        else
            # if within the mountpoint, cd to the equivalent dir on the remote before providing a shell (thanks @ralismark)
            ssh "${_SSHFS_NAME}" -t "cd $(printf "%q" "./$rel"); exec \$SHELL -l"
        fi
    else
        # if we have arguments, we have a command to execute.
        if [ "$PWD" = "$rel" ]; then
            # in the case that we're not in our mountpoint, we'll execute in the home directory.
            ssh -qt "${_SSHFS_NAME}" "$@"
        else
            # if within the mountpoint, cd to the equivalent dir on the remote before executing (thanks @ralismark)
            ssh "${_SSHFS_NAME}" -qt "cd $(printf "%q" "./$rel") && $(printf "%q " "$@")"
        fi
    fi
}
