{inputs, ...}: {
  flake.modules.darwin.core = {
    pkgs,
    lib,
    ...
  }: {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@admin"];
    };

    nixpkgs.hostPlatform = "aarch64-darwin";

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      coreutils
      curl
      git
      gnugrep
      gnused
      openssh
      vim
    ];

    system.stateVersion = 6;

    # Intentionally do not set networking.hostName, networking.computerName, or
    # networking.localHostName. The flake host names are friendly names only.
  };
}
