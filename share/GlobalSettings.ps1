# Global variables, which are used by each script
$global:caPath = "C:\CA"
$global:caCertsPath = $caPath + "\certs"
$global:caConfig = "openssl_ca.cnf"
$global:caCert = "rootCA.pem"
$global:caKey = "rootCA.key"
$global:caCrl = "rootCA.crl"

# Template files from configs directory
$global:templateReadmePath = "C:\Users\Administrator\Desktop"
$global:templateReadmeFile = "readme.txt"
$global:templateRoutesFile = "AdsOverMqtt.xml"

# Windows Registry
$global:regKeyTc = $regKeyBeckhoff + "\TwinCAT3"
$global:regKeyTcSystem = $regKeyTc + "\System"
$global:regKeyPropertyCaPath = "CaPath"
$global:regKeyPropertyCaCertsPath = "CaCertsPath"
$global:regKeyPropertyAmsNetId = "AmsNetId"
$global:regKeyPropertyInitScriptsRepo = "InitScriptsRepoPath"
$global:regKeyPropertyPublicIp = "PublicIp"

# TwinCAT
$global:tcInstallDir = "C:\TwinCAT"
$global:tcFunctionsInstallDir = $tcInstallDir + "\Functions"

# Repository paths
$global:repoPathInitScripts = "C:\git\TCCE_Scripts"