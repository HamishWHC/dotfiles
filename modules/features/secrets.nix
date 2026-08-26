{ inputs, ... }:
{
  flake.features.secrets = {
    darwin =
      {
        username,
        ...
      }:
      {
        imports = [ inputs.sops-nix.darwinModules.sops ];

        sops = {
          defaultSopsFile = ../../secrets/default.yaml;
          age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";

          secrets.github-token = {
            key = "github_token";
            owner = username;
            mode = "0400";
          };
        };
      };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        age
        sops
      ];
    };
  };
}
