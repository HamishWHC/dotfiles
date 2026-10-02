{
  flake.features.aws.homeManager =
    { config, lib, pkgs, ... }:
    let
      defaults = {
        output = "json";
      };
    in
    {
      home.packages = [
        pkgs.awscli2
        pkgs.awsume
      ];

      # Source the packaged script so assumed credentials reach the current shell.
      programs.zsh.shellAliases.awsume = "source ${pkgs.awsume}/bin/awsume";

      # AWS's writer preserves local profiles and comments. Removing an entry
      # above stops managing it; it does not delete its value from the config.
      home.activation.configureAws = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
          run ${pkgs.coreutils}/bin/env AWS_CONFIG_FILE=${lib.escapeShellArg "${config.home.homeDirectory}/.aws/config"} \
            ${pkgs.awscli2}/bin/aws configure set ${lib.escapeShellArg name} ${lib.escapeShellArg value} --profile default
        '') defaults)
      );
    };
}
