# Global variables, which are used by each script
$global:caPath = "C:\CA"
$global:caCert = "rootCA.pem"
$global:caKey = "rootCA.key"
$global:readmePath = "C:\Users\Administrator\Desktop"
$global:readmeFile = "readme.txt"

# Windows Registry
$global:regKeyTc = $regKeyBeckhoff + "\TwinCAT3"
$global:regKeyTcSystem = $regKeyTc + "\System"
$global:regKeyPropertyCaPath = "CaPath"
$global:regKeyPropertyAmsNetId = "AmsNetId"
$global:regKeyPropertyInitScriptsRepo = "InitScriptsRepoPath"
$global:regKeyPropertyPublicIp = "PublicIp"

# TwinCAT
$global:tcInstallDir = "C:\TwinCAT"
$global:tcFunctionsInstallDir = $tcInstallDir + "\Functions"

# TwinCAT System Service - ADS-over-MQTT
$global:tcSysSrvRoutesPath = "C:\TwinCAT\3.1\Target\Routes"
$global:tcSysSrvRoutesName = "AdsOverMqtt.xml"
$global:tcSysSrvAdsMqttClientCert = "AdsOverMqtt.pem"
$global:tcSysSrvAdsMqttClientKey = "AdsOverMqtt.key"

# Mosquitto
$global:mosquittoPath = "C:\Program Files\mosquitto"
$global:mosquittoConf = "mosquitto.conf"
$global:mosquittoServerCert = "mosquitto.pem"
$global:mosquittoServerKey = "mosquitto.key"

# Repository paths
$global:repoPathInitScripts = "C:\git\TCCE_InitScripts"