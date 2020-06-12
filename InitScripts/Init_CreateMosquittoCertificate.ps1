Write-Host "Starting certificate creation for Mosquitto message broker..."

$hostname = $args[0]

$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

$serverCert = "server.pem"
$serverKey = "server.key"

# Remove any existing files
if (Test-Path -Path "$caPath\$serverCert") {
    Remove-Item -Recurse -Force "$caPath\$serverCert"
}
if (Test-Path -Path "$caPath\$serverKey") {
    Remove-Item -Recurse -Force "$caPath\$serverKey"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $serverKey 2048"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -new -sha256 -key $serverKey -out $serverCert -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=$hostname"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "x509 -req -in $serverCert -CA $caCert -CAkey $caKey -CAcreateserial -out $serverCert -days 7300 -sha256"