param ($Hostname)

Write-Host "Configuring Mosquitto for hostname: $Hostname"

function Get-RandomCharacters($length, $characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs="" 
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

$mosquittoPath = "C:\Program Files\mosquitto"
$executable = "mosquitto.exe"
$mosquittoConf = "mosquitto.conf"
$mosquittoServerCert = "mosquitto.pem"
$mosquittoServerCsr = "mosquitto.csr"
$mosquittoServerKey = "mosquitto.key"

$caPath = "C:\CA"
$caConfig = "openssl_ca.cnf"
$caCert = "rootCA.pem"
$caCrl = "rootCA.crl"

# Remove any existing files
if (Test-Path -Path "$caPath\$mosquittoServerCert") {
    $rmv = Remove-Item -Recurse -Force "$caPath\$mosquittoServerCert"
}
if (Test-Path -Path "$caPath\$mosquittoServerKey") {
    $rmv = Remove-Item -Recurse -Force "$caPath\$mosquittoServerKey"
}
if (Test-Path -Path "$caPath\$mosquittoServerCsr") {
    $rmv = Remove-Item -Recurse -Force "$caPath\$mosquittoServerCsr"
}

# Generate new private key
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "genrsa -out $mosquittoServerKey 4096"

# Generate self-signed certificate
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "req -config $caConfig -new -sha256 -key $mosquittoServerKey -out $mosquittoServerCsr -subj /C=DE/ST=NRW/L=Verl/O=BeckhoffAutomation/OU=ServerCert/CN=$Hostname"

# Sign self-signed certificate by certificate authority
Start-Process -Wait -WindowStyle Hidden -FilePath "openssl.exe" -WorkingDirectory $caPath -ArgumentList "ca -config $caConfig -batch -days 7300 -notext -md sha256 -in $mosquittoServerCsr -extensions server_cert -out $mosquittoServerCert"

$mosquittoConfContent = @"
listener 8883`n
allow_anonymous true`n
require_certificate true`n
`n
cafile $caPath\$caCert`n
crlfile $caPath\$caCrl`n
certfile $caPath\$mosquittoServerCert`n
keyfile $caPath\$mosquittoServerKey`n
"@

# Remove any existing configuration file but create a backup first
if (Test-Path -Path "$mosquittoPath\$mosquittoConf") {
    $cpy = Copy-Item -Path "$mosquittoPath\$mosquittoConf" -Destination "$mosquittoPath\$mosquittoConf.bak"
    $rmv = Remove-Item -Recurse -Force "$mosquittoPath\$mosquittoConf"
}

# Create new configuration file
$file = New-Item -Path "$mosquittoPath\$mosquittoConf" -Value $mosquittoConfContent

# Create new user account if it does not exist
$username = "Tcce_User_Mosquitto"
$groupName = "Tcce_Group_Mosquitto"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    $rmv = Remove-LocalUser -Name $username
}
$usr = New-LocalUser -Name $username -FullName $username -Description "Account for Mosquitto service" -Password $passwordSec
$grp = Add-LocalGroupMember -Group $groupName -Member $username

# User account has been created, now create Windows service
$username = "$env:computername\$username"
$psCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $passwordSec

$serviceName = "Mosquitto"
$description = "Mosquitto Message Broker"
$displayName = "Mosquitto Message Broker"

$exeName = "$executable"
$exePath = "$mosquittoPath\$exeName run"

# Create Windows Service
$svc = Get-Service -Name $serviceName
if (-not ($svc -eq $null)) {
    Start-Process -Wait -WindowStyle Hidden -FilePath "sc.exe" -WorkingDirectory $mosquittoPath -ArgumentList "delete $serviceName"
}
$svc = New-Service -Name $serviceName -BinaryPathName $exePath -Credential $psCredentials -Description $description -DisplayName $displayName -StartupType Automatic