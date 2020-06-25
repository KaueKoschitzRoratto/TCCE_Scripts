Write-Host "Starting configuration of Mosquitto message broker..."

$mosquittoConfContent = @"
listener 8883`n
allow_anonymous true`n
require_certificate true`n
`n
cafile $caPath\$caCert`n
certfile $caPath\$mosquittoServerCert`n
keyfile $caPath\$mosquittoServerKey`n
"@

# Remove any existing configuration file but create a backup first
if (Test-Path -Path "$mosquittoPath\$mosquittoConf") {
    Copy-Item -Path "$mosquittoPath\$mosquittoConf" -Destination "$mosquittoPath\$mosquittoConf.bak"
    Remove-Item -Recurse -Force "$mosquittoPath\$mosquittoConf"
}

# Create new configuration file
New-Item -Path "$mosquittoPath\$mosquittoConf" -Value $mosquittoConfContent

# Restart of mosquitto service required -> will be performed by reboot anyway