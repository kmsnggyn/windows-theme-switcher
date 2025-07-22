# Windows Theme Switcher - Quick Setup for Start Menu Shortcuts
# Creates shortcuts for all theme switching functions

Add-Type -AssemblyName System.Windows.Forms

Write-Host "🎨 Theme Switcher - Quick Start Menu Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$startMenuFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft", "Windows", "Start Menu", "Programs")

# Define shortcuts to create
$shortcuts = @(
    @{
        Name = "Toggle Windows Theme"
        Script = "toggle-theme.vbs"
        Icon = "shell32.dll,278"
        Description = "Toggle between light and dark theme"
    },
    @{
        Name = "Dark Theme"
        Script = "dark-mode.vbs"
        Icon = "shell32.dll,277"
        Description = "Switch to dark theme"
    },
    @{
        Name = "Light Theme"
        Script = "light-mode.vbs"
        Icon = "shell32.dll,276"
        Description = "Switch to light theme"
    }
)

Write-Host "📋 Available shortcuts to create:" -ForegroundColor Yellow
foreach ($shortcut in $shortcuts) {
    $scriptPath = Join-Path $scriptDir $shortcut.Script
    $status = if (Test-Path $scriptPath) { "✅" } else { "❌" }
    Write-Host "   $status $($shortcut.Name)" -ForegroundColor White
}
Write-Host ""

$confirm = Read-Host "Create all available shortcuts in Start Menu? (y/n) [Default: y]"
if ($confirm -eq "" -or $confirm -eq "y" -or $confirm -eq "Y") {
    
    $created = 0
    $skipped = 0
    
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        
        foreach ($shortcut in $shortcuts) {
            $scriptPath = Join-Path $scriptDir $shortcut.Script
            
            if (Test-Path $scriptPath) {
                $shortcutPath = Join-Path $startMenuFolder "$($shortcut.Name).lnk"
                
                $lnk = $WshShell.CreateShortcut($shortcutPath)
                $lnk.TargetPath = "wscript.exe"
                $lnk.Arguments = "`"$scriptPath`""
                $lnk.Description = $shortcut.Description
                $lnk.WorkingDirectory = $scriptDir
                $lnk.IconLocation = $shortcut.Icon
                $lnk.Save()
                
                Write-Host "✅ Created: $($shortcut.Name)" -ForegroundColor Green
                $created++
            } else {
                Write-Host "⏭️  Skipped: $($shortcut.Name) (file not found)" -ForegroundColor Yellow
                $skipped++
            }
        }
        
        Write-Host ""
        Write-Host "🎉 Setup complete!" -ForegroundColor Green
        Write-Host "   Created: $created shortcuts" -ForegroundColor White
        Write-Host "   Skipped: $skipped shortcuts" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🚀 How to use:" -ForegroundColor Cyan
        Write-Host "   1. Press Win key" -ForegroundColor White
        Write-Host "   2. Type 'theme' or 'toggle'" -ForegroundColor White
        Write-Host "   3. Select your preferred option" -ForegroundColor White
        
    } catch {
        Write-Host "❌ Error creating shortcuts: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "⏭️  Setup cancelled." -ForegroundColor Gray
}

Write-Host ""
Read-Host "Press Enter to exit..."
