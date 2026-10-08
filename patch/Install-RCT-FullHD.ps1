$ErrorActionPreference = "Stop"

# RCT1 Deluxe Full HD installer
# The common English Steam/GOG Deluxe 1.20.015 executable is NeoLite-packed.
# This installer unpacks it automatically using temporary open-source tools.

function Show-Info([string]$text) {
    Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
    [System.Windows.MessageBox]::Show($text, "RCT1 Deluxe Full HD") | Out-Null
}

function Ensure-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Start-Process powershell.exe -Verb RunAs -ArgumentList $args
        exit
    }
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

function Download-File([string]$url, [string]$destination, [string]$label) {
    Write-Host "Downloading $label..."
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $destination
    if (-not (Test-Path $destination)) {
        throw "Download failed: $label"
    }
}

function Get-PatternState([byte[]]$data, [byte[]]$oldW, [byte[]]$oldH, [byte[]]$newW, [byte[]]$newH) {
    $oldWHits = Find-Pattern $data $oldW
    $oldHHits = Find-Pattern $data $oldH
    $newWHits = Find-Pattern $data $newW
    $newHHits = Find-Pattern $data $newH

    if ($newWHits.Count -eq 1 -and $newHHits.Count -eq 1) {
        return @{
            State = "patched"
            WidthOffset = $newWHits[0]
            HeightOffset = $newHHits[0]
        }
    }

    if ($oldWHits.Count -eq 1 -and $oldHHits.Count -eq 1) {
        return @{
            State = "patchable"
            WidthOffset = $oldWHits[0]
            HeightOffset = $oldHHits[0]
        }
    }

    return @{
        State = "unsupported"
        WidthOffset = -1
        HeightOffset = -1
    }
}

function Patch-Bytes(
    [byte[]]$data,
    [byte[]]$newW,
    [byte[]]$newH,
    [int]$widthOffset,
    [int]$heightOffset
) {
    [Array]::Copy($newW, 0, $data, $widthOffset, $newW.Length)
    [Array]::Copy($newH, 0, $data, $heightOffset, $newH.Length)
    return $data
}

function Auto-Unpack-NeoLite([string]$inputExe, [string]$outputExe) {
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("RCT1-FullHD-" + [guid]::NewGuid().ToString("N"))
    $pythonDir = Join-Path $tempRoot "python"
    $peSrcDir = Join-Path $tempRoot "pefile-src"

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null
    New-Item -ItemType Directory -Path $peSrcDir -Force | Out-Null

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Pinned upstream versions.
        $pythonVersion = "3.10.11"
        $pythonZipUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-embed-amd64.zip"

        # RCT1's Steam/GOG executable uses the ExeLock variant of NeoLite.
        # This pinned fork commit adds the required Deflate64/ExeLock support.
        $neoliteCommit = "4c8e0166af65f4a5410cd6a011489e04ffee1bbd"
        $neoliteUrl = "https://raw.githubusercontent.com/ZenoArrows/Neo-Executable-Decompressor/$neoliteCommit/neolite_unpack.py"

        $pefileVersion = "v2023.2.7"
        $pefileZipUrl = "https://github.com/erocarrera/pefile/archive/refs/tags/$pefileVersion.zip"

        $deflateVersion = "0.2.0"
        $deflateMetadataUrl = "https://pypi.org/pypi/zipfile-deflate64/$deflateVersion/json"
        $deflateWheelName = "zipfile_deflate64-0.2.0-cp310-cp310-win_amd64.whl"

        $pythonZip = Join-Path $tempRoot "python.zip"
        $pefileZip = Join-Path $tempRoot "pefile.zip"
        $deflateZip = Join-Path $tempRoot "deflate64.zip"
        $neoliteScript = Join-Path $pythonDir "neolite_unpack.py"

        Download-File $pythonZipUrl $pythonZip "temporary Python runtime from python.org"
        Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force

        Download-File $pefileZipUrl $pefileZip "pefile dependency from GitHub"
        Expand-Archive -Path $pefileZip -DestinationPath $peSrcDir -Force

        $peRoot = Get-ChildItem -Path $peSrcDir -Directory | Select-Object -First 1
        if ($null -eq $peRoot) {
            throw "Could not locate the extracted pefile source."
        }

        Copy-Item (Join-Path $peRoot.FullName "pefile.py") (Join-Path $pythonDir "pefile.py") -Force
        Copy-Item (Join-Path $peRoot.FullName "ordlookup") (Join-Path $pythonDir "ordlookup") -Recurse -Force

        Write-Host "Resolving zipfile-deflate64 $deflateVersion from PyPI..."
        $deflateMeta = Invoke-RestMethod -UseBasicParsing -Uri $deflateMetadataUrl
        $deflateWheel = $deflateMeta.urls | Where-Object { $_.filename -eq $deflateWheelName } | Select-Object -First 1
        if ($null -eq $deflateWheel) {
            throw "Could not locate the required Windows CPython 3.10 zipfile-deflate64 wheel on PyPI."
        }

        Download-File $deflateWheel.url $deflateZip "zipfile-deflate64 $deflateVersion from PyPI"
        $actualDeflateHash = (Get-FileHash -Algorithm SHA256 -Path $deflateZip).Hash.ToLowerInvariant()
        $expectedDeflateHash = $deflateWheel.digests.sha256.ToLowerInvariant()
        if ($actualDeflateHash -ne $expectedDeflateHash) {
            throw "SHA-256 verification failed for zipfile-deflate64."
        }
        Expand-Archive -Path $deflateZip -DestinationPath $pythonDir -Force

        Download-File $neoliteUrl $neoliteScript "ExeLock-compatible NeoLite unpacker from GitHub"

        $pythonExe = Join-Path $pythonDir "python.exe"
        if (-not (Test-Path $pythonExe)) {
            throw "Temporary Python runtime was not extracted correctly."
        }

        Write-Host "Unpacking the original RCT.EXE..."
        & $pythonExe $neoliteScript $inputExe $outputExe
        if ($LASTEXITCODE -ne 0) {
            throw "NeoLite unpacker returned exit code $LASTEXITCODE."
        }

        if (-not (Test-Path $outputExe)) {
            throw "NeoLite unpacker did not create an output file."
        }

        if ((Get-Item $outputExe).Length -lt 2000000) {
            throw "The unpacked executable is unexpectedly small."
        }
    }
    finally {
        Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Ensure-Administrator

$patchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $patchDir
$rct = Join-Path $root "RCT.EXE"
$backup = Join-Path $root "RCT.original.exe"

# Known English Deluxe 1.20.015 unpacked window-size checks.
$oldW = Hex "81 7D FC 00 05 00 00 7E 07 C7 45 FC 00 05 00 00"
$newW = Hex "81 7D FC 80 07 00 00 7E 07 C7 45 FC 80 07 00 00"
$oldH = Hex "81 7D F4 00 04 00 00 7E 07 C7 45 F4 00 04 00 00"
$newH = Hex "81 7D F4 38 04 00 00 7E 07 C7 45 F4 38 04 00 00"

try {
    if (-not (Test-Path $rct)) {
        throw "RCT.EXE was not found. Extract/copy this release into the RollerCoaster Tycoon Deluxe installation folder, next to RCT.EXE."
    }

    Write-Host "Checking RCT.EXE..."
    $current = [System.IO.File]::ReadAllBytes($rct)
    $state = Get-PatternState $current $oldW $oldH $newW $newH

    if ($state.State -eq "patched") {
        Write-Host "RCT.EXE is already patched for 1920x1080."
    }
    elseif ($state.State -eq "patchable") {
        if (-not (Test-Path $backup)) {
            Copy-Item $rct $backup
            Write-Host "Backup created: RCT.original.exe"
        }

        $patched = Patch-Bytes $current $newW $newH $state.WidthOffset $state.HeightOffset
        [System.IO.File]::WriteAllBytes($rct, $patched)
        Write-Host "RCT.EXE patched to allow a 1920x1080 window."
    }
    else {
        # The common English Steam/GOG build is NeoLite-packed.
        # Generate the unpacked copy automatically; the user does not need to
        # rename files or run any command manually.
        $generated = Join-Path ([IO.Path]::GetTempPath()) ("RCT-unpacked-" + [guid]::NewGuid().ToString("N") + ".exe")

        try {
            Write-Host "Packed RCT.EXE detected."
            Write-Host "Preparing automatic unpacking (Internet connection required)..."
            Auto-Unpack-NeoLite $rct $generated

            Write-Host "Validating unpacked executable..."
            $unpacked = [System.IO.File]::ReadAllBytes($generated)
            $unpackedState = Get-PatternState $unpacked $oldW $oldH $newW $newH

            if ($unpackedState.State -eq "unsupported") {
                throw "The unpacked executable does not match the supported English RollerCoaster Tycoon Deluxe 1.20.015 layout. No game file was modified."
            }

            if (-not (Test-Path $backup)) {
                Copy-Item $rct $backup
                Write-Host "Backup created: RCT.original.exe"
            }

            if ($unpackedState.State -eq "patchable") {
                $unpacked = Patch-Bytes $unpacked $newW $newH $unpackedState.WidthOffset $unpackedState.HeightOffset
            }

            [System.IO.File]::WriteAllBytes($rct, $unpacked)
            Write-Host "Unpacked and patched RCT.EXE installed."
        }
        finally {
            Remove-Item $generated -Force -ErrorAction SilentlyContinue
        }
    }

    # Compatibility combination verified on Windows 11:
    # XP SP3 + 16-bit colour + application DPI + elevated game process.
    $layers = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    if (-not (Test-Path $layers)) {
        New-Item -Path $layers -Force | Out-Null
    }

    New-ItemProperty `
        -Path $layers `
        -Name $rct `
        -Value "~ RUNASADMIN 16BITCOLOR HIGHDPIAWARE WINXPSP3" `
        -PropertyType String `
        -Force | Out-Null

    Write-Host ""
    Write-Host "Installation complete."
    Write-Host "Start the game with Start-RCT-FullHD.cmd"

    Show-Info @"
Installation complete.

The installer created/kept a backup of the original game executable as:
RCT.original.exe

Start RollerCoaster Tycoon with:
Start-RCT-FullHD.cmd
"@
}
catch {
    $message = $_.Exception.Message
    Write-Host ""
    Write-Host "Installation failed: $message" -ForegroundColor Red
    Show-Info "Installation failed:`n`n$message"
    exit 1
}
