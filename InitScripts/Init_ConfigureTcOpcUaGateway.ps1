Write-Host "Starting configuration of TwinCAT OPC UA Gateway..."

$hostname = $args[0]

Write-Host "Configuring Gateway for hostname " + $hostname

$baseRegKey32 = "\SOFTWARE\Beckhoff\TwinCAT3"
$baseRegKey64 = "\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3"
$serverName = "TcOpcUaGateway@" + $hostname
$serverUrl = "opc.tcp://" + $hostname + ":4840"

# Retrieve TwinCAT installation directory from Windows Registry
$tcInstallDirTemp = Get-ItemProperty -Path HKLM:$baseRegKey64
if($tcInstallDirTemp -eq $null) {
 $tcInstallDirTemp = Get-ItemProperty -Path HKLM:$baseRegKey32
}
$tcInstallDir = $tcInstallDirTemp.TwinCATDir
$tcFunctionsInstallDir = $tcInstallDir + "Functions"
$baseInstallPath = $tcFunctionsInstallDir + "\TF6100-OPC-UA\Win32\Gateway"
$configPath = $baseInstallPath + "\bin\uagateway.config.xml"

# Generate path for new PKI directories
$newPkiPathServer = $baseInstallPath + "\pkiserver"
$newPkiPathClient = $baseInstallPath + "\pkiclient"
$newPkiPathUser = $baseInstallPath + "\pkiuser"

# Load XML
[xml] $xmlContent = Get-Content -Path $configPath

# Change ServerName
$xmlContent.OpcServerConfig.UaServerConfig.ServerName = $serverName

# Change ServerUrl and StackUrl
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.Url = $serverUrl
$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.StackUrl = $serverUrl

# Change Cert CommonName
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.CommonName = $hostname

# Change Cert DomainComponent
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.DomainComponent = $hostname

# Change Cert DNSName
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.DNSName = $hostname

# Save config file
$xmlContent.Save($configPath)

# Remove PKI directory
Remove-Item -Recurse -Force $newPkiPathServer
Remove-Item -Recurse -Force $newPkiPathClient
Remove-Item -Recurse -Force $newPkiPathUser

# Restart UA Gateway service
Restart-Service -Name "UaGateway"