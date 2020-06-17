Write-Host "Starting certificate creation for ADS-over-MQTT..."

$hostname = $args[0]

# Remove any existing files
if (Test-Path -Path "$caPath\$tcSysSrvAdsMqttClientCert") {
    Remove-Item -Recurse -Force "$caPath\$tcSysSrvAdsMqttClientCert"
}
if (Test-Path -Path "$caPath\$tcSysSrvAdsMqttClientKey") {
    Remove-Item -Recurse -Force "$caPath\$tcSysSrvAdsMqttClientKey"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $tcSysSrvAdsMqttClientKey 2048"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -new -sha256 -key $tcSysSrvAdsMqttClientKey -out $tcSysSrvAdsMqttClientCert -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=DeviceCert/CN=$publicIp"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "x509 -req -in $tcSysSrvAdsMqttClientCert -CA $caCert -CAkey $caKey -CAcreateserial -out $tcSysSrvAdsMqttClientCert -days 7300 -sha256"