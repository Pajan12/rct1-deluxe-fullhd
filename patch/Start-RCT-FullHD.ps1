$ErrorActionPreference = "Stop"

# RCT1 Deluxe Full HD launcher
# Borderless 1920x1080 + multi-monitor edge scrolling.

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $args = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $args -WindowStyle Hidden
    exit
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe  = Join-Path $root "RCT.EXE"
$cfg  = Join-Path $root "Data\Game.cfg"

if (-not (Test-Path $exe)) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "RCT.EXE was not found.`n`nCopy this package into the RollerCoaster Tycoon Deluxe game folder and run Install-RCT-FullHD.cmd first.",
        "RCT1 Deluxe Full HD"
    ) | Out-Null
    exit 1
}

if (Test-Path $cfg) {
    $bytes = [System.IO.File]::ReadAllBytes($cfg)
    if ($bytes.Length -gt 0x17) {
        $bytes[0x17] = 0
        [System.IO.File]::WriteAllBytes($cfg, $bytes)
    }
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class RctWin32 {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT { public int X, Y; }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct MONITORINFO {
        public int cbSize;
        public RECT rcMonitor;
        public RECT rcWork;
        public uint dwFlags;
    }

    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    [DllImport("user32.dll")]
    public static extern IntPtr MonitorFromWindow(IntPtr hwnd, uint dwFlags);

    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern bool GetMonitorInfo(IntPtr hMonitor, ref MONITORINFO lpmi);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint MapVirtualKey(uint uCode, uint uMapType);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll", EntryPoint="ClipCursor")]
    public static extern bool ClipCursorRect(ref RECT lpRect);

    [DllImport("user32.dll", EntryPoint="ClipCursor")]
    public static extern bool ClipCursorClear(IntPtr lpRect);

    public const int GWL_STYLE = -16;
    public const int GWL_EXSTYLE = -20;
    public const int WS_CAPTION = 0x00C00000;
    public const int WS_THICKFRAME = 0x00040000;
    public const int WS_MINIMIZEBOX = 0x00020000;
    public const int WS_MAXIMIZEBOX = 0x00010000;
    public const int WS_SYSMENU = 0x00080000;
    public const int WS_EX_DLGMODALFRAME = 0x00000001;
    public const int WS_EX_WINDOWEDGE = 0x00000100;
    public const int WS_EX_CLIENTEDGE = 0x00000200;
    public const int WS_EX_STATICEDGE = 0x00020000;
    public const uint MONITOR_DEFAULTTONEAREST = 2;
    public const uint SWP_FRAMECHANGED = 0x0020;
    public const uint SWP_SHOWWINDOW = 0x0040;
    public const uint SWP_NOOWNERZORDER = 0x0200;
    public const int SW_RESTORE = 9;
    public const byte VK_LEFT = 0x25;
    public const byte VK_UP = 0x26;
    public const byte VK_RIGHT = 0x27;
    public const byte VK_DOWN = 0x28;
    public const uint MAPVK_VK_TO_VSC = 0;
    public const uint KEYEVENTF_EXTENDEDKEY = 0x0001;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public static readonly IntPtr HWND_TOP = IntPtr.Zero;
}
"@

function Set-KeyState([byte]$vk, [bool]$down) {
    $scan = [byte]([RctWin32]::MapVirtualKey($vk, [RctWin32]::MAPVK_VK_TO_VSC) -band 0xFF)
    $flags = [RctWin32]::KEYEVENTF_EXTENDEDKEY
    if (-not $down) { $flags = $flags -bor [RctWin32]::KEYEVENTF_KEYUP }
    [RctWin32]::keybd_event($vk, $scan, $flags, [UIntPtr]::Zero)
}

$p = Start-Process -FilePath $exe -WorkingDirectory $root -PassThru

$hwnd = [IntPtr]::Zero
for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Milliseconds 250
    try {
        $p.Refresh()
        $hwnd = $p.MainWindowHandle
    } catch {}
    if ($hwnd -ne [IntPtr]::Zero) { break }
}

if ($hwnd -eq [IntPtr]::Zero) { throw "Could not obtain the RollerCoaster Tycoon window handle." }

Start-Sleep -Milliseconds 1200

for ($i = 0; $i -lt 12; $i++) {
    try {
        $p.Refresh()
        if ($p.MainWindowHandle -ne [IntPtr]::Zero) { $hwnd = $p.MainWindowHandle }

        [RctWin32]::ShowWindow($hwnd, [RctWin32]::SW_RESTORE) | Out-Null

        $style = [RctWin32]::GetWindowLong($hwnd, [RctWin32]::GWL_STYLE)
        $removeStyle = [RctWin32]::WS_CAPTION -bor [RctWin32]::WS_THICKFRAME -bor `
                       [RctWin32]::WS_MINIMIZEBOX -bor [RctWin32]::WS_MAXIMIZEBOX -bor `
                       [RctWin32]::WS_SYSMENU
        $style = $style -band (-bnot $removeStyle)
        [RctWin32]::SetWindowLong($hwnd, [RctWin32]::GWL_STYLE, $style) | Out-Null

        $ex = [RctWin32]::GetWindowLong($hwnd, [RctWin32]::GWL_EXSTYLE)
        $removeEx = [RctWin32]::WS_EX_DLGMODALFRAME -bor [RctWin32]::WS_EX_WINDOWEDGE -bor `
                    [RctWin32]::WS_EX_CLIENTEDGE -bor [RctWin32]::WS_EX_STATICEDGE
        $ex = $ex -band (-bnot $removeEx)
        [RctWin32]::SetWindowLong($hwnd, [RctWin32]::GWL_EXSTYLE, $ex) | Out-Null

        $mon = [RctWin32]::MonitorFromWindow($hwnd, [RctWin32]::MONITOR_DEFAULTTONEAREST)
        $mi = New-Object RctWin32+MONITORINFO
        $mi.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($mi)

        if ([RctWin32]::GetMonitorInfo($mon, [ref]$mi)) {
            $x = $mi.rcMonitor.Left
            $y = $mi.rcMonitor.Top
            $w = $mi.rcMonitor.Right - $mi.rcMonitor.Left
            $h = $mi.rcMonitor.Bottom - $mi.rcMonitor.Top
            [RctWin32]::SetWindowPos($hwnd, [RctWin32]::HWND_TOP, $x, $y, $w, $h,
                [RctWin32]::SWP_FRAMECHANGED -bor [RctWin32]::SWP_SHOWWINDOW -bor [RctWin32]::SWP_NOOWNERZORDER) | Out-Null
        }
    } catch {}
    Start-Sleep -Milliseconds 300
}

$edgeMargin = 2
$leftHeld = $false
$rightHeld = $false
$upHeld = $false
$downHeld = $false
$cursorClipped = $false

function Release-EdgeKeys {
    if ($script:leftHeld)  { Set-KeyState ([RctWin32]::VK_LEFT) $false; $script:leftHeld = $false }
    if ($script:rightHeld) { Set-KeyState ([RctWin32]::VK_RIGHT) $false; $script:rightHeld = $false }
    if ($script:upHeld)    { Set-KeyState ([RctWin32]::VK_UP) $false; $script:upHeld = $false }
    if ($script:downHeld)  { Set-KeyState ([RctWin32]::VK_DOWN) $false; $script:downHeld = $false }
}

function Release-CursorClip {
    if ($script:cursorClipped) {
        [RctWin32]::ClipCursorClear([IntPtr]::Zero) | Out-Null
        $script:cursorClipped = $false
    }
}

try {
    while (-not $p.HasExited) {
        $p.Refresh()

        if ($p.MainWindowHandle -ne [IntPtr]::Zero -and $p.MainWindowHandle -ne $hwnd) {
            Release-EdgeKeys
            Release-CursorClip
            $hwnd = $p.MainWindowHandle
        }

        $isForeground = ([RctWin32]::GetForegroundWindow() -eq $hwnd)

        if ($isForeground) {
            $mon = [RctWin32]::MonitorFromWindow($hwnd, [RctWin32]::MONITOR_DEFAULTTONEAREST)
            $mi = New-Object RctWin32+MONITORINFO
            $mi.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($mi)

            if ([RctWin32]::GetMonitorInfo($mon, [ref]$mi)) {
                if (-not $cursorClipped) {
                    $clip = New-Object RctWin32+RECT
                    $clip.Left = $mi.rcMonitor.Left
                    $clip.Top = $mi.rcMonitor.Top
                    $clip.Right = $mi.rcMonitor.Right
                    $clip.Bottom = $mi.rcMonitor.Bottom
                    [RctWin32]::ClipCursorRect([ref]$clip) | Out-Null
                    $cursorClipped = $true
                }

                $pt = New-Object RctWin32+POINT
                if ([RctWin32]::GetCursorPos([ref]$pt)) {
                    $wantLeft  = $pt.X -le ($mi.rcMonitor.Left + $edgeMargin - 1)
                    $wantRight = $pt.X -ge ($mi.rcMonitor.Right - $edgeMargin)
                    $wantUp    = $pt.Y -le ($mi.rcMonitor.Top + $edgeMargin - 1)
                    $wantDown  = $pt.Y -ge ($mi.rcMonitor.Bottom - $edgeMargin)

                    if ($wantLeft -ne $leftHeld) { Set-KeyState ([RctWin32]::VK_LEFT) $wantLeft; $leftHeld = $wantLeft }
                    if ($wantRight -ne $rightHeld) { Set-KeyState ([RctWin32]::VK_RIGHT) $wantRight; $rightHeld = $wantRight }
                    if ($wantUp -ne $upHeld) { Set-KeyState ([RctWin32]::VK_UP) $wantUp; $upHeld = $wantUp }
                    if ($wantDown -ne $downHeld) { Set-KeyState ([RctWin32]::VK_DOWN) $wantDown; $downHeld = $wantDown }
                }
            }
        } else {
            Release-EdgeKeys
            Release-CursorClip
        }

        Start-Sleep -Milliseconds 10
    }
}
finally {
    Release-EdgeKeys
    Release-CursorClip
}
