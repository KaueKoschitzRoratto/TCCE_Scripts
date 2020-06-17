Write-Host "Starting configuration of TwinCAT System Service for ADS-over-MQTT..."

$tcRoutesContent = @"
<?xml version="1.0" encoding="ISO-8859-1"?>`n
<TcConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.beckhoff.com/schemas/2015/12/TcConfig">`n
<RemoteConnections>`n
    <Mqtt>`n
        <Address Port="8883">$publicIp</Address>`n
        <Topic>VirtualAmsNetwork1</Topic>`n
        <Tls>`n
            <Ca>$caPath\$caCert</Ca>`n
            <Cert>$caPath\$tcSysSrvAdsMqttClientCert</Cert>`n
            <Key>$caPath\$tcSysSrvAdsMqttClientKey</Key>`n
        </Tls>`n
    </Mqtt>`n
</RemoteConnections>`n
</TcConfig>`n
"@

# Remove any existing ADS-over-MQTT routes file but create a backup first
if (Test-Path -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName") {
    Copy-Item -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName" -Destination "$tcSysSrvRoutesPath\$tcSysSrvRoutesName.bak"
    Remove-Item -Recurse -Force "$tcSysSrvRoutesPath\$tcSysSrvRoutesName"
}

# Create new routes file for ADS-over-MQTT
New-Item -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName" -Value $tcRoutesContent

# Restart of TcSysSrv service required -> will be performed by reboot anyway