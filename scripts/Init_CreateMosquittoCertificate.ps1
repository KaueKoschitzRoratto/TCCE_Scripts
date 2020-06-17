Write-Host "Starting certificate creation for Mosquitto message broker..."

$hostname = $args[0]

# Remove any existing files
if (Test-Path -Path "$caPath\$mosquittoServerCert") {
    Remove-Item -Recurse -Force "$caPath\$mosquittoServerCert"
}
if (Test-Path -Path "$caPath\$mosquittoServerKey") {
    Remove-Item -Recurse -Force "$caPath\$mosquittoServerKey"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $mosquittoServerKey 2048"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -new -sha256 -key $mosquittoServerKey -out $mosquittoServerCert -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=$publicIp"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "x509 -req -in $mosquittoServerCert -CA $caCert -CAkey $caKey -CAcreateserial -out $mosquittoServerCert -days 7300 -sha256"