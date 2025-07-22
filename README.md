# Windows Theme Switcher

Automatically switch between## 💻 Requirements

- **Windows 10/11** (any recent version)
- **PowerShell 5.1 or higher** (built into Windows)
  - ✅ Compatible with PowerShell 5.1 (Windows default)
  - ✅ Compatible with PowerShell 7+ (if installed)
- Your wallpapers: `_DARK.jpg` and `_LIGHT.jpg`ows light and dark themes with matching wallpapers.

## ✨ Features

- 🔄 **Toggle Theme**: Switch between light/dark modes instantly
- ⏰ **Time-based**: Auto-switch themes by time of day (8AM-5PM = light)
- 🖼️ **Smart Wallpapers**: Automatically changes wallpaper to match theme
- 🎯 **Flexible Scope**: Choose full theme or apps-only changes per device
- 🔇 **Silent Mode**: VBScript wrappers for background execution

## 🚀 Quick Start

1. **Download** this repository to your computer
2. **Add wallpapers**: Place your `_DARK.jpg` and `_LIGHT.jpg` files in the folder
3. **Run setup** (choose one):
   - **Easy way**: Double-click `SETUP.bat` 
   - **Manual way**: Open PowerShell, run `.\configure.ps1`
4. **Start switching**:
   ```powershell
   .\toggle-theme.ps1    # Most common usage
   ```

## 📁 What's Included

| File | Purpose |
|------|---------|
| `SETUP.bat` | � **Double-click this first** - Easy setup launcher |
| `configure.ps1` | 🔧 Configuration manager (advanced) |
| `toggle-theme.ps1` | 🔄 Toggle between light/dark themes |
| `dark-mode.ps1` | 🌙 Force dark mode |
| `light-mode.ps1` | ☀️ Force light mode |
| `set-theme-by-time.ps1` | ⏰ Auto-switch by time (8AM-5PM light) |
| `*.vbs` files | 🔇 Silent versions (no windows) |

## ⚙️ Theme Scope Options

**Full Theme** (default): Changes everything - apps, taskbar, start menu, system UI  
**Apps Only**: Changes File Explorer and apps, leaves taskbar dark

> 💡 Most users prefer Full Theme for a consistent experience

## 🤖 Automation Ideas

### Keyboard Shortcuts
1. Right-click `toggle-theme.vbs` → Create shortcut
2. Right-click shortcut → Properties → Shortcut key
3. Set hotkey like `Ctrl+Alt+T`

### Task Scheduler
1. Open **Task Scheduler**
2. Create **Basic Task** 
3. Action: `wscript.exe "C:\path\to\set-theme-by-time.vbs"`
4. Trigger: Daily at startup + every 2 hours

## �️ Requirements

- Windows 10/11
- PowerShell 5.1+
- Your wallpapers: `_DARK.jpg` and `_LIGHT.jpg`

## ❓ Troubleshooting

| Issue | Solution |
|-------|----------|
| **Script flashes and closes** | Right-click PowerShell → "Run as Administrator", then try again |
| **"Execution policy" error** | Run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| **Script won't run at all** | Open PowerShell as Admin, navigate to folder, run `.\configure.ps1` |
| **Config window closes immediately** | Run from PowerShell directly, not by double-clicking |
| Wallpaper not changing | Check `_DARK.jpg` and `_LIGHT.jpg` exist in script folder |
| UI looks weird after theme change | Restart Explorer when prompted |

---
**MIT License** • Feel free to customize and share!
