param ($Hostname)

$serverName = "TcOpcUaServer@" + $Hostname
$serverUrl = "opc.tcp://" + $Hostname + ":4840"

$tcInstallDir = "C:\TwinCAT"
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
