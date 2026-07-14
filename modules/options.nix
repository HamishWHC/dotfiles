{ lib, moduleLocation, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
  inherit (lib.strings)
    escapeNixIdentifier
    ;

  # Stole this file from flake-parts source code before modifying for my purposes.
  # No idea how this function works.
  addModuleInfo =
    moduleName: class:
    if class == "generic" then
      module: module
    else
      module:
      # By returning a function, it will be accepted as a full-on module despite
      # a submodule having shorthandOnlyDefinesConfig = true, which is the
      # `types.submodule` default.
      # https://github.com/hercules-ci/flake-parts/issues/326
      { ... }:
      {
        # TODO: set key?
        _class = class;
        _file = "${toString moduleLocation}#features.${escapeNixIdentifier moduleName}.${escapeNixIdentifier class}";
        imports = [ module ];
      };

  featureType = types.lazyAttrsOf types.deferredModule;
in
{
  options = {
    flake.profiles = mkOption {
      type = types.lazyAttrsOf (types.listOf types.unspecified);
      description = ''
        Profiles published by the flake.

        Each element of a profile should be a feature (see flake.features) or another profile.
      '';
      example = lib.literalExpression ''
        [
           self.profiles.base
           self.features.nix
           self.features.home-manager
        ]
      '';
      apply = mapAttrs (name: profile: lib.flatten profile);
    };

    flake.features = mkOption {
      type = types.lazyAttrsOf featureType;
      description = ''
        Features published by the flake.

        The inner attributes declare the [`class`](https://nixos.org/manual/nixpkgs/stable/#module-system-lib-evalModules-param-class) of each module that make up the feature.
        The special attribute `generic` does not declare a class, allowing its modules to be used in any module class.
      '';
      example = lib.literalExpression ''
        {
          nixos = {
            some-nixos-service.enable = true;
          };

          darwin = {
            some-darwin-service.enable = true;
          };

          homeManager = {
            some-home-manager-service.enable = true;
          };
        }
      '';
      apply = mapAttrs (featureName: mapAttrs (addModuleInfo featureName));
    };
  };
}
