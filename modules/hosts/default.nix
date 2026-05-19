{ self, ... }:
{
  flake.darwinConfigurations = {
    atlassian = import ../_hosts/atlassian.nix { inherit self; };
    personal = import ../_hosts/personal.nix { inherit self; };
  };
}
