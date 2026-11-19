{ inputs, ... }:
let
  caches = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };
in
{
  # No `inputs.nixpkgs.follows`: overriding nixpkgs misses the Cachix cache.
  flake-file.inputs.vicinae.url = "github:vicinaehq/vicinae";
  flake-file.nixConfig = caches;

  flake.features.vicinae = {
    # The flake builds Vicinae from source on Darwin, so macOS uses the
    # official signed release from the cask instead.
    darwin =
      { lib, ... }:
      {
        homebrew.casks = [ "vicinae" ];

        # Free Command-Space for Vicinae, retaining the shortcut's existing binding.
        system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64".enabled =
          lib.mkForce false;
      };

    # Provides the input server used for pasting clipboard items, emoji and snippets.
    nixos = {
      imports = [ inputs.vicinae.nixosModules.default ];
      nix.settings = caches;
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (pkgs.stdenv) isDarwin isLinux;
        json = pkgs.formats.json { };
        jq = lib.getExe pkgs.jq;
        sed = lib.getExe pkgs.gnused;

        settings = import ./_settings.nix { inherit lib pkgs; };

        # Vicinae resolves a relative import against the real path of the
        # importing file, which is in the store, so it is imported by store path.
        platformSettings = json.generate "vicinae-${if isDarwin then "darwin" else "linux"}.json" (
          if isDarwin then settings.darwin else settings.linux
        );

        # Vicinae's settings.json is the GUI's, and its values win over this
        # import, so settings changed in the settings window keep working.
        configDir = "${config.home.homeDirectory}/.config/vicinae";
        dataDir =
          if isDarwin then
            "${config.home.homeDirectory}/.local/share/vicinae"
          else
            "${config.xdg.dataHome}/vicinae";
      in
      {
        imports = [ inputs.vicinae.homeManagerModules.default ];

        programs.vicinae = lib.mkIf isLinux {
          enable = true;
          enableNumen = false;
          systemd.enable = true;
        };

        home.file.".config/vicinae/nix.json".source = json.generate "vicinae-nix.json" (
          settings.shared // { imports = [ "${platformSettings}" ]; }
        );

        home.activation.vicinae = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          # Applies the jq filter in $2 to the JSON file $1, creating it from $3
          # when missing. Leading `//` comments, which Vicinae writes and jq
          # cannot parse, are set aside and restored.
          vicinaeUpdateJson() {
            local file="$1" filter="$2" empty="$3" header="" body="" updated
            if [ -e "$file" ]; then
              header="$(${sed} -n '/^[[:space:]]*\/\//!q;p' "$file")"
              body="$(${sed} '/^[[:space:]]*\/\//d' "$file")"
            fi
            [ -n "''${body//[[:space:]]/}" ] || body="$empty"

            if ! updated="$(printf '%s' "$body" | ${jq} "$filter" 2>/dev/null)"; then
              warnEcho "Not updating $file: it is not plain JSON."
              return
            fi
            [ "$updated" != "$(printf '%s' "$body" | ${jq} .)" ] || return 0

            run mkdir -p "$(dirname "$file")"
            if [ -z "''${DRY_RUN:-}" ]; then
              # Writes through a symlink, as Vicinae does.
              {
                [ -z "$header" ] || printf '%s\n\n' "$header"
                printf '%s\n' "$updated"
              } > "$file"
            fi
            verboseEcho "Updated $file"
          }

          vicinaeUpdateJson "${configDir}/settings.json" \
            'if (.imports // []) | index("nix.json") then . else .imports = (.imports // []) + ["nix.json"] end' \
            '{}'

          # Missing shortcuts are added; existing ones keep GUI edits and usage.
          vicinaeUpdateJson "${dataDir}/shortcuts/shortcuts.json" \
            ${lib.escapeShellArg ''
              (now | floor) as $now
              | . as $current
              | . + [${builtins.toJSON settings.shortcuts}[]
                  | select(.id as $id | any($current[]; .id == $id) | not)
                  | . + {openCount: 0, createdAt: $now, updatedAt: $now}]
            ''} \
            '[]'
        '';
      };
  };
}
