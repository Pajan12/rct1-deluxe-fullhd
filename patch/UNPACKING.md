# Automatic NeoLite unpacking

For the common English Steam/GOG **RollerCoaster Tycoon Deluxe 1.20.015** release, `RCT.EXE` is commonly compressed with **NeoLite**.

Older versions of this project required the user to unpack `RCT.EXE` manually. That is no longer required.

## Normal installation

Simply double-click:

```text
Install-RCT-FullHD.cmd
```

If the installer cannot find the Full HD patch pattern directly in `RCT.EXE`, it automatically attempts NeoLite unpacking.

The installer:

1. creates a temporary working directory;
2. downloads the official Python 3.12.7 embeddable runtime from python.org;
3. downloads Russ Dill's Neo-Executable-Decompressor pinned to commit `b88c93369e7faf4c087e3973e1028038ed510526`;
4. downloads Ero Carrera's pefile source pinned to commit `cc9f5501ba93938e505858eaa3230608b6fbc34f`;
5. unpacks the user's own `RCT.EXE`;
6. verifies that the expected English Deluxe 1.20.015 byte patterns occur exactly once;
7. applies the 1920×1080 patch;
8. keeps the original executable as `RCT.original.exe`;
9. deletes the temporary runtime and unpacking tools.

No Python installation is added to Windows.

## Safety behaviour

The installer will **not overwrite `RCT.EXE`** if the automatically unpacked executable does not match the expected supported byte patterns.

In that case it displays an error and leaves the game executable unchanged.

## Upstream projects

Neo-Executable-Decompressor:

https://github.com/russdill/Neo-Executable-Decompressor

pefile:

https://github.com/erocarrera/pefile

Python:

https://www.python.org/
