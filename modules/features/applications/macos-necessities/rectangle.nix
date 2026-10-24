{
  flake.features.rectangle.darwin = {
    homebrew.casks = [ "rectangle" ];

    system.defaults.CustomUserPreferences."com.knollsoft.Rectangle" = {
      launchOnLogin = true;
      hideMenubarIcon = true;
      gapSize = 10.0;
      alternateDefaultShortcuts = true; # Magnet shortcut defaults.
      allowAnyShortcut = false;
      subsequentExecutionMode = 1; # Repeated left/right moves to the adjacent display.
      unsnapRestore = 1;
      missionControlDragging = 1;
      hapticFeedbackOnSnap = 2;
      footprintAnimationDurationMultiplier = 0.0;
      footprintBlur = false;

      almostMaximize = {
        keyCode = 42;
        modifierFlags = 786432;
      }; # Control-Option-Backslash.
      reflowTodo = {
        keyCode = 45;
        modifierFlags = 786432;
      }; # Control-Option-N.
      toggleTodo = {
        keyCode = 11;
        modifierFlags = 786432;
      }; # Control-Option-B.

      # Rectangle stores snap-area configuration as a JSON string.
      landscapeSnapAreas = builtins.toJSON [
        6
        { action = 13; }
        5
        { compound = -3; }
        4
        { compound = -2; }
        3
        { action = 16; }
        8
        { action = 14; }
        2
        { action = 2; }
        7
        { compound = -4; }
        1
        { action = 15; }
      ];
    };
  };
}
