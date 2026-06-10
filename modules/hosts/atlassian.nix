{ inputs, self, ... }:
{
  flake-file.inputs = {
    homebrew-acli = {
      url = "github:atlassian/homebrew-acli";
      flake = false;
    };
  };

  flake.darwinConfigurations.atlassian = self.lib.mkDarwinHost "atlassian" {
    system = "aarch64-darwin";
    username = "hcox";
    configDir = "/Users/hcox/Documents/Personal/dotfiles";
    usesCyberark = true;
    darwinModules = [
      {
        security.pam.services.sudo_local.enable = false;
        # security.pam.services.sudo_local.enable = true;
        # security.pam.services.sudo_local.reattach = true;
        # security.pam.services.sudo_local.touchIdAuth = true;
      }
      {
        nix-homebrew.taps = {
          "atlassian/homebrew-acli" = inputs.homebrew-acli;
        };
        homebrew.brews = [ "acli" ];
      }
    ];
    homeManagerModules = [
      self.modules.homeManager.workstation
    ];
  };
}
