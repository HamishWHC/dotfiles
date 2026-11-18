{ config, lib, pkgs, osConfig, ... }:
let
  firefox = config.programs.firefox.finalPackage;
  browser = pkgs.writeShellApplication {
    name = "default-browser";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/default-browser"
      choice=firefox
      if [[ -r "$state_dir/choice" ]]; then
        read -r choice < "$state_dir/choice" || choice=firefox
      fi

      if [[ "''${1:-}" == --set ]]; then
        case "''${2:-}" in
          firefox|firefox-private|chromium|chromium-private) ;;
          *) echo 'Invalid browser choice' >&2; exit 1 ;;
        esac
        mkdir -p "$state_dir"
        choice_file=$(mktemp "$state_dir/choice.XXXXXX")
        printf '%s\n' "$2" > "$choice_file"
        mv -f "$choice_file" "$state_dir/choice"
        exit 0
      fi

      # Firefox's --private-window consumes its next argument as a URL.
      # Reject option-looking inputs before forwarding any browser arguments.
      for url in "$@"; do
        if [[ "$url" == -* ]]; then
          echo 'Expected a URL or file path, not a browser option' >&2
          exit 2
        fi
      done

      # Keep URLs as separate arguments, never shell code.
      case "$choice" in
        chromium) exec ${pkgs.ungoogled-chromium}/bin/chromium -- "$@" ;;
        chromium-private) exec ${pkgs.ungoogled-chromium}/bin/chromium --incognito -- "$@" ;;
        firefox-private)
          # Each URL needs its own private-window flag; trailing bare URLs
          # can otherwise be handled by Firefox as ordinary browsing requests.
          if (( $# <= 1 )); then
            exec ${firefox}/bin/firefox --private-window "$@"
          fi
          for url in "$@"; do
            ${firefox}/bin/firefox --private-window "$url" &
          done
          wait
          ;;
        *) exec ${firefox}/bin/firefox -- "$@" ;;
      esac
    '';
  };
  mimeTypes = [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ];
  firefoxIcon = "${firefox}/share/icons/hicolor/48x48/apps/firefox.png";
  chromiumIcon = "${pkgs.ungoogled-chromium}/share/icons/hicolor/48x48/apps/chromium.png";
  common = pkgs.replaceVars ./common.luau {
    browserCommand = "${browser}/bin/default-browser";
    inherit firefoxIcon chromiumIcon;
  };
  plugin = pkgs.runCommand "noctalia-browser-selector" { } ''
    mkdir -p "$out"
    cp ${./plugin.toml} "$out/plugin.toml"
    cp ${./widget.luau} "$out/widget.luau"
    cp ${./panel.luau} "$out/panel.luau"
    cp ${common} "$out/common.luau"
    test -f ${firefoxIcon}
    test -f ${chromiumIcon}
    ${osConfig.programs.noctalia.package}/bin/noctalia plugins lint "$out"
  '';
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ browser ];
    home.sessionVariables.BROWSER = "${browser}/bin/default-browser";
    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs mimeTypes (_: [ "default-browser.desktop" ]);
    };
    xdg.desktopEntries.default-browser = {
      name = "Default Browser";
      comment = "Open with the browser selected in the Noctalia bar";
      exec = "${browser}/bin/default-browser %u";
      icon = "web-browser";
      terminal = false;
      noDisplay = true;
      categories = [ "Network" "WebBrowser" ];
      mimeType = mimeTypes;
    };
    xdg.dataFile."noctalia/plugins/browser-selector".source = plugin;
  };
}
