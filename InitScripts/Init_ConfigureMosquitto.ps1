Write-Host "Starting configuratio of Mosquitto message broker..."

$hostname = $args[0]

$mosquittoPath = "C:\Program Files (x86)\mosquitto"
$mosquittoConf = "mosquitto.conf"
$mosquittoConfContent = @"
listener 8883 `r`n
allow_anonymous true `r`n
require_certificate true `r`n
`r`n
cafile C:\CA\rootCA.pem `r`n
certfile C:\CA\server.pem `r`n
keyfile C:\CA\server.key `r`n
"@

$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

$serverCert = "server.pem"
$serverKey = "server.key"

# Remove any existing configuration file but create a backup first
if (Test-Path -Path "$mosquittoPath\$mosquittoConf") {
    Copy-Item -Path "$mosquittoPath\$mosquittoConf" -Destination "$mosquittoPath\$mosquittoConf.bak"
    Remove-Item -Recurse -Force "$mosquittoPath\$mosquittoConf"
}

# Create new configuration file
New-Item -Path "$mosquittoPath\$mosquittoConf" -Value $mosquittoConfContent

# Restart Mosquitto service
Restart-Service -Name "mosquitto"