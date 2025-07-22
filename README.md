# Windows Theme Switcher

A collection of PowerShell scripts to automatically switch between Windows light and dark themes with wallpaper changes.

## Features

- 🌙 **Dark Mode**: Switch to dark theme with dark wallpaper
- ☀️ **Light Mode**: Switch to light theme with light wallpaper
- 🔄 **Toggle Theme**: Switch between light and dark modes
- ⏰ **Time-based Theme**: Automatically switch themes based on time of day (8 AM - 5 PM for light mode)
- 🖼️ **Wallpaper Integration**: Automatically changes wallpaper to match theme
- 💻 **Device-specific**: Configure which devices get full system theme changes

## Files

### PowerShell Scripts
- `initialize.ps1` - Setup script to configure all other scripts
- `dark-mode.ps1` - Switch to dark mode
- `light-mode.ps1` - Switch to light mode
- `toggle-theme.ps1` - Toggle between light and dark themes
- `set-theme-by-time.ps1` - Set theme based on current time

### VBScript Wrappers
- `toggle-theme.vbs` - Silent wrapper for toggle script
- `set-theme-by-time.vbs` - Silent wrapper for time-based script

### Wallpapers
- `_DARK.jpg` - Dark theme wallpaper
- `_LIGHT.jpg` - Light theme wallpaper

## Setup

### Quick Setup (Recommended)
1. **Clone or download** this repository
2. **Place wallpapers**: Put your dark and light wallpapers in the same folder as the scripts, named `_DARK.jpg` and `_LIGHT.jpg`
3. **Run the initialization script**:
   ```powershell
   .\initialize.ps1
   ```
   This will:
   - Detect your computer name automatically
   - Ask about theme scope (apps-only vs full theme)
   - Configure all scripts with your preferences
   - Check for wallpaper files

### Manual Setup
If you prefer manual configuration:
1. **Set execution policy** (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
2. **Configure devices**: Edit the `$fullThemeDevices` array in each script to specify which computers should have system-wide theme changes

## Usage

### Manual Theme Switching
```powershell
# Switch to dark mode
.\dark-mode.ps1

# Switch to light mode
.\light-mode.ps1

# Toggle between themes
.\toggle-theme.ps1
```

### Automatic Time-based Switching
```powershell
# Set theme based on current time
.\set-theme-by-time.ps1
```

### Silent Execution
Use the VBScript files for silent execution (no console window):
- Double-click `toggle-theme.vbs` to toggle themes silently
- Double-click `set-theme-by-time.vbs` for time-based switching

## Configuration

### Device-specific Settings
By default, only devices listed in `$fullThemeDevices` will have their system theme (taskbar, system apps) changed. Edit this array in each script:

```powershell
$fullThemeDevices = @("L5440", "YourComputerName")
```

To find your computer name, run: `$env:COMPUTERNAME`

### Time Schedule
The time-based script uses these hours:
- **Light mode**: 8 AM - 5 PM (8:00 - 17:00)
- **Dark mode**: 5 PM - 8 AM (17:00 - 8:00)

Edit the time conditions in `set-theme-by-time.ps1` to customize.

## Automation

### Task Scheduler
You can set up Windows Task Scheduler to run the time-based script automatically:

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (e.g., daily at startup, or multiple times per day)
4. Set action to run: `wscript.exe "path\to\set-theme-by-time.vbs"`

### Keyboard Shortcuts
Create shortcuts to the VBScript files and assign hotkeys for quick theme switching.

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges may be required for some registry changes

## How It Works

The scripts modify Windows registry keys to change the theme:
- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme`
- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\SystemUsesLightTheme`

Wallpapers are set using Windows API calls and registry modifications.

## Troubleshooting

- **Explorer UI issues**: The scripts offer to restart Explorer to refresh the UI
- **Wallpaper not changing**: Ensure image files exist and paths are correct
- **Permission errors**: Run PowerShell as administrator if needed
- **Execution policy errors**: Set PowerShell execution policy as described in setup

## License

This project is open source and available under the [MIT License](LICENSE).
