Write-Host "Starting configuration of TwinCAT System Service for ADS-over-MQTT..."

$tcRoutesContent = @"
<?xml version="1.0" encoding="ISO-8859-1"?> `r`n
<TcConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.beckhoff.com/schemas/2015/12/TcConfig"> `r`n
<RemoteConnections> `r`n
    <Mqtt> `r`n
        <Address Port="8883">127.0.0.1</Address> `r`n
        <Topic>VirtualAmsNetwork1</Topic> `r`n
        <Tls> `r`n
            <Ca>$caPath\$caCert</Ca> `r`n
            <Cert>$caPath\$tcSysSrvAdsMqttClientCert</Cert> `r`n
            <Key>$caPath\$tcSysSrvAdsMqttClientKey</Key> `r`n
        </Tls> `r`n
    </Mqtt> `r`n
</RemoteConnections> `r`n
</TcConfig> `r`n
"@

# Remove any existing ADS-over-MQTT routes file but create a backup first
if (Test-Path -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName") {
    Copy-Item -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName" -Destination "$tcSysSrvRoutesPath\$tcSysSrvRoutesName.bak"
    Remove-Item -Recurse -Force "$tcSysSrvRoutesPath\$tcSysSrvRoutesName"
}

# Create new routes file for ADS-over-MQTT
New-Item -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName" -Value $tcRoutesContent

# Restart of TcSysSrv service required -> will be performed by reboot anyway