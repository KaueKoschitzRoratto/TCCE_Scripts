# Total initilization steps for progress bar
$progressStepsTotal = 4

# Install/Update initilization scripts
$currentStep = 1
Write-Progress -Activity "Startup" -Status "Install/Update initialization scripts" -PercentComplete ($currentStep / $progressStepsTotal * 100)
Invoke-Expression "& '$PSScriptRoot\..\TcCloudEngineeringInstallScripts\InstallUpdateInitScripts.ps1'"

# Install/Update agent
$currentStep = $currentStep + 1
Write-Progress -Activity "Startup" -Status "Install/Update agent" -PercentComplete ($currentStep / $progressStepsTotal * 100)
Invoke-Expression "& '$PSScriptRoot\..\TcCloudEngineeringInstallScripts\InstallUpdateAgent.ps1'"

# Install/Update OPC UA server
$currentStep = $currentStep + 1
Write-Progress -Activity "Startup" -Status "Install/Update OPC UA server" -PercentComplete ($currentStep / $progressStepsTotal * 100)
Invoke-Expression "& '$PSScriptRoot\..\TcCloudEngineeringInstallScripts\InstallUpdateUaServer.ps1'"

# Start initilization
$currentStep = $currentStep + 1
Write-Progress -Activity "Startup" -Status "Start initilization" -PercentComplete ($currentStep / $progressStepsTotal * 100)
Invoke-Expression "& '$PSScriptRoot\..\TcCloudEngineeringInitScripts\scripts\StartInit.ps1'"
