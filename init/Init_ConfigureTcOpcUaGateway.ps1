Write-Host "Starting configuration of TwinCAT OPC UA Gateway..."

$hostname = $args[0]

$serverName = "TcOpcUaGateway@" + $publicIp.ToString()
$serverUrl = "opc.tcp://" + $hostname + ":48050"

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
#$xmlContent.OpcServerConfig.UaServerConfig.UaEndpoint.StackUrl = $serverUrl

# Change Cert CommonName
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.CommonName = $publicIp.ToString()

# Change Cert DomainComponent
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.DomainComponent = $hostname

# Change Cert DNSName
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.DNSName = $hostname

# Change Cert IPAddress
$xmlContent.OpcServerConfig.UaServerConfig.DefaultApplicationCertificateStore.ServerCertificate.CertificateSettings.IPAddress = $publicIp.ToString()

# Disable anonymous auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableAnonymous = "false"

# Disable cert auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableCertificate = "false"

# Enable username/password auth
$xmlContent.OpcServerConfig.UaServerConfig.UserIdentityTokens.EnableUserPw = "true"

# Check if TcOpcUaServer and TcCloudEngineeringUaServer have been added correctly
# /OpcServerConfig/Objects/OpcUa/OpcUaServer
$tcUaServerFound = $false
$tcceUaServerFound = $false
$ua = $xmlContent.SelectSingleNode("/OpcServerConfig/Objects/OpcUa")
$uaServers = $xmlContent.SelectNodes("/OpcServerConfig/Objects/OpcUa/OpcUaServer")
if (-not($uaServers -eq $null)) {
    foreach ($uaServer in $uaServers) {
        if ($uaServer.Name -eq "TcOpcUaServer") {
            $tcUaServerFound = $true
            $uaServer.Url = "opc.tcp://localhost:4840"
        }
        if ($uaServer.Name -eq "TcCloudEngineeringUaServer") {
            $tcceUaServerFound = $true
            $uaServer.Url = "opc.tcp://localhost:4842"
        }
    }

    if (-not $tcUaServerFound) {
        $newNodeOpcUaServer = $xmlContent.CreateNode("element", "OpcUaServer", "")
        $newNodeOpcUaServerName = $xmlContent.CreateNode("element", "Name", "")
        $newNodeOpcUaServerName.InnerText = "TcOpcUaServer"
        $newNodeOpcUaServerUrl = $xmlContent.CreateNode("element", "Url", "")
        $newNodeOpcUaServerUrl.InnerText = "opc.tcp://localhost:4840"
        $newNodeOpcUaServerSecPol = $xmlContent.CreateNode("element", "SecurityPolicy", "")
        $newNodeOpcUaServerSecPol.InnerText = "None"
        $newNodeOpcUaServerMsgMode = $xmlContent.CreateNode("element", "MessageSecurityMode", "")
        $newNodeOpcUaServerMsgMode.InnerText = "None"
        $newNodeOpcUaServerUserToken = $xmlContent.CreateNode("element", "UserTokenType", "")
        $newNodeOpcUaServerUserToken.InnerText = "Anonymous"
        $newNodeOpcUaServerUserName = $xmlContent.CreateNode("element", "UserName", "")
        $newNodeOpcUaServerUserName.InnerText = ""
        $newNodeOpcUaServerPwd = $xmlContent.CreateNode("element", "Password", "")
        $newNodeOpcUaServerPwd.InnerText = ""
        $newNodeOpcUaServerConnectFlag = $xmlContent.CreateNode("element", "ConnectFlag", "")
        $newNodeOpcUaServerConnectFlag.InnerText = "true"
        $newNodeOpcUaServerPrefix = $xmlContent.CreateNode("element", "NamespacePrefixOption", "")
        $newNodeOpcUaServerPrefix.InnerText = "Name"

        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUrl)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerSecPol)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerMsgMode)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserToken)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPwd)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerConnectFlag)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPrefix)
        
        $ua.AppendChild($newNodeOpcUaServer)
    }

    if (-not $tcceUaServerFound) {
        $newNodeOpcUaServer = $xmlContent.CreateNode("element", "OpcUaServer", "")
        $newNodeOpcUaServerName = $xmlContent.CreateNode("element", "Name", "")
        $newNodeOpcUaServerName.InnerText = "TcCloudEngineeringUaServer"
        $newNodeOpcUaServerUrl = $xmlContent.CreateNode("element", "Url", "")
        $newNodeOpcUaServerUrl.InnerText = "opc.tcp://localhost:4842"
        $newNodeOpcUaServerSecPol = $xmlContent.CreateNode("element", "SecurityPolicy", "")
        $newNodeOpcUaServerSecPol.InnerText = "None"
        $newNodeOpcUaServerMsgMode = $xmlContent.CreateNode("element", "MessageSecurityMode", "")
        $newNodeOpcUaServerMsgMode.InnerText = "None"
        $newNodeOpcUaServerUserToken = $xmlContent.CreateNode("element", "UserTokenType", "")
        $newNodeOpcUaServerUserToken.InnerText = "Anonymous"
        $newNodeOpcUaServerUserName = $xmlContent.CreateNode("element", "UserName", "")
        $newNodeOpcUaServerUserName.InnerText = ""
        $newNodeOpcUaServerPwd = $xmlContent.CreateNode("element", "Password", "")
        $newNodeOpcUaServerPwd.InnerText = ""
        $newNodeOpcUaServerConnectFlag = $xmlContent.CreateNode("element", "ConnectFlag", "")
        $newNodeOpcUaServerConnectFlag.InnerText = "true"
        $newNodeOpcUaServerPrefix = $xmlContent.CreateNode("element", "NamespacePrefixOption", "")
        $newNodeOpcUaServerPrefix.InnerText = "Name"

        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUrl)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerSecPol)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerMsgMode)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserToken)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPwd)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerConnectFlag)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPrefix)
        
        $ua.AppendChild($newNodeOpcUaServer)
    }
}
else {
        $newNodeOpcUaServer = $xmlContent.CreateNode("element", "OpcUaServer", "")
        $newNodeOpcUaServerName = $xmlContent.CreateNode("element", "Name", "")
        $newNodeOpcUaServerName.InnerText = "TcOpcUaServer"
        $newNodeOpcUaServerUrl = $xmlContent.CreateNode("element", "Url", "")
        $newNodeOpcUaServerUrl.InnerText = "opc.tcp://localhost:4840"
        $newNodeOpcUaServerSecPol = $xmlContent.CreateNode("element", "SecurityPolicy", "")
        $newNodeOpcUaServerSecPol.InnerText = "None"
        $newNodeOpcUaServerMsgMode = $xmlContent.CreateNode("element", "MessageSecurityMode", "")
        $newNodeOpcUaServerMsgMode.InnerText = "None"
        $newNodeOpcUaServerUserToken = $xmlContent.CreateNode("element", "UserTokenType", "")
        $newNodeOpcUaServerUserToken.InnerText = "Anonymous"
        $newNodeOpcUaServerUserName = $xmlContent.CreateNode("element", "UserName", "")
        $newNodeOpcUaServerUserName.InnerText = ""
        $newNodeOpcUaServerPwd = $xmlContent.CreateNode("element", "Password", "")
        $newNodeOpcUaServerPwd.InnerText = ""
        $newNodeOpcUaServerConnectFlag = $xmlContent.CreateNode("element", "ConnectFlag", "")
        $newNodeOpcUaServerConnectFlag.InnerText = "true"
        $newNodeOpcUaServerPrefix = $xmlContent.CreateNode("element", "NamespacePrefixOption", "")
        $newNodeOpcUaServerPrefix.InnerText = "Name"

        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUrl)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerSecPol)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerMsgMode)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserToken)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPwd)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerConnectFlag)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPrefix)
        
        $ua.AppendChild($newNodeOpcUaServer)

        $newNodeOpcUaServer = $xmlContent.CreateNode("element", "OpcUaServer", "")
        $newNodeOpcUaServerName = $xmlContent.CreateNode("element", "Name", "")
        $newNodeOpcUaServerName.InnerText = "TcCloudEngineeringUaServer"
        $newNodeOpcUaServerUrl = $xmlContent.CreateNode("element", "Url", "")
        $newNodeOpcUaServerUrl.InnerText = "opc.tcp://localhost:4842"
        $newNodeOpcUaServerSecPol = $xmlContent.CreateNode("element", "SecurityPolicy", "")
        $newNodeOpcUaServerSecPol.InnerText = "None"
        $newNodeOpcUaServerMsgMode = $xmlContent.CreateNode("element", "MessageSecurityMode", "")
        $newNodeOpcUaServerMsgMode.InnerText = "None"
        $newNodeOpcUaServerUserToken = $xmlContent.CreateNode("element", "UserTokenType", "")
        $newNodeOpcUaServerUserToken.InnerText = "Anonymous"
        $newNodeOpcUaServerUserName = $xmlContent.CreateNode("element", "UserName", "")
        $newNodeOpcUaServerUserName.InnerText = ""
        $newNodeOpcUaServerPwd = $xmlContent.CreateNode("element", "Password", "")
        $newNodeOpcUaServerPwd.InnerText = ""
        $newNodeOpcUaServerConnectFlag = $xmlContent.CreateNode("element", "ConnectFlag", "")
        $newNodeOpcUaServerConnectFlag.InnerText = "true"
        $newNodeOpcUaServerPrefix = $xmlContent.CreateNode("element", "NamespacePrefixOption", "")
        $newNodeOpcUaServerPrefix.InnerText = "Name"

        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUrl)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerSecPol)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerMsgMode)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserToken)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerUserName)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPwd)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerConnectFlag)
        $newNodeOpcUaServer.AppendChild($newNodeOpcUaServerPrefix)
        
        $ua.AppendChild($newNodeOpcUaServer)
}

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