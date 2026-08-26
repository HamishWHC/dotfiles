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
        # Disable sudo Touch ID management
        darwin = {
          security.pam.services.sudo_local.enable = false;
        };
      }
      {
        # Host-specific apps
        darwin = {
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
            "Okta Verify" = 490179405;
          };
        };

        homeManager = { config, ... }: {
          home.sessionPath = [
            "/opt/atlassian/bin"
            "${config.home.homeDirectory}/.orbit/bin"
          ];
        };
      }
      {
        # KITT kubeconfig handling
        homeManager =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            kittExternalKubeconfig = "${config.home.homeDirectory}/.kube/kitt/external/config";
          in
          {
            dotfiles.kube.k3d.package = inputs.wrappers.lib.wrapPackage {
              inherit pkgs;
              package = pkgs.unstable.k3d;
              runtimeInputs = [ pkgs.coreutils ];
              preHook = ''
                case "''${KUBECONFIG-}" in
                  "" | "$HOME/.kube/kitt/context-pool/"*)
                    mkdir -p "$HOME/.kube/kitt/external"
                    export KUBECONFIG="$HOME/.kube/kitt/external/config"
                    ;;
                esac
              '';
            };

            home.file.".kube/config".source = config.lib.file.mkOutOfStoreSymlink kittExternalKubeconfig;

            programs.zsh.initContent = lib.mkAfter ''
              export KUBECONFIG="$(atlas kitt context:create --pid=$$)"
            '';
          };
      }
    ];
  };
}
