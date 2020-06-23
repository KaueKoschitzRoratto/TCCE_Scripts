Write-Host "This script prepares the current virtual machine to be saved as an AMI"
Write-Host "----------------------------------------------------------------------"

###################################################################################

Write-Host "Step 1: Removing registry keys..."

$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyBase = $regKeyBeckhoff + $regKeyCloudEng

if(Test-Path -Path "$regKeyBase") {
    Remove-Item -Path $regKeyBase -Force
}

###################################################################################

Write-Host "Step 2: Removing CA directory and content..."

$caPath = "C:\CA"

if (Test-Path -Path $caPath) {
    Remove-Item -Recurse -Force $caPath
}

###################################################################################

Write-Host "Step 3: Removing ADS-over-MQTT route..."

$tcSysSrvRoutesPath = "C:\TwinCAT\3.1\Target\Routes"

if (Test-Path -Path $tcSysSrvRoutesPath) {
    Remove-Item -Recurse -Force $tcSysSrvRoutesPath
}

###################################################################################

Write-Host "Step 4: Removing readme file from users's desktop..."

$readmePath = "C:\Users\Administrator\Desktop\readme.txt"

if (Test-Path -Path $readmePath) {
    Remove-Item -Force $readmePath
}

###################################################################################

Write-Host "Step 5: Removing user accounts..."

Remove-LocalUser -Name "Tcce_User_OpcUa"
Remove-LocalUser -Name "Tcce_User_Ssh"

###################################################################################

Write-Host "Step 6: Removing SSH key files..."

$sshDirectory = "C:\ProgramData\ssh"
Remove-Item -Path "$sshDirectory\ssh_host_*" -Force

###################################################################################

Read-Host "Finished !!"