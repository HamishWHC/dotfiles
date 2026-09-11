{ self, inputs, ... }: {
  flake.features.dotfiles.homeManager =
    {
      host,
      configDir,
      username,
      pkgs,
      lib,
      system,
      ...
    }:
    let
      drs = pkgs.writeShellScriptBin "drs" ''
        sudo -H ${
          inputs.nix-darwin.packages.${system}.darwin-rebuild
        }/bin/darwin-rebuild switch --flake '${configDir}/.#${host}' "$@"
      '';
    in
    {
      imports = [
        self.features.just.homeManager
        self.features.nix-tools.homeManager
        self.features.jq.homeManager
      ];

      # Used as the default targets by the repository justfile.
      xdg.configFile."dotfiles/host".text = host;
      xdg.configFile."dotfiles/username".text = username;

      home.packages =
        with pkgs;
        [
          gum
          bat
          fzf
          ripgrep
          cloc
        ]
        ++ lib.optional pkgs.stdenv.isDarwin drs;
    };
}
