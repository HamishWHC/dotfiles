{inputs, ...}: {
  flake.modules.darwin.homebrew = {
    username,
    ...
  }: {
    imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

    system.primaryUser = username;

    nix-homebrew = {
      enable = true;
      user = username;
      autoMigrate = true;
      mutableTaps = false;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    };

    homebrew = {
      enable = true;
      global.brewfile = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "none";
      };
      brews = [
        "bat"
        "fzf"
        "git"
        "kubectl"
        "kubectx"
        "openssl"
        "readline"
        "sqlite3"
        "tcl-tk"
        "xh"
        "xz"
        "zlib"
      ];
    };
  };
}
