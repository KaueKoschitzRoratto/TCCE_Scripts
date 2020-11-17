param ($Hostname)

$serverName = "TcOpcUaServer@" + $Hostname
$serverUrl = "opc.tcp://" + $Hostname + ":4840"

$tcdir = Get-Childitem env:twincat3dir
$tcdirarray = $tcdir.Value.Split('\')
$tcInstallDir = $tcdirarray[0]+"\"+$tcdirarray[1]+"\"+$tcdirarray[2]
$tcFunctionsInstallDir = $tcInstallDir + "\Functions"

$baseInstallPath = $tcFunctionsInstallDir + "\TF6100-OPC-UA\Win32\Server"
$configPath = $baseInstallPath + "\TcUaServerConfig.xml"
$pkiPathServer = $baseInstallPath + "\pki"
$pkiPathBkpServer = $baseInstallPath + "\pki.bkp"
$pkiOwnCert = $pkiPathServer + "\CA\own\certs\Beckhoff_OpcUaServer.der"
$pkiOwnPrivate = $pkiPathServer + "\CA\own\private\Beckhoff_OpcUaServer.pem"

# Stop TcOpcUaServer.exe
$svc = Stop-Process -Name TcOpcUaServer -Force

# Load XML
[xml] $xmlContent = Get-Content -Path $configPath

# Change ServerName
$xmlContent.OpcServerConfig.UaServerConfig.ServerName = $serverName

# Change ServerUrl
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.Url = $serverUrl

# Change Cert CommonName
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.CertificateStore.CertificateSettings.CommonName = $Hostname

# Change Cert DNSName
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.CertificateStore.CertificateSettings.DNSName = $Hostname

# Add None/None endpoint for Gateway<->Server communication
$uaEndpoint = $xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint
$secSettings = $xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.SecuritySetting
$secSettingNoneFound = $false
foreach($secSetting in $secSettings) {
    if ($secSetting.SecurityPolicy -eq "http://opcfoundation.org/UA/SecurityPolicy#None") {
        $secSettingNoneFound = $true
    }
}
if (-not($secSettingNoneFound)) {
        $newSecSetting = $xmlContent.CreateNode("element", "SecuritySetting", "")
        $newSecPolicy = $xmlContent.CreateNode("element", "SecurityPolicy", "")
        $newSecPolicy.InnerText = "http://opcfoundation.org/UA/SecurityPolicy#None"
        $newMsgSecMode = $xmlContent.CreateNode("element", "MessageSecurityMode", "")
        $newMsgSecMode.InnerText = "None"

        $newSecSetting.AppendChild($newSecPolicy)
        $newSecSetting.AppendChild($newMsgSecMode)
        
        $uaEndpoint.AppendChild($newSecSetting)
}

# Save config file
$xmlContent.Save($configPath)

# Remove PKI.bkp directory
if (Test-Path -Path $pkiPathBkpServer) {
    $rmv = Remove-Item -Recurse -Force $pkiPathBkpServer
}

# Remove own server certificate because it needs to be re-created
if (Test-Path -Path $pkiOwnCert) {
    $rmv = Remove-Item -Force $pkiOwnCert
}
if (Test-Path -Path $pkiOwnPrivate) {
    $rmv = Remove-Item -Force $pkiOwnPrivate
}
