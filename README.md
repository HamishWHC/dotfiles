# Dotfiles

## On devices with Cyberark EPM
Instead of switching immediately with `./switch.sh`, run `./build-darwin.sh $host` and in `result/activate` modify the `launchctl` command to `sudo --preserve-env=PATH` to ensure that the PATH is preserved when running the home-manager activation script. This is necessary because EPM may modify the environment variables when running commands with elevated privileges.