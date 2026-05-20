{ ... }:
{
  flake.darwinModules.home-manager = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
