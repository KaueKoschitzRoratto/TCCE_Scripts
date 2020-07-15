Write-Host "Starting creation of a local certificate authority..."

# Create directory for CA
if (-not (Test-Path -Path $caPath)) {
    New-Item -Path $caPath -ItemType "directory"
    New-Item -Path $caCertsPath -ItemType "directory"
}

# Give user group Tcce_Group_OpcUa read/write permissions on the CA directory
$acl = Get-Acl $caPath
$aclRuleArgs = "Tcce_Group_OpcUa", "Read,Write,ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclRuleArgs)
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $caPath

# Generate certificate authority private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $caKey 2048"

# Generate certificate authority certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -x509 -new -nodes -key $caKey -out $caCert -sha256 -days 18250 -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=TcCloudEngineeringCA"