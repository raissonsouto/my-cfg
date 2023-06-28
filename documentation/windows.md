# Windows Setup

Here you will find useful information about how to setup your Windows enviroment automatically, using powershell and Choco (windows commandline installer).

**Disclaimer:** The author of this script is not responsible for any damage or loss of data that may occur as a result of running this script. Use at your own risk.

## Requirements

- Windows 10/11
- Windows PowerShell (version 5.1 or later)
- Administrator privileges

## Installation

1. Download this repository to your computer.

2. Open Windows PowerShell as an administrator.

3. Allow Windows to run scripts without been digitally signed.

```
set-executionpolicy Unrestricted
```

4. Navigate to the directory containing the `windows.ps1`.

```
cd ~/Downloads/My-CFG/My-CFG-main/
```

5. Run the `windows.ps1` script. Obs: Modify ``windows.ps1` to your own needs before run it.

```
windows.ps1
```

6. Disable scripts without been digitally signed.

```
set-executionpolicy Restricted
```

## Programs Installed

These are the programs I have set up in my environment. Feel free to edit the scripts to customize them to your needs.

### Tools

- 7zip
- Calibre
- Chrome
- DroidCam Client
- Firefox
- Libre Office
- Notion
- OBS
- OpenVPN
- Thunderbird
- Tor Browser
- VLC
- qBitTorrent

### Communication Tools
- Discord
- Mattermost Desktop
- Slack
- WhatsApp

### Development Tools
- Docker Desktop
- VirtualBox
- VS Code
- PyCharm
- IntelliJ IDEA
- GoLand
- Android Studio
- Python
- Nmap
- Git
- Microsoft Windows Terminal
- Postman

### Entertainment
- Steam

### Programs Uninstalled

- Disney+
- Clima
- dicas
- hub de comentarios
- mapas (@todo)
- mixed reality portal (@todo)
- notas autoadesivas
- solitaire & casual games (@todo)
- vincular ao celular
- skype
- pessoas
- one note
- Office
- One Drive
- Spotify

## Contribute

You can help this project by improving the scripts or reporting bugs and errors =)