Add-Type -AssemblyName System.Windows.Forms

# Load global settings
Invoke-Expression ".\Init_Settings.ps1"

# Retrieve public hostname of instance and store in registry to detect if InitScript needs to run again (Clone)
$token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token
$hostname = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/public-hostname

$init = $false

if (-Not (Test-Path $baseRegKey)) {
    New-Item -Path $regKeyBeckhoff -Name $regKeyCloudEng
    New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
}
else {
    $hostnameReg = Get-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname
    if ($hostnameReg.Hostname -ne $hostname) {
        Set-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
        $init = $true
    }
}

if($init)
{
    # Warn user about init scripts
    [System.Windows.Forms.MessageBox]::Show("A new or cloned virtual machine has been detected, which requires the one-time execution of an initialization script. Please click on OK to continue and do not close the command prompt window. A separate message box will notify you once the script has been executed.",“TwinCAT Cloud Engineering init script“,0)

    # Create Certificate Authority
    Invoke-Expression ".\Init_CreateCertificateAuthority.ps1"

    # Create server certificate for local Mosquitto message broker
    Invoke-Expression ".\Init_CreateMosquittoCertificate.ps1 $hostname"

    # Create client certificate for ADS-over-MQTT
    Invoke-Expression ".\Init_CreateAdsOverMqttCertificate.ps1 $hostname"

    # Configure TwinCAT OPC UA Server
    Invoke-Expression ".\Init_ConfigureTcOpcUaServer.ps1 $hostname"

    # Configure TwinCAT OPC UA Gateway
    Invoke-Expression ".\Init_ConfigureTcOpcUaGateway.ps1 $hostname"

    # Configure TwinCAT System Service with ADS-over-MQTT route
    Invoke-Expression ".\Init_ConfigureAdsOverMqtt.ps1"

    # Configure Mosquitto message broker
    Invoke-Expression ".\Init_ConfigureMosquitto.ps1"

    # Configure TwinCAT Cloud Engineering OPC UA Server
    Invoke-Expression ".\Init_ConfigureCloudEngineeringUaServer.ps1"

    # Reset AMS Net ID
    Invoke-Expression ".\Init_ResetAmsNetId.ps1"

    # Restart Windows
    [System.Windows.Forms.MessageBox]::Show("Windows will be restarted now to finish the initialization script...",“TwinCAT Cloud Engineering init script“,0)
    Restart-Computer
}