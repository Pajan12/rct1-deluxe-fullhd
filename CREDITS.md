# Credits and prior research

This project combines a small new launcher with prior community research around the original RCT1 executable.

## Widescreen Gaming Forum

Community members documented that the English Deluxe 1.20.015 executable uses a different window-size pattern from the non-English 1.20.013 builds, including the values used to raise the window limit from 1280×1024 to 1920×1080.

https://www.wsgf.org/phpBB3/viewtopic.php?f=61&t=22729

## GOG community

Long-running discussion of RCT1 fullscreen/windowed hacks, unpacked executables and modern Windows compatibility:

https://www.gog.com/forum/rollercoaster_tycoon_series/hack_run_rct_full_screen_at_any_resolution_up_to_1280x1024/page4

## Neo-Executable-Decompressor

Russ Dill's NeoLite unpacker is useful for owners of the English Deluxe 1.20.015 executable, which is commonly NeoLite-packed.

https://github.com/russdill/Neo-Executable-Decompressor

This repository does not bundle that project or any RollerCoaster Tycoon executable.

## This project's additions

The launcher in this repository adds:

- automatic borderless fullscreen conversion
- self-elevation for modern Windows
- forced windowed configuration without modifying save games
- mouse edge-scrolling emulation
- multi-monitor cursor confinement
- release of cursor and synthetic keys on focus loss / Alt+Tab
