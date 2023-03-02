# Install WSL 2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2

# Install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install programs in parallel
$programs = @(
    # Tools
    '7zip', 'vlc', 'qbittorrent', 'chromium', 'firefox', 'obs-studio', 'libreoffice-still', 'notion', 'droidcamclient', "tor-browser", "thunderbird", "steam", "bitwarden"

    # Communication tools
    'slack', 'discord', 'whatsapp', 'mattermost-desktop',

    # Dev tools
    'docker-desktop', 'nmap', 'microsoft-windows-terminal', 'wireshark', 'git', 'virtualbox', 'pgadmin4', 'postman',

    # Code editors and languages
    'pycharm', 'intellijidea', 'goland', 'androidstudio', 'vscode', 'python'
)

$tasks = $programs | ForEach-Object -Parallel {
    choco install $_ -y
}

# Wait for all tasks to complete
$tasks | Wait-Parallel

# Install openvpn
Invoke-WebRequest -Uri "https://openvpn.net/downloads/openvpn-client-installer.exe" -OutFile "C:\Temp\openvpn-client-installer.exe"
Start-Process "C:\Temp\openvpn-client-installer.exe"

# Install Nvidia driver
Start-Process -FilePath "C:\Path\To\Driver.exe"

# Set desktop wallpaper
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value 'C:\Windows\System32\solidblack.bmp'
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Set lock screen wallpaper
$ImagePath = "C:\Path\To\Image.jpg"
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
if (!(Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
New-ItemProperty -Path $regPath -Name "LockScreenImagePath" -Value $ImagePath -Force | Out-Null