$ErrorActionPreference = "Stop"

$patchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $patchDir
$rct = Join-Path $root "RCT.EXE"
$backup = Join-Path $root "RCT.original.exe"

Add-Type -AssemblyName PresentationFramework

if (-not (Test-Path $backup)) {
    [System.Windows.MessageBox]::Show(
        "RCT.original.exe was not found. Nothing was restored.",
        "RCT1 Deluxe Full HD"
    ) | Out-Null
    exit 1
}

Copy-Item $backup $rct -Force

$layers = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (Test-Path $layers) {
    Remove-ItemProperty -Path $layers -Name $rct -ErrorAction SilentlyContinue
}

# Remove the Desktop shortcut created by the installer.
try {
    $shell = New-Object -ComObject WScript.Shell
    $desktop = $shell.SpecialFolders.Item("Desktop")
    $shortcutPath = Join-Path $desktop "RollerCoaster Tycoon FullHD.lnk"
    Remove-Item $shortcutPath -Force -ErrorAction SilentlyContinue
}
catch {}

[System.Windows.MessageBox]::Show(
    "Original RCT.EXE restored.",
    "RCT1 Deluxe Full HD"
) | Out-Null
