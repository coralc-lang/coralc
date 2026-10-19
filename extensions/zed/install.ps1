# Install the Coral extension into Zed on Windows.
#
# The artifact is prebuilt: it contains extension.wasm, the tree-sitter
# grammar, queries and an index entry. Rust, clang and tree-sitter are NOT
# needed. Restart Zed afterwards.
#
# Usage:
#   .\install.ps1
#   .\install.ps1 -DataDir "$env:LOCALAPPDATA\Zed"
#   .\install.ps1 -Version 0.4.0
#   .\install.ps1 -File .\coral-zed-0.4.0.tar.gz
#
# From the web:
#   irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.ps1 | iex
param(
    [string]$DataDir = "",
    [string]$Version = "",
    [string]$Url = "",
    [string]$File = ""
)

$ErrorActionPreference = "Stop"
$base = if ($env:CORAL_EXTENSIONS_BASE) {
    $env:CORAL_EXTENSIONS_BASE
} else {
    "https://raw.githubusercontent.com/coralc-lang/coralc/main"
}

if (-not $DataDir) {
    $DataDir = Join-Path $env:LOCALAPPDATA "Zed"
}
$extRoot = Join-Path $DataDir "extensions"
$dest = Join-Path $extRoot "installed\coral"
New-Item -ItemType Directory -Force -Path (Join-Path $extRoot "installed") | Out-Null

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("coral-zed-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
    $archive = Join-Path $tmp "coral-zed.tar.gz"
    if ($File) {
        if (-not (Test-Path $File)) { throw "no such file: $File" }
        Copy-Item -Force $File $archive
    } else {
        if (-not $Version -and -not $Url) {
            if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "VERSION"))) {
                $Version = (Get-Content (Join-Path $PSScriptRoot "VERSION") -Raw).Trim()
            } else {
                try {
                    $Version = (Invoke-WebRequest -UseBasicParsing -Uri "$base/extensions/zed/VERSION").Content.Trim()
                } catch {
                    throw "cannot determine the latest version; pass -Version"
                }
            }
        }
        if (-not $Url) {
            $Url = "$base/extensions/zed/coral-zed-$Version.tar.gz"
        }
        Write-Host "downloading $Url"
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $archive
    }

    $bytes = [System.IO.File]::ReadAllBytes($archive)
    if ($bytes.Length -lt 2 -or $bytes[0] -ne 0x1f -or $bytes[1] -ne 0x8b) {
        throw "downloaded file is not a gzip archive"
    }

    $unpack = Join-Path $tmp "unpack"
    New-Item -ItemType Directory -Force -Path $unpack | Out-Null
    tar -xzf $archive -C $unpack
    if ($LASTEXITCODE -ne 0) { throw "could not extract the extension archive" }
    foreach ($f in @("extension.toml", "extension.wasm", "grammars\coral.wasm", "index-entry.json")) {
        if (-not (Test-Path (Join-Path $unpack $f))) {
            throw "package is missing $f"
        }
    }

    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -Recurse -Force (Join-Path $unpack "*") $dest

    $indexPath = Join-Path $extRoot "index.json"
    $entry = Get-Content (Join-Path $dest "index-entry.json") -Raw | ConvertFrom-Json
    if (Test-Path $indexPath) {
        Copy-Item -Force $indexPath "$indexPath.pre-coral.bak"
        $index = Get-Content $indexPath -Raw | ConvertFrom-Json
    } else {
        $index = New-Object PSObject
    }

    foreach ($name in @("extensions", "languages", "icon_themes", "themes")) {
        if (-not $index.PSObject.Properties[$name]) {
            $index | Add-Member -NotePropertyName $name -NotePropertyValue (New-Object PSObject)
        }
    }
    $index.extensions | Add-Member -NotePropertyName coral `
        -NotePropertyValue $entry.extension -Force
    foreach ($lang in $entry.language.PSObject.Properties) {
        $index.languages | Add-Member -NotePropertyName $lang.Name `
            -NotePropertyValue $lang.Value -Force
    }
    foreach ($icon in $entry.icon_theme.PSObject.Properties) {
        $index.icon_themes | Add-Member -NotePropertyName $icon.Name `
            -NotePropertyValue $icon.Value -Force
    }

    $json = $index | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($indexPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "registered coral in $indexPath"
    Write-Host "installed: $dest"

    if (-not (Get-Command coralc.exe -ErrorAction SilentlyContinue) -and
        -not (Get-Command coralc -ErrorAction SilentlyContinue)) {
        Write-Host "note: coralc is not on PATH; syntax highlighting works but the"
        Write-Host "      language server needs the compiler installer."
    }
    Write-Host "restart Zed to load the extension"
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
