Write-Host "Starting configuration of TcCloudEngineeringUaServer..."

# Set service startup type to Automatic
Set-Service -Name "TcCloudEngineeringUaServer" -StartupType Automatic

# Start service
Start-Service -Name "TcCloudEngineeringUaServer"