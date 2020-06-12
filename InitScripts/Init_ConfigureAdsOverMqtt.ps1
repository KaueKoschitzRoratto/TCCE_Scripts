Write-Host "Starting configuration of TwinCAT System Service for ADS-over-MQTT..."

$caPath = "C:\CA"
$caCert = "rootCA.pem"

$clientCert = "TwinCAT_XAE.pem"
$clientKey = "TwinCAT_XAE.key"

$tcRoutesPath = "C:\TwinCAT\3.1\Target\Routes"
$tcRoutesName = "AdsOverMqtt.xml"
$tcRoutesContent = @"
<?xml version="1.0" encoding="ISO-8859-1"?> `r`n
<TcConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.beckhoff.com/schemas/2015/12/TcConfig"> `r`n
<RemoteConnections> `r`n
    <Mqtt> `r`n
        <Address Port="8883">127.0.0.1</Address> `r`n
        <Topic>VirtualAmsNetwork1</Topic> `r`n
        <Tls> `r`n
            <Ca>$caPath\$caCert</Ca> `r`n
            <Cert>$caPath\$clientCert</Cert> `r`n
            <Key>$caPath\$clientKey</Key> `r`n
        </Tls> `r`n
    </Mqtt> `r`n
</RemoteConnections> `r`n
</TcConfig> `r`n
"@

# Remove any existing ADS-over-MQTT routes file but create a backup first
if (Test-Path -Path "$tcRoutesPath\$tcRoutesName") {
    Copy-Item -Path "$tcRoutesPath\$tcRoutesName" -Destination "$tcRoutesPath\$tcRoutesName.bak"
    Remove-Item -Recurse -Force "$tcRoutesPath\$tcRoutesName"
}

# Create new routes file for ADS-over-MQTT
New-Item -Path "$tcRoutesPath\$tcRoutesName" -Value $tcRoutesContent

# Restart of TcSysSrv service required -> will be performed by reboot anyway