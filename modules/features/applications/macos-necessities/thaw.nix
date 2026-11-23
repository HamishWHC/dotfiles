{
  flake.features.thaw = {
    darwin = { host, ... }: {
      homebrew.casks = [
        # TODO: Temporary. The atlassian host is on an older macOS that the
        # beta doesn't support; drop this once it's upgraded.
        (if host == "atlassian" then "thaw" else "thaw@beta")
      ];

      system.defaults.CustomUserPreferences."com.stonerl.Thaw" = {
        ShowIceIcon = true;
        ShowOnClick = true;
        ShowOnDoubleClick = true;
        ShowOnHover = false;
        ShowOnHoverDelay = 0.2;
        ShowOnScroll = true;
        AutoRehide = true;
        RehideStrategy = 0; # Smart
        EnableAlwaysHiddenSection = true;
        HideApplicationMenus = true;
        ShowAllSectionsOnUserDrag = true;
        EnableSecondaryContextMenu = true;
        SectionDividerStyle = 0;
        ItemSpacingOffset = -4.0;
        ShowMenuBarTooltips = false;
        TooltipDelay = 0.5;
        IconRefreshInterval = 0.5;
        EnableDiagnosticLogging = false;
      };
    };
  };
}
