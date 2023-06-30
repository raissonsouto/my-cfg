# Windows Setup

Here you will find useful information about how to setup your Windows enviroment automatically, using powershell and Choco (windows commandline installer).

**Disclaimer:** The author of this script is not responsible for any damage or loss of data that may occur as a result of running this script. Use at your own risk.

## Requirements

- Windows 10/11
- Windows PowerShell (version 5.1 or later)
- Administrator privileges

## How to get it done

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

## Settings
- Dark theme
- Taskbar small buttons
- Hide search, cortana and task view buttons
- Remove pre-installed programs listed bellow
- Hide news and interests tab
- Install some software listed bellow

## Programs Installed

These are the programs I have set up in my environment, feel free to edit the scripts to customize them to your needs.

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
- qBitTorrent
- Thunderbird
- Tor Browser
- VLC
- WSL2

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
- Dicas
- Hub de comentarios
- Mapas (@todo)
- Mixed reality portal (@todo)
- Notas autoadesivas
- Solitaire & casual games (@todo)
- Vincular ao celular
- Skype
- Pessoas
- One note
- Office
- One Drive
- Spotify

## Contribute

You can help this project by improving the scripts or reporting bugs and errors =)