@echo off
setlocal EnableExtensions

rem Iron Sentinel Core 1.1.2 - runtime startup fixes
rem Rebuilds only the modules changed for the reported startup errors.

set "ROOT=%~dp0.."
set "SCRIPT_DIR=%ROOT%\addons\sourcemod\scripting"
set "PLUGIN_DIR=%ROOT%\addons\sourcemod\plugins"
set "INCLUDE_DIR=%SCRIPT_DIR%\include"

if defined SPCOMP goto :have_compiler
if exist "%SCRIPT_DIR%\spcomp.exe" (
    set "SPCOMP=%SCRIPT_DIR%\spcomp.exe"
    goto :have_compiler
)
echo ERROR: spcomp.exe not found.
echo Set SPCOMP to your SourceMod 1.12 compiler, for example:
echo   set SPCOMP=D:\path\to\spcomp.exe
exit /b 2

:have_compiler
if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

pushd "%SCRIPT_DIR%" || exit /b 3
for %%F in (is_core.sp is_antismoke.sp is_banlist.sp) do (
    echo [SPCOMP] %%F
    "%SPCOMP%" -i"%INCLUDE_DIR%" "%%~fF" -o"%PLUGIN_DIR%\%%~nF.smx"
    if errorlevel 1 (
        echo FAILED: %%F
        popd
        exit /b 1
    )
)
popd

echo.
echo Runtime-fix build complete.
echo Replace these server files:
echo   addons\sourcemod\plugins\is_core.smx
echo   addons\sourcemod\plugins\is_antismoke.smx
echo   addons\sourcemod\plugins\is_banlist.smx
exit /b 0
