Write-Host "Starting certificate creation for ADS-over-MQTT..."

$hostname = $args[0]

$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

$clientCert = "TwinCAT_XAE.pem"
$clientKey = "TwinCAT_XAE.key"

# Generate new private key
Start-Process -Wait -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $clientKey 2048"

# Generate self-signed certificate
Start-Process -Wait -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -new -sha256 -key $clientKey -out $clientCert -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=DeviceCert/CN=$hostname"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "x509 -req -in $clientCert -CA $caCert -CAkey $caKey -CAcreateserial -out $clientCert -days 7300 -sha256"