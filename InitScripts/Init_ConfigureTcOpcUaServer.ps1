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

# Generate path for new PKI directories
$newPkiPathServer = $baseInstallPath + "\pki"
$newPkiPathBkpServer = $baseInstallPath + "\pki.bkp"
$newPkiPathUser = $baseInstallPath + "\pkiuser"

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

# Remove PKI directory
Remove-Item -Recurse -Force $newPkiPathServer
Remove-Item -Recurse -Force $newPkiPathBkpServer
Remove-Item -Recurse -Force $newPkiPathUser