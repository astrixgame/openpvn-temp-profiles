# OpenVPN profile automation
A PowerShell tool for automatically creating and connecting temporary OpenVPN profiles. Credentials are stored in the Windows Registry and securely deleted after use.

## 🧑🏻‍💻 Usage
### Define profile name and credentials
SetAndRun.ps1: set creds and run vpn
```powershell
$profile = "<profile name>"
$username = "<auth username>"
$authpwd = "<auth password>"
$privpwd = "<private key password>"
```
GetStatus.ps1: returns connection state of vpn profile
```powershell
$profile = "<profile name>"
```
GetCreds.ps1: returns vpn credentials of all vpn profiles
>To start PS script in background you can use:<br>`powershell -windowstyle hidden -file C:\some\path\to\SetAndStart.ps1`
## Additional options/parts
Copy downloaded OVPN profile:
```powershell
$downloadpath = "C:\Users\$currentuser\Downloads\$profile.ovpn"
...
Copy-Item $downloadpath -Destination "C:\Users\$currentuser\OpenVPN\config"
```
### Start OpenVPN GUI with connect parameter:
```powershell
Start-Process -FilePath "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--connect $profile.ovpn"
```
### Wait for OpenVPN to connect:
💡 This delay is important: without enabling silent connection mode in OpenVPN GUI, the connection dialog pauses for 5 seconds waiting for user confirmation — plus additional time for the actual connection to establish.
```powershell
Start-Sleep -Seconds 8
```

### Remove credentials from registry:
```powershell
Remove-Item -Path "$regPath\" -Recurse
```

## Setup silent connection (OpenVPN GUI)
**Right click** on tray icon and click on settings, in **General tab** check the `Silent connection`
![Image](/settings.png)

## 🛠️ Tech Stack
- [OpenVPN GUI](https://openvpn.net/community-downloads/)
- [PowerShell](https://github.com/PowerShell/PowerShell)
