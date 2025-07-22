Add-Type -AssemblyName System.Windows.Forms

# ----------- CONFIG -----------
$scriptDir = $PSScriptRoot
$lightWallpaper = Join-Path $scriptDir "_LIGHT.jpg"
$darkWallpaper  = Join-Path $scriptDir "_DARK.jpg"
$fullThemeDevices = @("YOUR_COMPUTER_NAME")  # Add your computer names here
# ------------------------------

$hostname = $env:COMPUTERNAME
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# Get current hour
$currentHour = [int](Get-Date).ToString("HH")

# Define function
function Set-Wallpaper($imagePath) {
    if (!(Test-Path $imagePath)) {
        Write-Error "Wallpaper not found: $imagePath"
        return
    }

    $resolvedPath = [System.IO.Path]::GetFullPath((Resolve-Path $imagePath))
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 10
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $resolvedPath
    Start-Process -WindowStyle Hidden -FilePath "reg.exe" -ArgumentList "export", "HKCU\Control Panel\Desktop", "$env:TEMP\wallpaper.reg", "/y" | Out-Null
    Start-Sleep -Milliseconds 800
    Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,UpdatePerUserSystemParameters"
}

if ($currentHour -ge 8 -and $currentHour -lt 17) {
    # Light mode
    Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value 1
    if ($fullThemeDevices -contains $hostname) {
        Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value 1
    }
    Set-Wallpaper $lightWallpaper
} else {
    # Dark mode
    Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value 0
    if ($fullThemeDevices -contains $hostname) {
        Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value 0
    }
    Set-Wallpaper $darkWallpaper
}

# Optional: Ask to restart Explorer
$answer = [System.Windows.Forms.MessageBox]::Show(
    "Explorer UI may look off. Restart now?",
    "Theme: Time-based",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($answer -eq [System.Windows.Forms.DialogResult]::Yes) {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}
