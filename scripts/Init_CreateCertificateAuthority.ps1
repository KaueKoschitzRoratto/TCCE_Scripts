Write-Host "Starting creation of a local certificate authority..."

# Remove any existing files
if (Test-Path -Path "$caPath\$caCert") {
    Remove-Item -Recurse -Force "$caPath\$caCert"
}
if (Test-Path -Path "$caPath\$caKey") {
    Remove-Item -Recurse -Force "$caPath\$caKey"
}

# Generate certificate authority private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $caKey 2048"

# Generate certificate authority certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -x509 -new -nodes -key $caKey -out $caCert -sha256 -days 18250 -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=TcCloudEngineeringCA"