{ inputs, self, ... }:
{
  flake.overlays.custom =
    final: _prev:
    let
      system = final.stdenv.hostPlatform.system;
    in
    {
      custom = self.packages.${system} or (throw "custom packages are not defined for ${system}");
    };
}
