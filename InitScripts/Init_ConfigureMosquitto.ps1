Write-Host "Starting configuration of Mosquitto message broker..."

$mosquittoConfContent = @"
listener 8883 `r`n
allow_anonymous true `r`n
require_certificate true `r`n
`r`n
cafile $caPath\$caCert `r`n
certfile $caPath\$mosquittoServerCert `r`n
keyfile $caPath\$mosquittoServerKey `r`n
"@

# Remove any existing configuration file but create a backup first
if (Test-Path -Path "$mosquittoPath\$mosquittoConf") {
    Copy-Item -Path "$mosquittoPath\$mosquittoConf" -Destination "$mosquittoPath\$mosquittoConf.bak"
    Remove-Item -Recurse -Force "$mosquittoPath\$mosquittoConf"
}

# Create new configuration file
New-Item -Path "$mosquittoPath\$mosquittoConf" -Value $mosquittoConfContent

# Restart of mosquitto service required -> will be performed by reboot anyway