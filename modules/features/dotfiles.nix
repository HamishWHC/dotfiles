{ self, ... }: {
  flake.features.dotfiles.homeManager =
    {
      host,
      username,
      pkgs,
      ...
    }:
    {
      imports = [
        self.features.just.homeManager
        self.features.nix-tools.homeManager
        self.features.jq.homeManager
      ];

      # Used as the default targets by the repository justfile.
      xdg.configFile."dotfiles/host".text = host;
      xdg.configFile."dotfiles/username".text = username;

      home.packages = with pkgs; [
        gum
        bat
        fzf
        ripgrep
        cloc
      ];
    };
}
