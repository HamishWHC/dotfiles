{
  flake.features.thaw = {
    homeManager = { lib, pkgs, ... }: {
      home.packages = lib.mkIf pkgs.stdenv.isDarwin [ pkgs.unstable.thaw ];
    };

    darwin = {
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
