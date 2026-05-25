{
  flake.modules.homeManager.nix-tools = {config, pkgs, ...}: {
    home.packages = with pkgs; [
      nixfmt
      nixd
      nil
    ];
  };
}