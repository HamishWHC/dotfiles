{ ... }:
{
  systems = [ "aarch64-darwin" ];

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-rfc-style;
  };
}
