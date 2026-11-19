{
  # SSH Agent Mux combines several SSH agents behind one socket. The SSH client
  # feature enables it when more than one agent is configured.
  flake.features.ssh-agent-mux.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.dotfiles.ssh-agent-mux;
      mux = lib.getExe pkgs.ssh-agent-mux;
      plist = "${config.home.homeDirectory}/Library/LaunchAgents/net.ross-williams.ssh-agent-mux.plist";
      unit = "ross-williams-ssh-agent-mux.service";

      # The installer only detects systemd by finding `systemctl` on PATH,
      # which Home Manager's NixOS activation PATH lacks. Each script runs in a
      # subshell to keep these exports out of later activation steps.
      systemdEnv = ''
        export PATH="${pkgs.systemd}/bin:$PATH"
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      '';

      install =
        if pkgs.stdenv.isDarwin then
          ''
            # The installer invokes launchctl by name, but Home Manager's
            # activation PATH excludes macOS system commands.
            run ${pkgs.coreutils}/bin/env PATH="/bin:$PATH" ${mux} --install-service

            # Version 0.2.0 installs a disabled launch agent; its restart command
            # also uses an invalid launchctl status target. Enable/load directly.
            if ! /bin/launchctl print "gui/$(id -u)/net.ross-williams.ssh-agent-mux" >/dev/null 2>&1; then
              run /bin/launchctl load -w ${lib.escapeShellArg plist}
            fi
          ''
        else
          ''
            (
              ${systemdEnv}
              # Activation also runs at boot, before the user manager exists. The
              # unit stays enabled from the last install, so it starts on login.
              if systemctl --user show-environment >/dev/null 2>&1; then
                run ${mux} --install-service
                # The unit's ExecStart is a store path; reload before restarting
                # so an updated binary is picked up.
                run systemctl --user daemon-reload
                run ${mux} --restart-service
              else
                verboseEcho "Skipping ssh-agent-mux service install: user systemd manager is not running"
              fi
            )
          '';

      # Removes a service left by an earlier generation that enabled the mux.
      uninstall =
        if pkgs.stdenv.isDarwin then
          ''
            if [ -e ${lib.escapeShellArg plist} ]; then
              run /bin/launchctl unload -w ${lib.escapeShellArg plist} || true
              run ${pkgs.coreutils}/bin/env PATH="/bin:$PATH" ${mux} --uninstall-service
            fi
          ''
        else
          ''
            (
              ${systemdEnv}
              if [ -e "${config.xdg.configHome}/systemd/user/${unit}" ]; then
                if systemctl --user show-environment >/dev/null 2>&1; then
                  run systemctl --user disable --now ${unit} || true
                  run ${mux} --uninstall-service
                  run systemctl --user daemon-reload
                else
                  verboseEcho "Skipping ssh-agent-mux service removal: user systemd manager is not running"
                fi
              fi
            )
          '';
    in
    {
      options.dotfiles.ssh-agent-mux = {
        enable = lib.mkEnableOption "SSH Agent Mux";

        agents = lib.mkOption {
          description = "Upstream SSH agent socket paths, in the order keys should be offered.";
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        socketPath = lib.mkOption {
          description = "Socket the combined agent listens on.";
          type = lib.types.str;
          readOnly = true;
          default = "${config.home.homeDirectory}/.ssh/ssh-agent-mux.sock";
        };
      };

      config = {
        home.packages = lib.mkIf cfg.enable [ pkgs.ssh-agent-mux ];

        xdg.configFile."ssh-agent-mux/ssh-agent-mux.toml" = lib.mkIf cfg.enable {
          source = (pkgs.formats.toml { }).generate "ssh-agent-mux.toml" {
            agent_sock_paths = cfg.agents;
          };
        };

        home.activation.installSshAgentMuxService = lib.hm.dag.entryAfter [
          "linkGeneration"
          "createSshSocketDirectory"
        ] (if cfg.enable then install else uninstall);
      };
    };
}
