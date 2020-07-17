param ($CaPath="C:\CA", $CaConfig="openssl_ca.cnf", $CaCrl="rootCA.crl", $CertPath)

$totalSteps = 2

$currentStep = 1
Write-Progress -Activity "Certificate Authority" -Status "Revoking certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $CaPath\openssl_ca.cnf -revoke $CertPath"

$currentStep = $currentStep + 1
Write-Progress -Activity "Certificate Authority" -Status "Updating CRL" -PercentComplete ($currentStep / $totalSteps * 100)
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $CaConfig -gencrl -out $CaCrl"

$restart = Read-Host 'CRL updated, would you like to restart the message broker? (y/n)'

if (($restart -eq "Y") -or ($restart -eq "y")) {
    Stop-Service mosquitto
    Start-Service mosquitto
}

if (-not $NoPrompt) {
    Write-Host "Script execution finished. Press ENTER to continue."
    Read-Host
}
