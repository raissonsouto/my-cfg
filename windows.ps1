# Remove apps
# Uninstall Disney+
Get-AppxPackage -Name Disney.DisneyPlus -AllUsers | Remove-AppxPackage

# Uninstall OneDrive
Get-AppxPackage -Name Microsoft.OneDrive -AllUsers | Remove-AppxPackage

# Uninstall Office (replace with the version you want to uninstall)
Get-AppxPackage -Name Microsoft.Office.Desktop -AllUsers | Remove-AppxPackage

# Uninstall Spotify
Get-AppxPackage -Name SpotifyAB.SpotifyMusic -AllUsers | Remove-AppxPackage

# Set Windows dark theme
if (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize')) {
  New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Force
}

New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0 -Type DWord -Force
New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0 -Type DWord -Force

# Set desktop wallpaper
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value 'C:\Windows\System32\solidblack.bmp'
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Set lock screen wallpaper
$ImagePath = "D:\Code\My-CFG\lock-bg.jpeg"
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
if (!(Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
New-ItemProperty -Path $regPath -Name "LockScreenImagePath" -Value $ImagePath -Force | Out-Null

# Install Nvidia driver
Start-Process -FilePath "D:\Softwares\installers\driver-nvdia.exe"

# Check if WSL is already installed
if (!(Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -ErrorAction SilentlyContinue)) {
    # Install WSL 2
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    # Set WSL 2 as the default version
    wsl --set-default-version 2
    # Download Ubuntu 22.04 LTS from the Microsoft Store
    $app = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu22.04onWindows
    if ($app -eq $null) {
        Start-Process -FilePath "ms-windows-store://pdp/?productid=9P91RK0MGV6M" -Verb RunAs
        Write-Host "Please install Ubuntu 22.04 LTS from the Microsoft Store and run this script again."
        Pause
        Exit
    }
    # Launch Ubuntu 22.04 LTS and complete the installation
    wsl --set-version Ubuntu-22.04 2
    wsl -d Ubuntu-22.04
} else {
    Write-Host "WSL is already installed."
}

# Install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Programs to install
$programs = @(
    # Tools
    '7zip', 'vlc', 'qbittorrent', 'chromium', 'firefox', 'obs-studio', 'libreoffice-still', 'notion', 'droidcamclient', 'tor-browser', 'thunderbird', 'steam', 'bitwarden',
    
    # Communication tools
    'slack', 'discord', 'whatsapp', 'mattermost-desktop',
    
    # Dev tools
    'docker-desktop', 'nmap', 'microsoft-windows-terminal', 'wireshark', 'git', 'virtualbox', 'pgadmin4', 'postman',
    
    # Code editors and languages
    'pycharm', 'intellijidea', 'goland', 'androidstudio', 'vscode', 'python'
)

# Install programs in parallel
$tasks = foreach ($program in $programs) {
    Start-Job -ScriptBlock { choco install $args[0] -y } -ArgumentList $program
}

# Wait for all tasks to complete
Wait-Job $tasks | Out-Null
Receive-Job $tasks | Out-Null
Remove-Job $tasks | Out-Null

# Install openvpn
Invoke-WebRequest -Uri "https://openvpn.net/downloads/openvpn-client-installer.exe" -OutFile "C:\Temp\openvpn-client-installer.exe"
Start-Process "C:\Temp\openvpn-client-installer.exe"