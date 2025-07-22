# Windows Theme Switcher - Start Menu Shortcut Creator
# This script adds a shortcut to the Start Menu for easy theme toggling

Add-Type -AssemblyName System.Windows.Forms

Write-Host "🎨 Windows Theme Switcher - Start Menu Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Get current script directory
$scriptDir = $PSScriptRoot
$toggleScript = Join-Path $scriptDir "toggle-theme.vbs"
$togglePowerShell = Join-Path $scriptDir "toggle-theme.ps1"

# Check if files exist
if (!(Test-Path $toggleScript) -and !(Test-Path $togglePowerShell)) {
    Write-Host "❌ Error: Neither toggle-theme.vbs nor toggle-theme.ps1 found in current directory!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# Determine which script to use (prefer .vbs for silent execution)
$targetScript = if (Test-Path $toggleScript) { $toggleScript } else { $togglePowerShell }
$isVBScript = $targetScript.EndsWith(".vbs")

Write-Host "📁 Script location: $targetScript" -ForegroundColor Gray
Write-Host "🔇 Silent execution: $(if ($isVBScript) { 'Yes (VBS)' } else { 'No (PowerShell)' })" -ForegroundColor Gray
Write-Host ""

# Get Start Menu folder path
$startMenuFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft", "Windows", "Start Menu", "Programs")
$shortcutPath = Join-Path $startMenuFolder "Toggle Windows Theme.lnk"

Write-Host "📍 Shortcut will be created at:" -ForegroundColor Yellow
Write-Host "   $shortcutPath" -ForegroundColor White
Write-Host ""

# Confirm with user
$confirm = Read-Host "Create Start Menu shortcut? (y/n) [Default: y]"
if ($confirm -eq "" -or $confirm -eq "y" -or $confirm -eq "Y") {
    
    try {
        # Create WScript.Shell COM object for shortcut creation
        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut($shortcutPath)
        
        if ($isVBScript) {
            # For VBScript - use wscript.exe for silent execution
            $shortcut.TargetPath = "wscript.exe"
            $shortcut.Arguments = "`"$targetScript`""
            $shortcut.Description = "Toggle Windows Theme (Light/Dark)"
        } else {
            # For PowerShell - use powershell.exe
            $shortcut.TargetPath = "powershell.exe"
            $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetScript`""
            $shortcut.Description = "Toggle Windows Theme (Light/Dark)"
        }
        
        $shortcut.WorkingDirectory = $scriptDir
        $shortcut.IconLocation = "shell32.dll,278"  # Theme/color icon from Windows
        $shortcut.Save()
        
        Write-Host "✅ Shortcut created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 How to use:" -ForegroundColor Cyan
        Write-Host "   1. Press Win key to open Start Menu" -ForegroundColor White
        Write-Host "   2. Type 'Toggle' to find the shortcut" -ForegroundColor White
        Write-Host "   3. Click or press Enter to toggle theme" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Pro tip: Right-click the shortcut → Pin to Start for quick access!" -ForegroundColor Yellow
        
    } catch {
        Write-Host "❌ Failed to create shortcut: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "   - Try running as Administrator" -ForegroundColor White
        Write-Host "   - Make sure Start Menu folder is accessible" -ForegroundColor White
    }
    
} else {
    Write-Host "⏭️  Shortcut creation cancelled." -ForegroundColor Gray
}

Write-Host ""
Write-Host "📋 Additional shortcuts you can create manually:" -ForegroundColor Cyan
Write-Host "   • Desktop: Copy any .vbs file to Desktop" -ForegroundColor White
Write-Host "   • Taskbar: Right-click shortcut → Pin to taskbar" -ForegroundColor White
Write-Host "   • Hotkey: Right-click shortcut → Properties → Shortcut key" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue..."
