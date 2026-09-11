$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot "skills"

if ($env:CODEX_HOME) {
    $target = Join-Path $env:CODEX_HOME "skills"
} else {
    $target = Join-Path $HOME ".codex\skills"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null

Get-ChildItem -Path $source -Directory | ForEach-Object {
    $dest = Join-Path $target $_.Name
    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }
    Copy-Item -Recurse -Force $_.FullName $dest
    Write-Host "Installed $($_.Name) -> $dest"
}

Write-Host "Done. Reload/restart Codex if needed."
