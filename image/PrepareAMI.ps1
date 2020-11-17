$totalSteps = 11

###################################################################################
# This script prepares the current virtual machine to be saved as an AMI
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
Remove-LocalUser -Name "Tcce_User_SSH"
Remove-LocalUser -Name "Tcce_User_Agent"
Remove-LocalUser -Name "Tcce_User_TcAdmin"

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing SSH key files" -PercentComplete ($currentStep / $totalSteps * 100)

$sshDirectory = "C:\ProgramData\ssh"
Remove-Item -Path "$sshDirectory\ssh_host_*" -Force

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing Agent installation and service" -PercentComplete ($currentStep / $totalSteps * 100)
Stop-Service "TcCloudEngineeringAgent"
Invoke-Expression -Command "sc.exe delete TcCloudEngineeringAgent"

$agentDirectory = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringAgent"
if (Test-Path -Path $agentDirectory) {
    Remove-Item -Recurse -Force $agentDirectory
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing OPC UA Server service" -PercentComplete ($currentStep / $totalSteps * 100)
Stop-Service "TcCloudEngineeringUaServer"
Invoke-Expression -Command "sc.exe delete TcCloudEngineeringUaServer"

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing gateway crash logs" -PercentComplete ($currentStep / $totalSteps * 100)

$gatewayPath = "C:\TwinCAT\Functions\TF6100-OPC-UA\Win32\Gateway"
$gatewayCrashLogsPath = $gatewayPath + "\crash_log*"

if (Test-Path -Path $gatewayCrashLogsPath) {
    Remove-Item -Recurse -Force $gatewayCrashLogsPath
}

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Removing TCCE firewall settings" -PercentComplete ($currentStep / $totalSteps * 100)

# Remove firewall rule for MQTT/TLS
$rule = Remove-NetFirewallRule -DisplayName "Tcce_Mqtt"

# Remove firewall rule for OPC UA Gateway
$rule = Remove-NetFirewallRule -DisplayName "Tcce_TcOpcUaGateway"

# Remove firewall rule for TwinCAT HMI
$rule = Remove-NetFirewallRule -DisplayName "Tcce_TcHmi"

# Remove firewall rule for Agent communication
$newRule = Remove-NetFirewallRule -DisplayName "Tcce_Agent"

# Remove firewall rule for ADS Discovery
$newRule = Remove-NetFirewallRule -DisplayName "Tcce_AdsDiscovery"

# Remove firewall rule for ADSSecure
$newRule = Remove-NetFirewallRule -DisplayName "Tcce_AdsSecure"

# Remove firewall rule for SSH
$newRule = Remove-NetFirewallRule -DisplayName "Tcce_Ssh"

###################################################################################

$currentStep = $currentStep + 1
Write-Progress -Activity "AMI preparation" -Status "Disabling OS firewall settings" -PercentComplete ($currentStep / $totalSteps * 100)

Disable-NetFirewallRule -DisplayName "DIAL protocol server (HTTP-In)"

Disable-NetFirewallRule -DisplayName "DIAL protocol server (HTTP-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device functionality (qWave-TCP-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device functionality (qWave-UDP-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device SSDP Discovery (UDP-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device streaming server (HTTP-Streaming-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device streaming server (RTCP-Streaming-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device streaming server (RTSP-Streaming-In)"

Disable-NetFirewallRule -DisplayName "Cast to Device UPnP Events (TCP-In)"

Disable-NetFirewallRule -DisplayName "Cortana"

Disable-NetFirewallRule -DisplayName "Desktop App Web Viewer"

Disable-NetFirewallRule -DisplayName "Delivery Optimization (TCP-In)"

Disable-NetFirewallRule -DisplayName "Delivery Optimization (UDP-In)"

Disable-NetFirewallRule -DisplayName "DCOM-Port"

Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (LLMNR-UDP-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (NB-Datagram-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (NB-Name-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (Pub-WSD-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (SSDP-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (UPnP-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (WSD Events-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (WSD EventsSecure-In)"

Disable-NetFirewallRule -DisplayName "Network Discovery (WSD-In)"

Disable-NetFirewallRule -DisplayName "OpenSSH Server (sshd)"

###################################################################################

Read-Host "Finished AMI preparations!!"