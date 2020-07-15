$totalSteps = 12

# Create registry keys
$currentStep = 1
Write-Progress -Activity "Initialization" -Status "Create registry keys" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\CreateRegKeys.ps1"

# Create Certificate Authority
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize Certificate Authority" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\CreateCertificateAuthority.ps1"

# Configure TwinCAT OPC UA Server
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT OPC UA Server" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\InitializeTcOpcUaServer.ps1 $hostname"

# Configure TwinCAT OPC UA Gateway
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT OPC UA Gateway" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\InitializeTcOpcUaGateway.ps1 $hostname"

# Configure TwinCAT System Service with ADS-over-MQTT route
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT ADS-over-MQTT" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\InitializeAdsOverMqtt.ps1 $hostname"

# Initialize TwinCAT Cloud Engineering Agent
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT Cloud Engineering Agent" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\InitializeAgent.ps1"

# Configure Mosquitto message broker
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Initialize Mosquitto message broker" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\InitializeMosquitto.ps1 $hostname"

# Reset AMS Net ID
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Reset AMS Net ID" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\ResetAmsNetId.ps1"

# Create user account for TcOpcUaGateway
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Create OPC UA user" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\CreateUserOpcUa.ps1"

# Create user account for SSH access
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Create SSH user" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\CreateUserSsh.ps1"

# Create user account for ADS routes (TcAdmin)
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Create TcAdmin user" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\CreateUserTcAdmin.ps1"

# Add Windows Firewall rules
$currentStep = $currentStep + 1
Write-Progress -Activity "Initialization" -Status "Add Firewall rules" -PercentComplete ($currentStep / $totalSteps * 100)
Invoke-Expression "$PSScriptRoot\..\init\AddFirewallRules.ps1"