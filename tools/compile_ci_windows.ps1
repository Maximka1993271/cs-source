$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$src = Join-Path $root "addons\sourcemod\scripting"
$out = Join-Path $root "ci-build\plugins"
$spcomp = $null
if ($env:SPCOMP -and (Test-Path $env:SPCOMP)) {
    $spcomp = Get-Item $env:SPCOMP
} else {
    $spcomp = Get-ChildItem -Path (Join-Path $root "sm") -Filter "spcomp.exe" -Recurse | Select-Object -First 1
}
if (-not $spcomp) { throw "spcomp.exe was not found. Set SPCOMP or provide the SourceMod package in .\sm" }
New-Item -ItemType Directory -Force -Path $out | Out-Null
$failed = $false
Get-ChildItem $src -Filter "is_*.sp" | Sort-Object Name | ForEach-Object {
    Write-Host "[SPCOMP] $($_.Name)"
    $output = & $spcomp.FullName -i"$src\include" $_.FullName -o"$out\$($_.BaseName).smx" 2>&1
    $exitCode = $LASTEXITCODE
    $log = ($output | Out-String)
    Write-Host $log
    if ($exitCode -ne 0) { $failed = $true; return }
    if ($log -match '(?im)\bwarning\s+[0-9]+\s*:') { $failed = $true; return }
}
if ($failed) { throw "Build failed or compiler emitted warnings." }
Write-Host "Clean SourcePawn build completed."
