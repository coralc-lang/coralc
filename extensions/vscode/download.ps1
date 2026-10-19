# Download the Coral VS Code extension (.vsix) into your Downloads folder.
#
# This script intentionally does NOT install anything. The .vsix works in
# VS Code, VSCodium, Cursor, Windsurf, Positron, Kiro and other VS Code
# forks; open the file in your editor, or use its own CLI:
#
#   code --install-extension "$env:USERPROFILE\Downloads\coral-<version>.vsix"
#
# Usage:
#   .\download.ps1 [-OutDir DIR] [-Version VERSION] [-Force]
#
# From the web:
#   irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.ps1 | iex
param(
    [string]$OutDir = "",
    [string]$Version = "",
    [string]$Url = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$base = if ($env:CORAL_EXTENSIONS_BASE) {
    $env:CORAL_EXTENSIONS_BASE
} else {
    "https://raw.githubusercontent.com/coralc-lang/coralc/main"
}

if (-not $OutDir) {
    try {
        $OutDir = (New-Object -ComObject Shell.Application).NameSpace("shell:Downloads").Self.Path
    } catch {
        $OutDir = Join-Path $env:USERPROFILE "Downloads"
    }
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if (-not $Version -and -not $Url) {
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "VERSION"))) {
        $Version = (Get-Content (Join-Path $PSScriptRoot "VERSION") -Raw).Trim()
    } else {
        try {
            $Version = (Invoke-WebRequest -UseBasicParsing -Uri "$base/extensions/vscode/VERSION").Content.Trim()
        } catch {
            throw "cannot determine the latest version; pass -Version"
        }
    }
}

if (-not $Url) {
    $Url = "$base/extensions/vscode/coral-$Version.vsix"
}

$name = Split-Path -Leaf $Url
$dest = Join-Path $OutDir $name
if ((Test-Path $dest) -and -not $Force) {
    Write-Host "already downloaded: $dest"
    Write-Host "use -Force to download it again"
    return
}

$tmp = "$dest.part"
Write-Host "downloading $Url"
try {
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $tmp
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 4 -or $bytes[0] -ne 0x50 -or $bytes[1] -ne 0x4b) {
        throw "downloaded file is not a .vsix (zip) archive"
    }
    Move-Item -Force $tmp $dest
} finally {
    if (Test-Path $tmp) { Remove-Item -Force $tmp -ErrorAction SilentlyContinue }
}

$size = (Get-Item $dest).Length
Write-Host "saved: $dest ($size bytes)"
Write-Host ""
Write-Host "Install it in your editor (VS Code or any fork):"
Write-Host "  code --install-extension `"$dest`""
