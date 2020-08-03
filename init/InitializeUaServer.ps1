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

$serviceName = "TcCloudEngineeringUaServer"
$username = "Tcce_User_OpcUa"
$executable = "TcCloudEngineeringUaServer.exe"

$folderPath = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringUaServer"
$description = "TwinCAT Cloud Engineering OPC UA Server"
$displayName = "TwinCAT Cloud Engineering OPC UA Server"

$username = "Tcce_User_Agent"
$groupName = "Tcce_Group_Agent"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    $rmv = Remove-LocalUser -Name $username
}
$usr = New-LocalUser -Name $username -FullName $username -Description "Account for Tcce Agent Windows service" -Password $passwordSec
$grp = Add-LocalGroupMember -Group $groupName -Member $username

# User account has been created, now install Agent and create Windows service
$username = "$env:computername\$username"
$psCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $passwordSec

$exeName = "$executable"
$exePath = "$folderPath\$exeName"

# Install Agent
Invoke-Expression "$PSScriptRoot\..\user\InstallUpdateUaServer.ps1"

# Create Windows Service
$svc = New-Service -Name $serviceName -BinaryPathName $exePath -Credential $psCredentials -Description $description -DisplayName $displayName -StartupType Automatic
