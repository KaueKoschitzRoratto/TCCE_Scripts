Write-Host "Starting configuration of TwinCAT OPC UA Server..."

$hostname = $args[0]

$baseRegKey32 = "\SOFTWARE\Beckhoff\TwinCAT3"
$baseRegKey64 = "\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3"
$serverName = "TcOpcUaServer@" + $hostname
$serverUrl = "opc.tcp://" + $hostname + ":4841"

# Retrieve TwinCAT installation directory from Windows Registry
$tcInstallDirTemp = Get-ItemProperty -Path HKLM:$baseRegKey64
if($tcInstallDirTemp -eq $null) {
 $tcInstallDirTemp = Get-ItemProperty -Path HKLM:$baseRegKey32
}
$tcInstallDir = $tcInstallDirTemp.TwinCATDir
$tcFunctionsInstallDir = $tcInstallDir + "Functions"
$baseInstallPath = $tcFunctionsInstallDir + "\TF6100-OPC-UA\Win32\Server"
$configPath = $baseInstallPath + "\TcUaServerConfig.xml"
$pkiPathServer = $baseInstallPath + "\pki"
$pkiPathBkpServer = $baseInstallPath + "\pki.bkp"
$pkiOwnCert = $pkiPathServer + "\CA\own\certs\Beckhoff_OpcUaServer.der"
$pkiOwnPrivate = $pkiPathServer + "\CA\own\private\Beckhoff_OpcUaServer.pem"

# Stop TcOpcUaServer.exe
Stop-Process -Name TcOpcUaServer -Force

# Load XML
[xml] $xmlContent = Get-Content -Path $configPath

# Change ServerName
$xmlContent.OpcServerConfig.UaServerConfig.ServerName = $serverName

# Change ServerUrl
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.Url = $serverUrl

# Change Cert CommonName
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.CertificateStore.CertificateSettings.CommonName = $hostname

# Change Cert DNSName
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.CertificateStore.CertificateSettings.DNSName = $hostname

# Save config file
$xmlContent.Save($configPath)

# Remove PKI.bkp directory
if (Test-Path -Path $pkiPathBkpServer) {
    Remove-Item -Recurse -Force $pkiPathBkpServer
}

# Remove own server certificate because it needs to be re-created
if (Test-Path -Path $pkiOwnCert) {
    Remove-Item -Force $pkiOwnCert
}
if (Test-Path -Path $pkiOwnPrivate) {
    Remove-Item -Force $pkiOwnPrivate
}
