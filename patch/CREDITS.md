# Credits and prior research

This project combines a small new launcher with prior community research around the original RCT1 executable.

## Widescreen Gaming Forum

Community members documented that the English Deluxe 1.20.015 executable uses a different window-size pattern from the non-English 1.20.013 builds, including the values used to raise the window limit from 1280×1024 to 1920×1080.

https://www.wsgf.org/phpBB3/viewtopic.php?f=61&t=22729

## GOG community

Long-running discussion of RCT1 fullscreen/windowed hacks, unpacked executables and modern Windows compatibility:

https://www.gog.com/forum/rollercoaster_tycoon_series/hack_run_rct_full_screen_at_any_resolution_up_to_1280x1024/page4

## NeoLite / ExeLock unpacking

Russ Dill's Neo-Executable-Decompressor is the base unpacker:

https://github.com/russdill/Neo-Executable-Decompressor

The Steam/GOG RCT1 executable tested for this project uses the ExeLock variant. ExeLock support is provided by ZenoArrows' contribution:

https://github.com/russdill/Neo-Executable-Decompressor/pull/1

The installer pins the corresponding fork commit:

https://github.com/ZenoArrows/Neo-Executable-Decompressor/commit/4c8e0166af65f4a5410cd6a011489e04ffee1bbd

The unpacker also uses:

- pefile 2023.2.7: https://github.com/erocarrera/pefile/releases/tag/v2023.2.7
- zipfile-deflate64 0.2.0: https://pypi.org/project/zipfile-deflate64/0.2.0/

This repository does not bundle any RollerCoaster Tycoon executable.

## This project's additions

The launcher in this repository adds:

- automatic borderless fullscreen conversion
- self-elevation for modern Windows
- forced windowed configuration without modifying save games
- mouse edge-scrolling emulation
- multi-monitor cursor confinement
- release of cursor and synthetic keys on focus loss / Alt+Tab
