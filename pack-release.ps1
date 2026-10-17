# Builds the install zip the game expects: bin, mods, and dlc at the root.
# Scripts come from src. The mod bundle comes from build\mod000Spectre\content,
# made by bundle\build_bundle.py. Strings (built from strings\*.csv), 000Spectre.xml, and
# dlc000Spectre come from this repo.
#
#   .\pack-release.ps1 -Version 0.94 -Base "C:\path\to\Spectre.-.Release.-.v0.93.zip"
#   .\pack-release.ps1 -Version 0.94 -Bundle "C:\path\to\folder-or-zip-or-url"
#   .\pack-release.ps1 -Version 0.94      (reuses the bundle already in build)
#
# -Bundle takes the finished bundle (blob0.bundle + metadata.store) that is
# published with the release as Spectre-bundle-v<Version>.zip. It can be a
# folder, a zip, or an https URL to that zip. Python is not needed. The files
# are checked against bundle\bundle.sha256 before they are used.

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    # Spectre v0.93 release zip or folder. When given, the bundle is rebuilt first.
    [string]$Base,

    # The finished bundle: folder, zip, or https URL of a zip. No Python needed.
    [string]$Bundle
)

$ErrorActionPreference = "Stop"
$Version = $Version.Trim().TrimStart("v", "V")
if ($Version -notmatch "^[0-9]") {
    throw "Version must look like 0.94, not '$Version'."
}

$Root = $PSScriptRoot
$BuildDir = Join-Path $Root "build\mod000Spectre\content"

if ($Bundle) {
    $tmp = Join-Path $Root "build\bundle-download"
    $src = $Bundle
    if ($src -match "^https?://") {
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        $src = Join-Path $tmp "bundle.zip"
        Invoke-WebRequest -Uri $Bundle -OutFile $src
    }
    if (Test-Path -LiteralPath $src -PathType Leaf) {
        $dir = Join-Path $tmp "unzipped"
        if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($src, $dir)
        $src = $dir
    }
    $found = Get-ChildItem -LiteralPath $src -Recurse -Filter "blob0.bundle" | Select-Object -First 1
    if (-not $found) { throw "No blob0.bundle found in $Bundle" }
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    foreach ($n in @("blob0.bundle", "metadata.store")) {
        $f = Join-Path $found.DirectoryName $n
        if (-not (Test-Path -LiteralPath $f)) { throw "Missing $n next to blob0.bundle in $Bundle" }
        Copy-Item -LiteralPath $f -Destination (Join-Path $BuildDir $n) -Force
    }
    foreach ($line in Get-Content -LiteralPath (Join-Path $Root "bundle\bundle.sha256")) {
        if ($line -match "^([0-9a-fA-F]{64})\s+\*?(\S+)$") {
            $got = (Get-FileHash -LiteralPath (Join-Path $BuildDir $Matches[2]) -Algorithm SHA256).Hash
            if ($got -ne $Matches[1].ToUpper()) { throw "$($Matches[2]) does not match bundle\bundle.sha256. Wrong bundle version?" }
        }
    }
    Write-Output "Bundle checked and copied to build."
}

if ($Base) {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
    if (-not $python) { throw "Python is needed to build the bundle." }
    & $python.Source (Join-Path $Root "bundle\build_bundle.py") --base $Base --out $BuildDir
    if ($LASTEXITCODE -ne 0) { throw "bundle\build_bundle.py failed." }
}

$Scripts = Join-Path $Root "src"
$Bundle = Join-Path $BuildDir "blob0.bundle"
$Metadata = Join-Path $BuildDir "metadata.store"
$StringsDir = Join-Path $Root "strings"
$MenuXml = Join-Path $Root "bin\config\r4game\user_config_matrix\pc\000Spectre.xml"
$DlcContent = Join-Path $Root "dlc\dlc000Spectre\content"
$OutDir = Join-Path $Root "dist"
$ZipPath = Join-Path $OutDir "Spectre.-.Release.-.v$Version.zip"

function Require-Path([string]$Path, [string]$Why) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Why`nMissing: $Path"
    }
}

Require-Path $Scripts "The repo has no src folder."
Require-Path $Bundle "Build the mod bundle first: pass -Bundle with the published bundle, or -Base with the Spectre v0.93 release."
Require-Path $Metadata "Build the mod bundle first: pass -Bundle with the published bundle, or -Base with the Spectre v0.93 release."
Require-Path $StringsDir "The repo has no strings folder."
Require-Path $MenuXml "The repo has no bin menu file for Spectre."
Require-Path $DlcContent "The repo has no dlc\dlc000Spectre\content."

# The .w3strings are built from strings\en.csv and strings\es.csv, so an edit in a .csv always ships.
# Without Python, the .w3strings already in the repo are used as they are.
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
if ($python) {
    & $python.Source (Join-Path $StringsDir "build_w3strings.py")
    if ($LASTEXITCODE -ne 0) { throw "strings\build_w3strings.py failed." }
} else {
    Write-Warning "Python not found: the .w3strings are not rebuilt from the .csv files."
}

$Strings = @(Get-ChildItem -LiteralPath $StringsDir -Filter "*.w3strings" -File)
if ($Strings.Count -eq 0) {
    throw "No .w3strings files in $StringsDir"
}
foreach ($name in @("blob0.bundle", "metadata.store", "texture.cache")) {
    Require-Path (Join-Path $DlcContent $name) "dlc000Spectre is missing $name."
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
$scriptCount = 0
try {
    function Add-Entry([string]$Source, [string]$EntryName) {
        $EntryName = ($EntryName -replace "\\", "/").TrimStart("/")
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $Source,
            $EntryName,
            [System.IO.Compression.CompressionLevel]::Optimal)
    }

    Add-Entry $MenuXml "bin/config/r4game/user_config_matrix/pc/000Spectre.xml"
    Add-Entry $Bundle "mods/mod000Spectre/content/blob0.bundle"
    Add-Entry $Metadata "mods/mod000Spectre/content/metadata.store"
    foreach ($file in $Strings) {
        Add-Entry $file.FullName "mods/mod000Spectre/content/$($file.Name)"
    }

    Get-ChildItem -LiteralPath $Scripts -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($Scripts.Length).TrimStart("\", "/")
        Add-Entry $_.FullName "mods/mod000Spectre/content/scripts/$relative"
        $script:scriptCount++
    }

    foreach ($name in @("blob0.bundle", "metadata.store", "texture.cache")) {
        Add-Entry (Join-Path $DlcContent $name) "dlc/dlc000Spectre/content/$name"
    }
}
finally {
    $zip.Dispose()
}

$zipInfo = Get-Item -LiteralPath $ZipPath
Write-Output "Wrote $($zipInfo.FullName)"
Write-Output ("{0:N1} MB, {1} scripts, {2} string files" -f ($zipInfo.Length / 1MB), $scriptCount, $Strings.Count)
