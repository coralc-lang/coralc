# coralc installer for Windows: download (or use the current checkout),
# build, and install into $env:USERPROFILE\.coral.
# Requires git, make (w64devkit/mingw-w64) and gcc on PATH.
# Run from the web:
#   irm https://raw.githubusercontent.com/coralc-lang/coralc/main/install.ps1 | iex
param([string]$Prefix = "$env:USERPROFILE\.coral")

$ErrorActionPreference = "Stop"

$src = $null
try {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) { $src = Split-Path -Parent $scriptPath }
} catch { $src = $null }
if (-not $src) { $src = (Get-Location).Path }

$tmp = $null
if (-not (Test-Path (Join-Path $src "compiler\coral.crlb"))) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required to download the repository"
    }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("coralc-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    git clone --depth 1 https://github.com/coralc-lang/coralc.git (Join-Path $tmp "coralc")
    $src = Join-Path $tmp "coralc"
}

Push-Location $src
try {
    $make = Get-Command make -ErrorAction SilentlyContinue
    $gcc = Get-Command gcc -ErrorAction SilentlyContinue
    if (-not $gcc) { throw "gcc not found; install w64devkit or mingw-w64 and put it on PATH" }

    if ($make) {
        & make windows
        if ($LASTEXITCODE -ne 0) { throw "building coralc failed" }
        & make install "PREFIX=$Prefix"
        if ($LASTEXITCODE -ne 0) { throw "installing coralc failed" }
    } else {
        if (-not (Test-Path "dist\coralc-windows.c")) {
            throw "dist\coralc-windows.c missing; run package.sh on a build host first"
        }
        $bin = "dist\coralc-windows-x86_64.exe"
        & gcc -std=gnu11 -O0 -o $bin dist\coralc-windows.c -lm
        if ($LASTEXITCODE -ne 0) { throw "bootstrapping the compiler failed" }
        New-Item -ItemType Directory -Force -Path (Join-Path $Prefix "bin") | Out-Null
        Copy-Item $bin (Join-Path $Prefix "bin\coralc.exe") -Force
        if (Test-Path (Join-Path $Prefix "lib")) { Remove-Item -Recurse -Force (Join-Path $Prefix "lib") }
        Copy-Item -Recurse .\lib (Join-Path $Prefix "lib")
    }

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $binDir = Join-Path $Prefix "bin"
    $parts = @()
    if ($userPath) { $parts = $userPath -split ";" }
    if (-not ($parts | Where-Object { $_ -ieq $binDir })) {
        $newPath = if ($userPath) { "$binDir;$userPath" } else { $binDir }
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "added $binDir to the user PATH (open a new shell)"
    }
    $env:Path = "$binDir;$env:Path"

    Write-Host ""
    Write-Host "coralc installed to $binDir\coralc.exe"
    & (Join-Path $binDir "coralc.exe") --version
    Write-Host ""
    Write-Host "editor support:"
    Write-Host "  Zed:            irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.ps1 | iex"
    Write-Host "  VS Code / fork: irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.ps1 | iex"
}
finally {
    Pop-Location
    if ($tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
}
