Write-Host "Starting reset of AMS Net ID..."

# Set service startup type to Automatic
Set-Service -Name "TwinCAT Cloud Control UA Server" -StartupType Automatic

# Start service
Start-Service -Name "TwinCAT Cloud Control UA Server"