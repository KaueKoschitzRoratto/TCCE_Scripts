param ($CaPath, $CertPath)

$totalSteps = 1

$currentStep = 1
Write-Progress -Activity "Certificate Authority" -Status "Revoking certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "openssl ca -config $CaPath\openssl_ca.cnf -revoke $CertPath"

if (-not $NoPrompt) {
    Write-Host "Script execution finished. Press ENTER to continue."
    Read-Host
}
