@echo off
echo 🎨 Windows Theme Switcher - Setup Helper
echo ==========================================
echo.
echo This will open PowerShell and run the configuration script.
echo If you see any "execution policy" errors, you may need to run as Administrator.
echo.
pause

powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& '%~dp0configure.ps1'"

echo.
echo If the script didn't work, try:
echo 1. Right-click this file and "Run as administrator"  
echo 2. Or open PowerShell as admin and run: .\configure.ps1
echo.
pause
