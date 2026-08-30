@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0compile_strict_windows.ps1"
exit /b %ERRORLEVEL%
