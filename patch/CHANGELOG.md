# Changelog

## 1.0.2

Clean-install test fixes.

- Added ExeLock/Deflate64 support for the Steam/GOG RCT1 executable
- Switched the temporary runtime to Python 3.10.11 for zipfile-deflate64 compatibility
- Added zipfile-deflate64 0.2.0 with SHA-256 verification from PyPI metadata
- Pinned pefile to 2023.2.7, matching the ExeLock unpacker requirements
- Documented all helper packages downloaded by the installer
- Moved internal PowerShell scripts and technical files into the `patch` folder
- Kept only the three CMD entry points and README files at the package root

## 1.0.1

Installer usability fix discovered during clean-install testing.

- NeoLite unpacking is now fully automatic
- No Python installation or command-line steps required
- Installer self-elevates through UAC
- Uses a temporary official Python embeddable runtime
- Pins Neo-Executable-Decompressor and pefile to specific commits
- Validates the unpacked EXE before overwriting the game executable
- Temporary unpacking tools are removed afterwards
- Simplified EN/CZ installation instructions

## 1.0.0

Initial public release.

- Patches supported unpacked English RCT Deluxe 1.20.015 executables for a 1920×1080 window
- Borderless fullscreen launcher
- Windows 11 compatibility configuration
- Automatic administrator elevation
- Mouse edge-scrolling restored in borderless mode
- Dual-/multi-monitor cursor confinement while the game is focused
- Cursor and synthetic arrow keys released on Alt+Tab
- Original `RCT.EXE` automatically backed up
- Restore script
- No game executable included
