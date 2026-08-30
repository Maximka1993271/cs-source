$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $env:SPCOMP) {
    $candidates = @(
        (Join-Path $root "spcomp.exe"),
        (Join-Path $root "addons\sourcemod\scripting\spcomp.exe")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { $env:SPCOMP = $candidate; break }
    }
}
& (Join-Path $root "tools\compile_ci_windows.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
