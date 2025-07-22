Add-Type -AssemblyName System.Windows.Forms

# ----------- CONFIG -----------
$picturesPath = [Environment]::GetFolderPath('MyPictures')
$darkWallpaper = Join-Path $picturesPath "Synced Images\Wallpapers\_DARK.JPG"
$fullThemeDevices = @("YOUR_COMPUTER_NAME")  # Add your computer names here
# ------------------------------

$hostname = $env:COMPUTERNAME
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# Apply dark mode
Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value 0
if ($fullThemeDevices -contains $hostname) {
    Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value 0
}

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

Set-Wallpaper $darkWallpaper

$answer = [System.Windows.Forms.MessageBox]::Show(
    "Explorer UI may look off. Restart now?",
    "Theme: Dark",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($answer -eq [System.Windows.Forms.DialogResult]::Yes) {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}
