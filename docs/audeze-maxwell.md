# Audeze Maxwell Game/Chat dial

The headset's Game/Chat dial works on Linux once PipeWire exposes both of the
dongle's hardware outputs. The rules are in `modules/hosts/gaming/default.nix`
under `services.pipewire.wireplumber.extraConfig."51-audeze-maxwell"`.

## How the dongle works

The Maxwell dongle (`3329:4b19`) is a composite USB device with two separate
USB Audio Class functions:

| USB interface | String                | ALSA PCM       | Contents                    |
|---------------|-----------------------|----------------|-----------------------------|
| 0             | Audeze Maxwell HID    | `/dev/hidrawN` | media keys + vendor channel |
| 1 (ctrl) 2, 3 | `Chat-Audeze Maxwell` | `hw:Dongle,0`  | stereo out + mono mic       |
| 4 (ctrl) 5    | `Game-Audeze Maxwell` | `hw:Dongle,1`  | stereo out                  |

**The dongle/headset does the Game/Chat mix itself, in hardware.** The dial
attenuates the `hw:,1` (Game) stream at one end and the `hw:,0` (Chat) stream at the
other. It does not touch the UAC volume controls (no ALSA mixer events), and the
Windows driver does no mixing; Windows just exposes the two functions as two
playback devices.

PipeWire's default ACP profile only opens `hw:,0` (Chat), so without the rules
everything goes into the Chat stream and the dial does nothing useful.

I tested this with a 440 Hz tone on `hw:,1` and an 880 Hz tone on `hw:,0`. Each
one ducks at the opposite end of the dial.

## Configuration

The rules apply PipeWire's bundled `usb-gaming-headset.conf` profile set to the
dongle. It already describes the "chat on device 0 with mic, game on device 1"
layout, and it is used for SteelSeries and HyperX headsets. The rules also rename
the nodes and make Game the default sink:

- **Audeze Maxwell Game**: default sink, for regular audio
- **Audeze Maxwell Chat**: for Discord and other voice apps
- **Audeze Maxwell Microphone**

Move chat apps onto the Chat sink with pavucontrol, the app's own output-device
setting, or `pw-metadata -n default <stream-id> target.object <sink object.serial>`.
`target.object` must be the sink's `object.serial` for WirePlumber to remember it.
WirePlumber remembers each app's choice in
`~/.local/state/wireplumber/stream-properties`.

## Dial position over HID

You only need this for monitoring, not for the mix. The vendor channel is
Airoha-based (see HeadsetControl's `audeze_maxwell_device.hpp`). Read parameter
`0x0B`:

```
out report 06: 06 <len> 80 | 05 5A 04 00 83 2C 0B 00
in  report 07 (HIDIOCGINPUT): ... 05 5B 06 00 83 2C 00 0B 00 <value>
```

`<value>` goes from 0 to 20, with 10 at the centre. Reading it needs read/write
access to the dongle's hidraw node, which is root-only by default.
