Write-Host "Starting creation of a local certificate authority..."

$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

# Generate certificate authority private key
Start-Process -Wait -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $caKey 2048"

# Generate certificate authority certificate
Start-Process -Wait -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -x509 -new -nodes -key $caKey -out $caCert -sha256 -days 18250 -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=TcCloudEngineeringCA"