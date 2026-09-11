"""Merge portable input choices into user preferences without copying registries."""

import plistlib
import subprocess


def read_domain(domain, *, current_host=False):
    command = ["/usr/bin/defaults"]
    if current_host:
        command.append("-currentHost")
    # Export uses the preferences service and preserves plist scalar types.
    result = subprocess.run(
        [*command, "export", domain, "-"], capture_output=True, check=True
    )
    return plistlib.loads(result.stdout)


def write_changed(domain, existing, key, value, *, current_host=False):
    if existing.get(key) == value:
        return
    command = ["/usr/bin/defaults"]
    if current_host:
        command.append("-currentHost")
    subprocess.run(
        [*command, "write", domain, key, plistlib.dumps(value).decode()], check=True
    )


input_domain = "com.apple.HIToolbox"
inputs = read_domain(input_domain)
australian = {
    "InputSourceKind": "Keyboard Layout",
    "KeyboardLayout ID": 15,
    "KeyboardLayout Name": "Australian",
}

# Retain additional enabled layouts and system input methods (emoji, dictation,
# press-and-hold, etc.). Only the selected keyboard layout is managed.
enabled = inputs.get("AppleEnabledInputSources", [])
if australian not in enabled:
    write_changed(input_domain, inputs, "AppleEnabledInputSources", [*enabled, australian])
selected = [
    item
    for item in inputs.get("AppleSelectedInputSources", [])
    if item.get("InputSourceKind") != "Keyboard Layout"
]
write_changed(input_domain, inputs, "AppleSelectedInputSources", [australian, *selected])
write_changed(
    input_domain,
    inputs,
    "AppleCurrentKeyboardLayoutInputSourceID",
    "com.apple.keylayout.Australian",
)

global_domain = "NSGlobalDomain"
host_preferences = read_domain(global_domain, current_host=True)

# Vendor/product/interface tuples, not host UUIDs or device serial numbers.
# Match the three keyboard models from the audit, leaving other models local.
# The pinned nix-darwin keyboard module identifies 1095216660483 as Fn/Globe.
for keyboard in ["1133-50503-0", "1452-834-0", "3141-25903-0"]:
    key = f"com.apple.keyboard.modifiermapping.{keyboard}"
    mappings = [
        item
        for item in host_preferences.get(key, [])
        if item.get("HIDKeyboardModifierMappingSrc") != 30064771129
    ]
    mappings.append(
        {
            "HIDKeyboardModifierMappingSrc": 30064771129,  # Caps Lock
            "HIDKeyboardModifierMappingDst": 1095216660483,  # Fn/Globe
        }
    )
    write_changed(global_domain, host_preferences, key, mappings, current_host=True)

# Mirror the managed gestures where macOS also records host-specific overrides.
for key, value in {
    "com.apple.trackpad.enableSecondaryClick": True,
    "com.apple.trackpad.threeFingerDragGesture": False,
    "com.apple.trackpad.threeFingerVertSwipeGesture": 2,
    "com.apple.trackpad.fourFingerVertSwipeGesture": 2,
    "com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture": 3,
}.items():
    write_changed(global_domain, host_preferences, key, value, current_host=True)
