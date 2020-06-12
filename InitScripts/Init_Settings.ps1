# Global variables, which are used by each script
$caPath = "C:\CA"
$caCert = "rootCA.pem"
$caKey = "rootCA.key"

# Windows Registry
$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyTc = $regKeyBeckhoff + "\TwinCAT3"
$regKeyTcSystem = $regKeyTc + "\System"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyBase = $regKeyBeckhoff + $regKeyCloudEng
$regKeyPropertyHostname = "Hostname"
$regKeyPropertyCaPath = "CaPath"
$regKeyPropertyAmsNetId = "AmsNetId"

# TwinCAT
$tcInstallDir = "C:\TwinCAT"
$tcFunctionsInstallDir = $tcInstallDir + "\Functions"


# TwinCAT System Service - ADS-over-MQTT
$tcSysSrvRoutesPath = "C:\TwinCAT\3.1\Target\Routes"
$tcSysSrvRoutesName = "AdsOverMqtt.xml"
$tcSysSrvAdsMqttClientCert = "TwinCAT_XAE.pem"
$tcSysSrvAdsMqttClientKey = "TwinCAT_XAE.key"

# Mosquitto
$mosquittoPath = "C:\Program Files (x86)\mosquitto"
$mosquittoConf = "mosquitto.conf"
$mosquittoServerCert = "server.pem"
$mosquittoServerKey = "server.key"
