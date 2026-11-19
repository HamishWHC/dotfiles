# Vicinae settings, split by platform. `shared` is written to nix.json, which
# imports the platform file. Run `vicinae config default` for every option.
{ lib, pkgs }:
let
  disabled =
    names:
    lib.genAttrs names (_: {
      enabled = false;
    });

  # Agents are run through an absolute npx: apps launched by the desktop do
  # not get the shell's PATH, so Vicinae cannot find Node.js on its own.
  npx = lib.getExe' pkgs.nodejs_26 "npx";

  # The Claude adapter otherwise runs the generic Linux binary it downloads,
  # which NixOS cannot execute, so point it at the Nix-built CLI.
  claudeEnv = lib.optionalString pkgs.stdenv.isLinux "${lib.getExe' pkgs.coreutils "env"} CLAUDE_CODE_EXECUTABLE=${lib.getExe pkgs.unstable.claude-code} ";
in
{
  # Shortcuts live in Vicinae's data rather than its settings. They are added
  # when missing, keeping GUI edits and usage counts. IDs are referenced below.
  shortcuts = [
    {
      id = "sct-7d79a57c7a7f";
      name = "Kagi";
      icon = "icon://omnicast/text-cursor?fill=primary-text";
      url = "https://kagi.com/search?q={query}";
      app = "default";
    }
  ];

  shared = {
    close_on_focus_loss = false;
    pop_to_root_on_close = false;
    # Empty navigates back; "close_window" closes the launcher.
    escape_key_behavior = "";
    theme.dark.name = "vicinae-dark";
    telemetry.system_info = false;

    fallbacks = [
      "shortcuts:sct-7d79a57c7a7f" # Kagi
      "ai:quick"
      "files:search"
    ];

    providers = {
      ai.preferences = {
        providers = {
          claude-code = {
            type = "acp";
            fields = {
              name = "Claude Code";
              command = "${claudeEnv}${npx} -y @agentclientprotocol/claude-agent-acp@0.101.0";
            };
          };
          codex = {
            type = "acp";
            fields = {
              name = "Codex";
              command = "${npx} -y @agentclientprotocol/codex-acp@2.6.0";
            };
          };
        };
        defaultModel = "claude-code:opus";
        instructions = "";
        enableTools = true;
      };

      clipboard.entrypoints.history.preferences.defaultAction = "copy";

      core.entrypoints =
        disabled [
          "list-extensions"
          "open-default-config"
          "refresh-apps"
          "reload-scripts"
          "report-bug"
          "show-logs"
          "sponsor"
          "store"
        ]
        //
          lib.genAttrs
            [
              "manage-fallback"
              "open-config-file"
              "search-emojis"
            ]
            (_: {
              enabled = true;
            });

      developer.entrypoints = disabled [ "create" ];

      dictation.entrypoints = disabled [
        "add-vocab"
        "create-style"
        "dictate"
        "history"
        "styles"
        "vocab"
      ];

      media.entrypoints = disabled [
        "next-track"
        "now-playing"
        "play-pause"
        "previous-track"
        "toggle-mute"
        "volume-0"
        "volume-25"
        "volume-50"
        "volume-75"
        "volume-100"
        "volume-down"
        "volume-up"
      ];

      power.entrypoints = disabled [
        "logout"
        "power-off"
        "reboot"
      ];

      raycast-compat.entrypoints = disabled [ "store" ];

      screenshots.entrypoints = disabled [
        "browse"
        "paste-last"
      ];

      snippets = {
        preferences = {
          enabled = true;
          undo = true;
        };
        entrypoints = disabled [
          "create"
          "manage"
        ];
      };

      system.entrypoints = disabled [
        "browse-apps"
        "run"
      ];

      theme.entrypoints = disabled [ "set" ];

      wm.entrypoints = disabled [ "switch-windows" ];
    };
  };

  darwin = {
    global_shortcuts.toggle = "cmd+space";

    providers = {
      # Entrypoints are bundle IDs. On NixOS, the compositor binds Ghostty.
      applications.entrypoints = {
        "com.apple.Terminal".enabled = false;
        "com.mitchellh.ghostty" = {
          alias = "terminal";
          shortcut = "control+`";
        };
      };

      core.entrypoints = disabled [ "search-menu-bar" ];

      macos-settings.entrypoints = disabled [ "com.apple.Touch-Settings.extension" ];
    };
  };

  linux = {
    # The Home Manager module would otherwise pin the calculator backend
    # through VICINAE_OVERRIDES, which the settings window cannot change.
    providers.calculator.preferences.backend = "numen";
  };
}
