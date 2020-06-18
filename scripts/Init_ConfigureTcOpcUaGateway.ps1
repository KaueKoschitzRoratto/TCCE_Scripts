Write-Host "Starting configuration of TwinCAT OPC UA Gateway..."

$hostname = $args[0]

$serverName = "TcOpcUaGateway@" + $hostname
$serverUrl = "opc.tcp://" + $hostname + ":4840"

$baseInstallPath = $tcFunctionsInstallDir + "\TF6100-OPC-UA\Win32\Gateway"
$configPath = $baseInstallPath + "\bin\uagateway.config.xml"
$pkiPathServer = $baseInstallPath + "\pkiserver"
$pkiOwnCert = $pkiPathServer + "\own\certs\uagateway.der"
$pkiOwnPrivate = $pkiPathServer + "\own\private\uagateway.pem"

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

# Change Cert IPAddress
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.IPAddress = $publicIp

# Disable anonymous auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableAnonymous = "false"

# Disable cert auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableCertificate = "false"

# Enable username/password auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableUserPw = "true"

# Save config file
$xmlContent.Save($configPath)

# Remove own server certificate because it needs to be re-created
if (Test-Path -Path $pkiOwnCert) {
    Remove-Item -Force $pkiOwnCert
}
if (Test-Path -Path $pkiOwnPrivate) {
    Remove-Item -Force $pkiOwnPrivate
}

# Restart UA Gateway service
Restart-Service -Name "UaGateway"