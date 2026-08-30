@echo off
setlocal
cd /d "%~dp0.."
where python >nul 2>&1 || (echo Python is required.& exit /b 1)
set PYTHONDONTWRITEBYTECODE=1
python -m pytest -q -p no:cacheprovider tests
set RC=%ERRORLEVEL%
rmdir /s /q tests\__pycache__ 2>nul
rmdir /s /q tools\__pycache__ 2>nul
rmdir /s /q .pytest_cache 2>nul
exit /b %RC%
