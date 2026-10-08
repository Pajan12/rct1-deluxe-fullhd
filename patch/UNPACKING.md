# Automatic NeoLite / ExeLock unpacking

The common English Steam/GOG **RollerCoaster Tycoon Deluxe 1.20.015** executable uses an **ExeLock variant of NeoLite**. ExeLock uses Deflate64 compression in places where the original NeoLite unpacker expects normal zlib data.

That is why the original upstream Neo-Executable-Decompressor can fail on this RCT executable with:

```text
zlib.error: Error -3 while decompressing data: unknown compression method
```

An open upstream pull request adds explicit ExeLock support and notes that ExeLock is used by RollerCoaster Tycoon 1 and 2.

## Normal installation

The user does not need to unpack anything manually. Double-click:

```text
Install-RCT-FullHD.cmd
```

If the installer cannot find the Full HD byte pattern directly in `RCT.EXE`, it automatically:

1. creates a temporary working directory;
2. downloads **Python 3.10.11 embeddable** from python.org;
3. downloads the ExeLock-supporting Neo-Executable-Decompressor code pinned to commit `4c8e0166af65f4a5410cd6a011489e04ffee1bbd`;
4. downloads **pefile 2023.2.7**;
5. downloads the Windows CPython 3.10 wheel of **zipfile-deflate64 0.2.0** from PyPI;
6. verifies the wheel against the SHA-256 published by PyPI;
7. unpacks the user's own `RCT.EXE`;
8. verifies that the expected English Deluxe 1.20.015 patch patterns occur exactly once;
9. applies the 1920×1080 patch;
10. keeps the original executable as `RCT.original.exe`;
11. deletes the temporary runtime and helper packages.

No Python installation is added to Windows.

## Safety behaviour

The installer will **not overwrite `RCT.EXE`** if the unpacked executable does not match the expected supported byte patterns.

## Upstream sources

ExeLock support pull request:
https://github.com/russdill/Neo-Executable-Decompressor/pull/1

ExeLock-supporting fork/commit:
https://github.com/ZenoArrows/Neo-Executable-Decompressor/commit/4c8e0166af65f4a5410cd6a011489e04ffee1bbd

pefile:
https://github.com/erocarrera/pefile/releases/tag/v2023.2.7

zipfile-deflate64:
https://pypi.org/project/zipfile-deflate64/0.2.0/

Python:
https://www.python.org/
