$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
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

[System.Windows.MessageBox]::Show(
    "Original RCT.EXE restored.",
    "RCT1 Deluxe Full HD"
) | Out-Null
