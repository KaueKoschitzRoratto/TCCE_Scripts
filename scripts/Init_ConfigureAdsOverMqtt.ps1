Write-Host "Starting configuration of TwinCAT System Service for ADS-over-MQTT..."

# Remove any existing ADS-over-MQTT routes file but create a backup first
if (-not (Test-Path -Path $tcSysSrvRoutesPath)) {
  New-Item -Path $tcSysSrvRoutesPath -ItemType "directory"
}
if (Test-Path -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName") {
    Copy-Item -Path "$tcSysSrvRoutesPath\$tcSysSrvRoutesName" -Destination "$tcSysSrvRoutesPath\$tcSysSrvRoutesName.bak"
    Remove-Item -Recurse -Force "$tcSysSrvRoutesPath\$tcSysSrvRoutesName"
}

# Create new routes file for ADS-over-MQTT
if (-not (Test-Path -Path "$tcSysSrvRoutesPath\$templateRoutesFile")) {
  Copy-Item -Path "$repoPathInitScripts\configs\$templateRoutesFile" -Destination "$tcSysSrvRoutesPath\$templateRoutesFile"
}
$routesContent = Get-Content -Path "$tcSysSrvRoutesPath\$templateRoutesFile" -Raw
$routesContent = $routesContent.Replace("%hostname%", $publicIp)
$routesContent = $routesContent.Replace("%port%", "8883")
$routesContent = $routesContent.Replace("%caCertPath%", "$caPath\$caCert")
$routesContent = $routesContent.Replace("%clientCertPath%", "$caPath\$tcSysSrvAdsMqttClientCert")
$routesContent = $routesContent.Replace("%clientKeyPath%", "$caPath\$tcSysSrvAdsMqttClientKey")

Set-Content -Path $tcSysSrvRoutesPath\$templateRoutesFile -Value $routesContent

# Restart of TcSysSrv service required -> will be performed by reboot anyway