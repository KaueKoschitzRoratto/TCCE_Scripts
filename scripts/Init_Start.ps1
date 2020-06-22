# Create registry keys
Invoke-Expression ".\scripts\Init_CreateRegKeys.ps1"

# Create Certificate Authority
Invoke-Expression ".\scripts\Init_CreateCertificateAuthority.ps1"

# Create server certificate for local Mosquitto message broker
Invoke-Expression ".\scripts\Init_CreateMosquittoCertificate.ps1 $hostname"

# Create client certificate for ADS-over-MQTT
Invoke-Expression ".\scripts\Init_CreateAdsOverMqttCertificate.ps1 $hostname"

# Configure TwinCAT OPC UA Server
Invoke-Expression ".\scripts\Init_ConfigureTcOpcUaServer.ps1 $hostname"

# Configure TwinCAT OPC UA Gateway
Invoke-Expression ".\scripts\Init_ConfigureTcOpcUaGateway.ps1 $hostname"

# Configure TwinCAT System Service with ADS-over-MQTT route
Invoke-Expression ".\scripts\Init_ConfigureAdsOverMqtt.ps1"

# Configure Mosquitto message broker
Invoke-Expression ".\scripts\Init_ConfigureMosquitto.ps1"

# Configure TwinCAT Cloud Engineering OPC UA Server
Invoke-Expression ".\scripts\Init_ConfigureCloudEngineeringUaServer.ps1"

# Reset AMS Net ID
Invoke-Expression ".\scripts\Init_ResetAmsNetId.ps1"

# Create user account for TcOpcUaGateway
Invoke-Expression ".\scripts\Init_CreateUserTcOpcUaGateway.ps1"

# Create user account for SSH access
Invoke-Expression ".\scripts\Init_CreateUserSsh.ps1"