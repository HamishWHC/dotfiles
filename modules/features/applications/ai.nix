{
  flake.features.ai.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.unstable.claude-code
        pkgs.unstable.codex
        pkgs.unstable.t3code
      ];
    };
}
