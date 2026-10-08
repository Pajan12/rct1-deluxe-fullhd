$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$rct = Join-Path $root "RCT.EXE"
$unpacked = Join-Path $root "RCT-unpacked.exe"
$backup = Join-Path $root "RCT.original.exe"

function Show-Info([string]$text) {
    Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
    [System.Windows.MessageBox]::Show($text, "RCT1 Deluxe Full HD") | Out-Null
}

function Find-Pattern([byte[]]$data, [byte[]]$pattern) {
    $hits = New-Object System.Collections.Generic.List[int]
    if ($pattern.Length -eq 0 -or $data.Length -lt $pattern.Length) { return $hits }

    for ($i = 0; $i -le $data.Length - $pattern.Length; $i++) {
        $ok = $true
        for ($j = 0; $j -lt $pattern.Length; $j++) {
            if ($data[$i + $j] -ne $pattern[$j]) {
                $ok = $false
                break
            }
        }
        if ($ok) { $hits.Add($i) }
    }
    return $hits
}

function Hex([string]$s) {
    return [byte[]]($s -split ' ' | ForEach-Object { [Convert]::ToByte($_, 16) })
}

$oldW = Hex "81 7D FC 00 05 00 00 7E 07 C7 45 FC 00 05 00 00"
$newW = Hex "81 7D FC 80 07 00 00 7E 07 C7 45 FC 80 07 00 00"
$oldH = Hex "81 7D F4 00 04 00 00 7E 07 C7 45 F4 00 04 00 00"
$newH = Hex "81 7D F4 38 04 00 00 7E 07 C7 45 F4 38 04 00 00"

if (-not (Test-Path $rct)) {
    Show-Info "RCT.EXE was not found.`n`nExtract/copy this release into the RollerCoaster Tycoon Deluxe installation folder, next to RCT.EXE."
    exit 1
}

$current = [System.IO.File]::ReadAllBytes($rct)
$oldWHits = Find-Pattern $current $oldW
$oldHHits = Find-Pattern $current $oldH
$newWHits = Find-Pattern $current $newW
$newHHits = Find-Pattern $current $newH

if ($newWHits.Count -eq 1 -and $newHHits.Count -eq 1) {
    Write-Host "RCT.EXE is already patched for 1920x1080."
}
elseif ($oldWHits.Count -eq 1 -and $oldHHits.Count -eq 1) {
    if (-not (Test-Path $backup)) {
        Copy-Item $rct $backup
        Write-Host "Backup created: RCT.original.exe"
    }

    $data = [System.IO.File]::ReadAllBytes($rct)
    [Array]::Copy($newW, 0, $data, $oldWHits[0], $newW.Length)
    [Array]::Copy($newH, 0, $data, $oldHHits[0], $newH.Length)
    [System.IO.File]::WriteAllBytes($rct, $data)
    Write-Host "RCT.EXE patched to allow a 1920x1080 window."
}
elseif (Test-Path $unpacked) {
    $u = [System.IO.File]::ReadAllBytes($unpacked)
    $uOldW = Find-Pattern $u $oldW
    $uOldH = Find-Pattern $u $oldH
    $uNewW = Find-Pattern $u $newW
    $uNewH = Find-Pattern $u $newH

    if ($uNewW.Count -eq 1 -and $uNewH.Count -eq 1) {
        if (-not (Test-Path $backup)) {
            Copy-Item $rct $backup
            Write-Host "Backup created: RCT.original.exe"
        }
        Copy-Item $unpacked $rct -Force
        Write-Host "Installed already-patched RCT-unpacked.exe as RCT.EXE."
    }
    elseif ($uOldW.Count -eq 1 -and $uOldH.Count -eq 1) {
        if (-not (Test-Path $backup)) {
            Copy-Item $rct $backup
            Write-Host "Backup created: RCT.original.exe"
        }
        [Array]::Copy($newW, 0, $u, $uOldW[0], $newW.Length)
        [Array]::Copy($newH, 0, $u, $uOldH[0], $newH.Length)
        [System.IO.File]::WriteAllBytes($rct, $u)
        Write-Host "RCT-unpacked.exe patched and installed as RCT.EXE."
    }
    else {
        Show-Info "RCT-unpacked.exe was found, but it does not match the supported English Deluxe 1.20.015 layout.`n`nNo game file was modified."
        exit 2
    }
}
else {
    Show-Info @"
This RCT.EXE appears to be packed (the English Steam/GOG Deluxe 1.20.015 executable is typically NeoLite-packed).

This project intentionally does NOT redistribute RCT.EXE.

Create an unpacked copy from your own legally installed RCT.EXE, name it:

RCT-unpacked.exe

place it in this game folder, and run Install-RCT-FullHD.cmd again.

See UNPACKING.md for details.
"@
    exit 3
}

$layers = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (-not (Test-Path $layers)) { New-Item -Path $layers -Force | Out-Null }
New-ItemProperty -Path $layers -Name $rct -Value "~ RUNASADMIN 16BITCOLOR HIGHDPIAWARE WINXPSP3" -PropertyType String -Force | Out-Null

Write-Host ""
Write-Host "Installation complete."
Write-Host "Start the game with Start-RCT-FullHD.cmd"
Show-Info "Installation complete.`n`nStart RollerCoaster Tycoon with:`nStart-RCT-FullHD.cmd"
