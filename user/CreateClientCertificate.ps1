param ($DestinationPath='C:\Temp', $Name='ClientCert', $Validity=365, $NoPrompt=$false)

$totalSteps = 5

if (-not (Test-Path -Path $DestinationPath)) {
    New-Item -Path $DestinationPath -ItemType "directory"
}

$currentStep = 1
Write-Progress -Activity "Certificate Authority" -Status "Importing global settings" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "$PSScriptRoot\..\share\GlobalSettings.ps1"

# Generate new private key
$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Creating key" -PercentComplete ($currentStep / $totalSteps * 100)
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $DestinationPath\$Name.key 4096"

# Generate self-signed certificate
$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Creating certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -config $caConfig -new -sha256 -key $DestinationPath\$Name.key -out $DestinationPath\$Name.csr -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ClientCert/CN=$Name"

# Sign self-signed certificate by certificate authority
$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Signing certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $caConfig -batch -days 7300 -notext -md sha256 -in $DestinationPath\$Name.csr -extensions usr_cert -out $DestinationPath\$Name.pem"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Copying CA certificate to destination folder" -PercentComplete ($currentStep / $totalSteps * 100)
Copy-Item -Path "$caPath\$caCert" -Destination "$DestinationPath\$caCert"

if (-not $NoPrompt) {
    Write-Host "Script execution finished. All files are located in $DestinationPath. Press ENTER to continue."
    Read-Host
}
