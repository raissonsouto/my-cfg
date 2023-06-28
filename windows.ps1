# Raisson Souto, 2023

# The goal of this script is to automate the
# configuration of my Windows environment

# Remove apps
$programs = @(
    "Disney.DisneyPlus",
    "Microsoft.BingWeather",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.OneDrive",
    "Microsoft.OneNote",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "SpotifyAB.SpotifyMusic"
)

# Uninstall programs in parallel
$tasks = foreach ($program in $programs) {
    Start-Job -ScriptBlock {
        Get-AppxPackage -Name $args[0] -AllUsers -ErrorAction SilentlyContinue |
        Remove-AppxPackage -ErrorAction SilentlyContinue
    } -ArgumentList $program
}

Wait-Job $tasks | Out-Null

$results = $tasks | Receive-Job

foreach ($i in 0..($results.Count - 1)) {
    $program = $programs[$i]
    $result = $results[$i]

    if ($result) {
        Write-Host "Uninstalled program: $program"
    } else {
        Write-Host "Program not found: $program"
    }
}

Remove-Job $tasks | Out-Null

# Set Windows dark theme
if (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize')) {
  New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Force
}

New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0 -Type DWord -Force
New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0 -Type DWord -Force

# Set desktop wallpaper
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value 'C:\Windows\System32\solidblack.bmp'
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Install Nvidia driver
$nvidiaDriver = "D:\Softwares\installers\driver-nvdia.exe"

if (Test-Path $nvidiaDriver -PathType Leaf) {
    Start-Process -FilePath $nvidiaDriver
} else {
    "File does not exist: $nvidiaDriver"
}

workflow Install-WSL {
    param ([string]$Name)

    # Check if WSL is already installed
    if (!(Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -ErrorAction SilentlyContinue)) {
    
        # Install WSL 2
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    }
    else {
        Write-Host "WSL is already installed."
    }

    Restart-Computer -Wait

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
}

Install-WSL

# Install openvpn
Invoke-WebRequest -Uri "https://openvpn.net/downloads/openvpn-client-installer.exe" -OutFile "C:\Temp\openvpn-client-installer.exe"
Start-Process "C:\Temp\openvpn-client-installer.exe"

# Install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Programs to install
$programs = @(
    # Tools
    '7zip', 'vlc', 'qbittorrent', 'calibre', 'chrome', 'firefox', 'obs-studio',
    'libreoffice-still', 'notion', 'droidcamclient', 'tor-browser', 'thunderbird',
    
    # Games
    'steam',
    
    # Communication tools
    'slack', 'discord', 'whatsapp', 'mattermost-desktop',
    
    # Dev tools
    'docker-desktop', 'nmap', 'microsoft-windows-terminal', 'git', 'virtualbox', 'postman',
    
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