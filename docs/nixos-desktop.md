# NixOS desktop reference

Umbriel manages windows and displays; Noctalia provides the bar, launcher,
settings, notifications, and window switcher. `Mod` below means **Super** (the
Windows key). Press **Mod+/** for Umbriel's live keybind cheatsheet.

The configuration includes the starting config from the pinned Umbriel source
with unused bindings removed, then adds our overrides in
`modules/features/desktop/noctalia.nix`.
This reference describes that combined configuration.

## Everyday window management

The default layout scrolls horizontally through columns. New windows start at
half the monitor's usable width. A column can contain several vertically stacked
windows, or show them as tabs.

| Shortcut | Action |
| --- | --- |
| Mod+Left/Right | Focus window left/right |
| Mod+Up/Down | Focus window above/below |
| Alt+Tab / Alt+Shift+Tab | Noctalia window switcher, forward/backward |
| Mod+Shift+Left/Right | Move column left/right; at the carousel's end, move to the adjacent monitor |
| Mod+Shift+Up/Down | Move the window up/down in its column |
| Mod+Ctrl+Left/Right | Focus the monitor on that side |
| Mod+Ctrl+Shift+Left/Right | Move the window to that monitor |
| Mod+Q | Close the focused window |
| Mod+O | Toggle workspace overview |
| Mod+WheelUp/Down | Focus left/right |

For directional shortcuts, think **Mod = focus**, **Ctrl = across monitors**,
and **Shift = move the content instead of focus**. This is a convention for the
arrow bindings, not every shortcut. Left/right with Shift moves the whole column;
up/down moves the focused window inside its column. Ctrl+Shift+Left/Right moves
only the focused window to the adjacent monitor.

The monitor transfer happens at the end of the workspace's column list, not
merely at the visible edge of the screen. A stack or tab group moves together
with its column. Ctrl+Shift transfers the focused window immediately, without
first moving through the carousel.

## Size, grouping, and floating

| Shortcut | Action |
| --- | --- |
| Mod+R / Mod+Shift+R | Cycle width forward/backward: roughly ⅓, ½, ⅔ |
| Mod+Minus / Mod+Equal | Shrink/grow width by 2 percentage points |
| Mod+Shift+Minus / Mod+Shift+Equal | Shrink/grow height by 2 percentage points |
| Mod+F | Toggle full-width column |
| Mod+Ctrl+F | Toggle fullscreen |
| Mod+T | Toggle floating/tiling |
| Mod+Shift+T | Switch focus between floating and tiled windows |
| Mod+P | Toggle pinned above other windows and across workspaces on this monitor |
| Mod+Comma / Mod+Period | Stack into the column left/right, or unstack into a new column on that side |
| Mod+Ctrl+Comma / Mod+Ctrl+Period | Pull a window from the column left/right into this column |
| Mod+W | Toggle stacked rows / tabs |
| Mod+Alt+Left/Right | Reorder the focused tab left/right |
| Mod+Alt+1…9 | Focus tab 1…9 in the current tab group |

Width/height descriptions refer to the default horizontal scrolling layout;
Umbriel calls them primary/secondary extent for other layout orientations.
These tab shortcuts affect Umbriel's window tabs, not browser tabs.

**Floating** means the window is outside the tiled carousel: it can overlap
other windows and be positioned independently, but belongs to its workspace.
**Pinned** keeps a window above others and visible when switching workspaces on
its monitor. It is useful for a small reference window you want to keep around.

**Mod+T** changes the focused window between tiled and floating.
**Mod+Shift+T** only changes focus: from a tiled window to a floating one on
the same workspace, or back again. It does not change either window's layout
state, and does nothing if there is no window of the opposite kind to focus.

Mod+Comma / Mod+Period use `window-consume-or-expel-left/right`: if the window
is alone in its column, put it into the adjacent column on that side. If it is
already stacked, split it out into its own column on that side. For example,
Mod+Period can turn two side-by-side windows into a vertical stack; pressing it
again splits the focused window back out. Key repeat is disabled so holding the
shortcut does not repeatedly stack and unstack.
Mod+W switches that stack to tabs. Use Mod+Shift+Left/Right to move a column
sideways without combining it with another column.

## Workspaces

Workspaces belong to individual monitors.

| Shortcut | Action |
| --- | --- |
| Mod+1…9 | Switch to numbered workspace on this monitor |
| Mod+Shift+1…9 | Move window to numbered workspace |

## Desktop controls

| Shortcut | Action |
| --- | --- |
| Mod+Space | Toggle launcher/search |
| Mod+grave (backtick key) | Open Ghostty |
| Print | Screenshot an area |
| Shift+Print | Screenshot the focused monitor |
| Alt+Print | Screenshot the focused window |
| Mod+Shift+A | Screenshot and annotate |
| Mod+Shift+Space | 1Password Quick Access |
| Mod+/ | Toggle live keybind cheatsheet |
| Mod+Escape | Quit session (confirmation) |
| Mod+Shift+Escape | Toggle shortcut inhibition for the focused app |

Media, volume, mute, and brightness keys are handled through Noctalia, including
its on-screen indicators. The upper-left hot corner opens the overview after
500 ms.

Open the control center and settings through the Noctalia bar. Pressing Mod
alone does nothing.

## Cursor, shell, and timezone

Linux uses **Bibata-Modern-Classic**, a conventional dark cursor theme, at
**32 logical pixels**. Umbriel, GTK, and Xcursor applications share the theme
and size. Umbriel scales its cursor with the output scale; applications that
draw their own custom cursor may differ. These settings are in
`modules/features/desktop/noctalia.nix`.

Zsh is explicitly configured as the user's login shell on both NixOS and macOS
in `modules/features/cli/zsh/default.nix`. Existing terminals retain their running
shell; log out and back in after applying the configuration.

Both platforms use **Australia/Sydney**, including automatic daylight-saving
changes, in their respective `nixos.nix` and `nix-darwin.nix` feature modules.

## Gaming machine displays

The Alienware AW3225QF is on the **left**, and Samsung LS32A70 on the **right**.
Both use **150%** scaling. Their positions are `(0, 0)` and `(2560, 0)` in logical
pixels, so the two 3840-pixel-wide displays meet at their inner edges. Monitor
identities rather than connector numbers keep the layout stable across port changes.

These host-specific settings live in `modules/hosts/gaming/default.nix`.
To try **125%**, change both scales to `1.25` and the Samsung's x-position to
`3072` (`3840 / 1.25`). Refresh rates are currently left at their existing defaults.

## Browsers and the bar

HTTP, HTTPS, and HTML files on Linux use the `default-browser` dispatcher, and
`BROWSER` points to the same dispatcher for programs that use that variable.
It starts with Firefox and remembers your selection across logins and rebuilds.
The existing T3 Code URL association is also declared so it is retained when
Home Manager takes ownership of `mimeapps.list`.

The bar shows the selected browser's icon, with a **Private** label in private
mode. Click it for a dropdown with **Firefox**, **Firefox Private**, **Chromium**,
and **Chromium Incognito**. Selecting an entry changes where subsequent links
open; it does not open a browser immediately or change existing windows.
Private mode opens links using Firefox's `--private-window` or Chromium's
`--incognito`. The selection is stored in
`~/.local/state/default-browser/choice` (respecting `XDG_STATE_HOME`).

The system's registered browser remains **Default Browser**, so browsers may
report that they themselves are not the default. Use the bar to choose the target;
setting a browser directly as default would bypass the dispatcher.
Applications with their own browser preference may need that preference changed
to the system default. This selector does not implement per-site routing rules.

Noctalia's GUI overrides in `~/.local/state/noctalia/settings.toml` take precedence
over the Nix-managed base config. Bar customizations made there can override
the configured widget list.

## Applying changes

Build with `just build-home gaming hamishwhc` and `just build-system gaming`.
When ready, the human can apply the system configuration with `just switch gaming`.
Log out and back in to give existing applications the updated browser environment.
The agent must not run a host system switch.
