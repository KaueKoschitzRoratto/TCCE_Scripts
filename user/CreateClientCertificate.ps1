param ($DestinationPath='C:\Temp', $Name='ClientCert', $Validity=365, $NoPrompt=$false)

$totalSteps = 5

if (-not (Test-Path -Path $DestinationPath)) {
    New-Item -Path $DestinationPath -ItemType "directory"
}

$currentStep = 1
Write-Progress -Activity "Certificate Authority" -Status "Importing global settings" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "$PSScriptRoot\..\share\GlobalSettings.ps1"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Creating key" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe genrsa -out $DestinationPath\$Name.key 2048"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Creating certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe req -new -sha256 -key $DestinationPath\$Name.key -out $DestinationPath\$Name.pem -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ClientCert/CN=$Name"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Signing certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe x509 -req -in $DestinationPath\$Name.pem -CA $caPath\$caCert -CAkey $caPath\$caKey -CAcreateserial -out $DestinationPath\$Name.pem -days $Validity -sha256"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Copying CA certificate to destination folder" -PercentComplete ($currentStep / $totalSteps * 100)
Copy-Item -Path "$caPath\$caCert" -Destination "$DestinationPath\$caCert"

if (-not $NoPrompt) {
    Write-Host "Script execution finished. All files are located in $DestinationPath. Press ENTER to continue."
    Read-Host
}
