param ($DestinationPath='C:\Temp', $Name='ClientCert', $Validity=365, $NoPrompt=$false)

$totalSteps = 5

if (-not (Test-Path -Path $DestinationPath)) {
    New-Item -Path $DestinationPath -ItemType "directory"
}

$currentStep = 1
Write-Progress -Activity "Create ADSoverMQTT Client" -Status "Importing global settings" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "$PSScriptRoot\..\share\GlobalSettings.ps1"

$currentStep = $currentStep + 1
Write-Progress -Activity "Create ADSoverMQTT Client" -Status "Retrieving IP address" -PercentComplete ($currentStep / $totalSteps * 100)
$ipAddress = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/public-ipv4
if ($ipAddress -eq $null) {
    $ipAddress = "127.0.0.1"
}

$currentStep = $currentStep + 1
Write-Progress -Activity "Create ADSoverMQTT Client" -Status "Creating client certificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression -Command "$PSScriptRoot\CreateClientCertificate.ps1 -DestinationPath $DestinationPath -Name $Name -Validity $Validity -NoPrompt $true"

$currentStep = $currentStep + 1
Write-Progress -Activity "Create ADSoverMQTT Client" -Status "Copying ADSoverMQTT configuration file" -PercentComplete ($currentStep / $totalSteps * 100)
Copy-Item -Path "$PSScriptRoot\..\configs\AdsOverMqtt.xml" -Destination "$DestinationPath\AdsOverMqtt.xml"

$currentStep = $currentStep + 1
Write-Progress -Activity "Create ADSoverMQTT Client" -Status "Modifying ADSoverMQTT configuration file" -PercentComplete ($currentStep / $totalSteps * 100)
[xml] $xmlContent = Get-Content -Path "$DestinationPath\AdsOverMqtt.xml"
$xmlContent.TcConfig.RemoteConnections.Mqtt.Address.InnerText = $ipAddress
$xmlContent.TcConfig.RemoteConnections.Mqtt.Address.attributes["Port"].Value = "8883"
$xmlContent.TcConfig.RemoteConnections.Mqtt.Tls.Ca = "$caCert"
$xmlContent.TcConfig.RemoteConnections.Mqtt.Tls.Cert = "$Name.pem"
$xmlContent.TcConfig.RemoteConnections.Mqtt.Tls.Key = "$Name.key"
$xmlContent.Save("$DestinationPath\AdsOverMqtt.xml")

if (-not $NoPrompt) {
    Write-Host "Script execution finished. All files are located in $DestinationPath and you can copy them to your target system."
    Write-Host "Make sure to edit AdsOverMqtt.xml to reference the correct certificate paths. Press ENTER to continue."
    Read-Host
}