$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyBase = $regKeyBeckhoff + $regKeyCloudEng
$regKeyPropertyCaPath = "CaPath"
$regKeyPropertyCaCertsPath = "CaCertsPath"

$caPath = "C:\CA"
$caCertsPath = $caPath + "\certs"
$caConfig = "openssl_ca.cnf"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"
$caCrl = "rootCA.crl"

# Create directory for CA
if (-not (Test-Path -Path $caPath)) {
    $dir = New-Item -Path $caPath -ItemType "directory"
}
if (-not (Test-Path -Path $caCertsPath)) {
    $dir = New-Item -Path $caCertsPath -ItemType "directory"
}

# Copy template files
$cpy = Copy-Item -Path "$PSScriptRoot\..\templates\ca\openssl_ca.cnf" -Destination $caPath
$cpy = Copy-Item -Path "$PSScriptRoot\..\templates\ca\index.txt" -Destination $caPath
$cpy = Copy-Item -Path "$PSScriptRoot\..\templates\ca\crlnumber" -Destination $caPath
$cpy = Copy-Item -Path "$PSScriptRoot\..\templates\ca\serial" -Destination $caPath

# Create registry property to store CA paths
$key = New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyCaPath -Value $caPath
$key = New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyCaCertsPath -Value $caCertsPath

# Give user group Tcce_Group_OpcUa read/write permissions on the CA directory
$acl = Get-Acl $caPath
$aclRuleArgs = "Tcce_Group_OpcUa", "Read,Write,ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclRuleArgs)
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $caPath

# Generate certificate authority private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $caKey 4096"

# Generate certificate authority certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -config $caConfig -key $caKey -out $caCert -x509 -new -nodes -sha256 -days 18250 -extensions v3_ca -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=TcCloudEngineeringCA"

# Generate certificate authority CRL
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $caConfig -gencrl -out $caCrl"