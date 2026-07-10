{ self, inputs, ... }:
{
  flake.overlays.unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  flake.overlays.custom =
    final: _prev:
    let
      system = final.stdenv.hostPlatform.system;
    in
    {
      custom = self.packages.${system} or (throw "custom packages are not defined for ${system}");
    };
}
