# Sync-FromCefDistribution.ps1 -Distribution <path>
# Replace this repo's contents with the build-time half of a CEF binary distribution.
#
# EVERYTHING HERE IS GENERATED. Nothing in include/, libcef_dll/ or Release/ is edited by hand: a change
# belongs in the CEF fork and arrives here by running this against a distribution built from it. The script
# DELETES those directories before copying, so a file that disappeared upstream disappears here too rather
# than lingering as a stale header nobody notices.
param(
    [Parameter(Mandatory = $true)][string]$Distribution
)
$ErrorActionPreference = 'Stop'

foreach ($required in @('include', 'libcef_dll', 'Release\libcef.lib', 'LICENSE.txt')) {
    if (-not (Test-Path (Join-Path $Distribution $required))) {
        throw "Not a CEF distribution: '$Distribution' has no '$required'."
    }
}

$root = $PSScriptRoot

foreach ($stale in @('include', 'libcef_dll', 'Release')) {
    Remove-Item (Join-Path $root $stale) -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force -Path (Join-Path $root 'Release') | Out-Null

Copy-Item (Join-Path $Distribution 'include')    $root -Recurse
Copy-Item (Join-Path $Distribution 'libcef_dll') $root -Recurse
Copy-Item (Join-Path $Distribution 'Release\libcef.lib') (Join-Path $root 'Release')
Copy-Item (Join-Path $Distribution 'LICENSE.txt') $root -Force

# THE VERSION, recorded from the headers rather than from the folder name, which a consumer may have renamed.
$version = (Select-String -Path (Join-Path $root 'include\cef_version.h') -Pattern '#define CEF_VERSION "(.*)"').Matches.Groups[1].Value
Set-Content (Join-Path $root 'CEF_VERSION') $version

$size = (Get-ChildItem $root -Recurse -File -Exclude '.git*' | Measure-Object Length -Sum).Sum / 1MB
Write-Output ("cef-sdk: CEF {0}, {1:N1} MB" -f $version, $size)
Write-Output "Review with git status, then commit. The commit IS the version a consumer pins."
