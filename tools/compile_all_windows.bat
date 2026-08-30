@echo off
setlocal EnableExtensions

rem Iron Sentinel Core - SourcePawn batch compiler for Windows
rem Usage: run from this file's folder, or edit SPCOMP below.

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
for %%F in (*.sp) do (
    echo [SPCOMP] %%~nxF
    "%SPCOMP%" -i"%INCLUDE_DIR%" "%%~fF" -o"%PLUGIN_DIR%\%%~nF.smx"
    if errorlevel 1 (
        echo FAILED: %%~nxF
        popd
        exit /b 1
    )
)
popd

echo.
echo Build complete.
echo NOTE: Use tools\compile_strict_windows.bat to fail on compiler warnings.
exit /b 0
