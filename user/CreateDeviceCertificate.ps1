param ($DestinationPath, $CommonName, $Validity)

$totalSteps = 3

Invoke-Expression "..\.\share\GlobalSettings.ps1"

$currentStep = 1
Write-Progress -Activity "Certificate Authority" -Status "Creating key" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe genrsa -out $DestinationPath\device.key 2048"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Creating certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe req -new -sha256 -key $DestinationPath\device.key -out $DestinationPath\device.pem -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ClientCert/CN=$CommonName"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Signing certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl.exe x509 -req -in $DestinationPath\device.pem -CA $caPath\$caCert -CAkey $caPath\$caKey -CAcreateserial -out $DestinationPath\device.pem -days $Validity -sha256"

Read-Host