{
  flake.features.ai = {
    darwin = {
      homebrew.casks = [
        "paseo"
      ];
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.unstable.claude-code
          pkgs.unstable.codex
        ];
      };
  };
}
