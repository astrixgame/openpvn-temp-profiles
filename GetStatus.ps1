$profile = ""

$currentuser = $Env:UserName

$configpath = "C:\Users\$currentuser\openvpn\config\$profile.ovpn"
$remote = Select-String -Path $configpath -Pattern '^remote\s+\S+\s+\S+\s+\S+' | Select-Object -First 1 | ForEach-Object { $_.Line }

function Test-TCP {
    param($ip, $port)
    return Get-NetTCPConnection -RemoteAddress $ip -RemotePort $port -State Established -ErrorAction SilentlyContinue
}

if($remote) {
    $parts = $remote -split '\s+'
    $ip = $parts[1]
    $port = $parts[2]
    $protocol = $parts[3]

    if($protocol -eq 'tcp') {
        if(Test-TCP $ip $port) { Write-Output "The target is connected" } else { Write-Output "The target is not connnected" }
    } else {
        Write-Error "Cannot detect established connections which using UDP"
    }
} else {
    Write-Error "Cannot find remote parameter in ovpn profile"
}
