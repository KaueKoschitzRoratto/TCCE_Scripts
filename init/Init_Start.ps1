$totalSteps = 12

# Create registry keys
$currentStep = 1
Write-Progress -Activity "Initialization" -Status "CreateRegKeys" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateRegKeys.ps1"

# Create Certificate Authority
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateCertificateAuthority" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateCertificateAuthority.ps1"

# Create server certificate for local Mosquitto message broker
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateMosquittoCertificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateMosquittoCertificate.ps1 $hostname"

# Create client certificate for ADS-over-MQTT
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateAdsOverMqttCertificate" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateAdsOverMqttCertificate.ps1 $hostname"

# Configure TwinCAT OPC UA Server
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "ConfigureTcOpcUaServer" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_ConfigureTcOpcUaServer.ps1 $hostname"

# Configure TwinCAT OPC UA Gateway
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "ConfigureTcOpcUaGateway" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_ConfigureTcOpcUaGateway.ps1 $hostname"

# Configure TwinCAT System Service with ADS-over-MQTT route
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "ConfigureAdsOverMqtt" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_ConfigureAdsOverMqtt.ps1"

# Configure Mosquitto message broker
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "ConfigureMosquitto" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_ConfigureMosquitto.ps1"

# Reset AMS Net ID
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "ResetAmsNetId" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_ResetAmsNetId.ps1"

# Create user account for TcOpcUaGateway
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateUserOpcUa" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateUserOpcUa.ps1"

# Create user account for SSH access
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateUserSsh" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateUserSsh.ps1"

# Create user account for Tcce Agent Windows service
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "CreateUserAgent" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\Init_CreateUserAgent.ps1"