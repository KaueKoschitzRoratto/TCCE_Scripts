# Add firewall rule for MQTT/TLS if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_Mqtt" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_Mqtt" -Description "Allows incoming traffic to port 8883/tcp (MQTT with TLS)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8883 -Enabled "False"
}

# Add firewall rule for OPC UA Gateway if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_TcOpcUaGateway" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_TcOpcUaGateway" -Description "Allows incoming traffic to port 48050/tcp (OPC UA Gateway)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 48050 -Enabled "False"
}

# Add firewall rule for TwinCAT HMI if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_TcHmi" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_TcHmi" -Description "Allows incoming traffic to ports 1010/tcp and 1020/tcp (TwinCAT HMI)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1010,1020 -Enabled "False"
}

# Add firewall rule for Agent communication (required for internal comm - do not change) if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_Agent" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_Agent" -Description "Allows incoming traffic to port 444/tcp (Tcce Agent)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 444 -Enabled "True"
}

# Add firewall rule for ADS Discovery if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_AdsDiscovery" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_AdsDiscovery" -Description "Allows incoming traffic to port 48899/udp (TwinCAT ADS Discovery)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 48899 -Enabled "False"
}

# Add firewall rule for ADSSecure if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_AdsSecure" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_AdsSecure" -Description "Allows incoming traffic to port 8016/tcp (TwinCAT SecureADS)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8016 -Enabled "False"
}

# Add firewall rule for SSH if it does not exist
$existingRule = Get-NetFirewallRule -DisplayName "Tcce_Ssh" -ErrorAction SilentlyContinue
if ($existingRule -eq $null) {
    $newRule = New-NetFirewallRule -DisplayName "Tcce_Ssh" -Description "Allows incoming traffic to port 22/tcp (SSH)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8016 -Enabled "True"
}