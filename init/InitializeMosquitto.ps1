$hostname = $args[0]

$mosquittoPath = "C:\Program Files\mosquitto"
$mosquittoConf = "mosquitto.conf"
$mosquittoServerCert = "mosquitto.pem"
$mosquittoServerCsr = "mosquitto.csr"
$mosquittoServerKey = "mosquitto.key"

# Remove any existing files
if (Test-Path -Path "$caPath\$mosquittoServerCert") {
    Remove-Item -Recurse -Force "$caPath\$mosquittoServerCert"
}
if (Test-Path -Path "$caPath\$mosquittoServerKey") {
    Remove-Item -Recurse -Force "$caPath\$mosquittoServerKey"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $mosquittoServerKey 4096"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -config $caConfig -new -sha256 -key $mosquittoServerKey -out $mosquittoServerCsr -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=$publicIp"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $caConfig -batch -days 7300 -notext -md sha256 -in $mosquittoServerCsr -extensions server_cert -out $mosquittoServerCert"

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