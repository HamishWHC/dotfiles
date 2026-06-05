{
  flake.modules.homeManager.nix-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixfmt
        nixd
        nil
      ];
    };
}
