Write-Host "Starting reset of AMS Net ID..."

# Reading current AmsNetId from Windows Registry
$amsNetId = Get-ItemProperty -Path $regKeyTcSystem -Name $regKeyPropertyAmsNetId

# Using public IP from EC2 meta data service
$ipAddrArr = $publicIp.Split(".")

# Stopping TwinCAT System Service and all dependencies
Stop-Service -Name "TcSysSrv"

# Setting new AMS Net ID based on local IP address, the last two bytes from old AMS Net ID are kept
$amsNetId.AmsNetId[0] = $ipAddrArr[0]
$amsNetId.AmsNetId[1] = $ipAddrArr[1]
$amsNetId.AmsNetId[2] = $ipAddrArr[2]
$amsNetId.AmsNetId[3] = $ipAddrArr[3]
Set-ItemProperty -Path $regKeyTcSystem -Name $regKeyPropertyAmsNetId -Value $amsNetId.AmsNetId

# Starting TwinCAT System Service
Start-Service -Name "TcSysSrv"