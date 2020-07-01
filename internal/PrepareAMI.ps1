$totalSteps = 7

Write-Host "This script prepares the current virtual machine to be saved as an AMI"
Write-Host "----------------------------------------------------------------------"

###################################################################################

$currentStep = 1
Write-Progress -Activity "AMI preparation" -Status "Removing registry keys" -PercentComplete ($currentStep / $totalSteps * 100)

$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyBase = $regKeyBeckhoff + $regKeyCloudEng

if(Test-Path -Path "$regKeyBase") {
    Remove-Item -Path $regKeyBase -Force
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing CA directory and content" -PercentComplete ($currentStep / $totalSteps * 100)

$caPath = "C:\CA"

if (Test-Path -Path $caPath) {
    Remove-Item -Recurse -Force $caPath
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing ADS-over-MQTT route" -PercentComplete ($currentStep / $totalSteps * 100)

$tcSysSrvRoutesPath = "C:\TwinCAT\3.1\Target\Routes"

if (Test-Path -Path $tcSysSrvRoutesPath) {
    Remove-Item -Recurse -Force $tcSysSrvRoutesPath
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing readme file from users's desktop" -PercentComplete ($currentStep / $totalSteps * 100)

$readmePath = "C:\Users\Administrator\Desktop\readme.txt"

if (Test-Path -Path $readmePath) {
    Remove-Item -Force $readmePath
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing user accounts" -PercentComplete ($currentStep / $totalSteps * 100)

Remove-LocalUser -Name "Tcce_User_OpcUa"
Remove-LocalUser -Name "Tcce_User_Ssh"
Remove-LocalUser -Name "Tcce_User_Agent"

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing SSH key files" -PercentComplete ($currentStep / $totalSteps * 100)

$sshDirectory = "C:\ProgramData\ssh"
Remove-Item -Path "$sshDirectory\ssh_host_*" -Force

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing Agent service" -PercentComplete ($currentStep / $totalSteps * 100)

Invoke-Expression -Command "sc.exe delete TcCloudEngineeringAgent"

###################################################################################

Read-Host "Finished AMI preparations!!"