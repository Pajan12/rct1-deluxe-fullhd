# Unpacking the English Deluxe 1.20.015 executable

The English Steam/GOG release of RollerCoaster Tycoon Deluxe 1.20.015 is commonly packed with **NeoLite**.

The Full HD patch cannot find its target byte patterns until the executable has been unpacked.

## Important

This repository does **not** distribute an unpacked `RCT.EXE`.

Use only an executable from a RollerCoaster Tycoon Deluxe installation you legally own.

## Option: Neo-Executable-Decompressor

An open-source NeoLite unpacker is available here:

https://github.com/russdill/Neo-Executable-Decompressor

Follow that project's instructions. A typical command is conceptually:

```text
python neolite_unpack.py RCT.EXE RCT-unpacked.exe
```

After you have an unpacked copy:

1. keep the original `RCT.EXE` in the game directory;
2. place the unpacked copy next to it as:

   ```text
   RCT-unpacked.exe
   ```

3. run:

   ```text
   Install-RCT-FullHD.cmd
   ```

The installer looks for the known 1.20.015 byte patterns and refuses to modify the file if they are not found exactly once.

## Historical context

The relevant English Deluxe 1.20.015 window-size patterns were documented by the Widescreen Gaming Forum community:

https://www.wsgf.org/phpBB3/viewtopic.php?f=61&t=22729

Historical GOG discussion:

https://www.gog.com/forum/rollercoaster_tycoon_series/hack_run_rct_full_screen_at_any_resolution_up_to_1280x1024/page4
