Write-Host "Starting certificate creation for ADS-over-MQTT..."

$hostname = $args[0]

$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

$clientCert = "TwinCAT_XAE.pem"
$clientKey = "TwinCAT_XAE.key"

# Remove any existing files
if (Test-Path -Path "$caPath\$clientCert") {
    Remove-Item -Recurse -Force "$caPath\$clientCert"
}
if (Test-Path -Path "$caPath\$clientKey") {
    Remove-Item -Recurse -Force "$caPath\$clientKey"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $clientKey 2048"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -new -sha256 -key $clientKey -out $clientCert -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=DeviceCert/CN=$hostname"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "x509 -req -in $clientCert -CA $caCert -CAkey $caKey -CAcreateserial -out $clientCert -days 7300 -sha256"