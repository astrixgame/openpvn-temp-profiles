Add-Type -AssemblyName System.Security
$currentuser = $Env:UserName

# ===== Static variables ==============
$profile = ""
$downloadpath = "C:\Users\$currentuser\Downloads\$profile.ovpn"
$username = ""
$authpwd = ""
$privpwd = ""
# =====================================

if (-not $profile) {
    Write-Error "Profile name is missing"
    exit
}

# Copy downloaded profile into ovpn config directory
# Copy-Item $downloadpath -Destination "C:\Users\$currentuser\OpenVPN\config"
# ...

function Encrypt-Data {
    param($decryptedData, $entropy, $cu)
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($decryptedData)
    return [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes,
        $entropy,
        $cu
    )
}

$regPath = "HKCU:\Software\OpenVPN-GUI\configs\$profile"
$cu = [System.Security.Cryptography.DataProtectionScope]::CurrentUser

$entropy = New-Object byte[] 16
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($entropy)

$entropyfull = New-Object byte[] ($entropy.Length + 1)
[Array]::Copy($entropy, 0, $entropyfull, 0, $entropy.Length)
$entropyfull[$entropyfull.Length - 1] = 0

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$username = [System.Text.Encoding]::Unicode.GetBytes($username)
$authpwd = [byte[]](Encrypt-Data $authpwd $entropy $cu)
$privpwd = [byte[]](Encrypt-Data $privpwd $entropy $cu)

Set-ItemProperty -Path $regPath -Name 'username' -Value $username
Set-ItemProperty -Path $regPath -Name 'entropy' -Value $entropyfull
Set-ItemProperty -Path $regPath -Name 'auth-data' -Value $authpwd
Set-ItemProperty -Path $regPath -Name 'key-data' -Value $privpwd

# Connect profile in OpenVPN GUI
Start-Process -FilePath "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--connect $profile.ovpn"

Start-Sleep -Seconds 8

# Remove profile from registry
Remove-Item -Path "$regPath\" -Recurse
