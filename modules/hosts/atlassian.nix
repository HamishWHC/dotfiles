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
    features = [
      self.profiles.workstation
      {
        darwin = {
          security.pam.services.sudo_local.enable = false;
          # security.pam.services.sudo_local.enable = true;
          # security.pam.services.sudo_local.reattach = true;
          # security.pam.services.sudo_local.touchIdAuth = true;

          nix-homebrew = {
            taps = {
              "atlassian/homebrew-acli" = inputs.homebrew-acli;
            };
            trust.formulae = [
              "atlassian/acli/acli"
            ];
          };
          homebrew.brews = [ "acli" ];
          homebrew.masApps = {
            "MeetingBar" = 1532419400;
          };
        };
      }
    ];
  };
}
