# Retrieve public hostname of instance and store in registry to detect if InitScript needs to run again (Clone)
$token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token
$hostname = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/public-hostname

# Check if reg key for TwinCAT Cloud Engineering exists
$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyName = "TwinCAT Cloud Engineering"
$regKeyPropertyName = "Hostname"
$baseRegKey = $regKeyBeckhoff + $regKeyName
$regKeyExists = Test-Path $baseRegKey

$init = $false

if($regKeyExists -eq $false) {
    New-Item -Path $regKeyBeckhoff -Name $regKeyName
    New-ItemProperty -Path $baseRegKey -Name $regKeyPropertyName -Value $hostname
}
else {
    $hostnameReg = Get-ItemProperty -Path $baseRegKey -Name $regKeyPropertyName
    if ($hostnameReg.Hostname -ne $hostname) {
        Set-ItemProperty -Path $baseRegKey -Name $regKeyPropertyName -Value $hostname
        $init = $true
        }
}

if($init)
{
    # Configure TwinCAT OPC UA Server
    Invoke-Expression ".\Init_ConfigureTcOpcUaServer.ps1 $hostname"

    # Configure TwinCAT OPC UA Gateway
    Invoke-Expression ".\Init_ConfigureTcOpcUaGateway.ps1 $hostname"

    # Create Certificate Authority
    Invoke-Expression ".\Init_CreateCertificateAuthority.ps1"

    # Create server certificate for local Mosquitto message broker
    Invoke-Expression ".\Init_CreateMosquittoCertificate.ps1 $hostname"

    # Create client certificate for ADS-over-MQTT
    Invoke-Expression ".\Init_CreateAdsOverMqttCertificate.ps1 $hostname"

    # Reset AMS Net ID
    Invoke-Expression ".\Init_ResetAmsNetId.ps1"

    # Start TwinCAT Cloud Engineering OPC UA Server
    Invoke-Expression ".\Init_StartCloudEngineeringUaServer.ps1"
}