Write-Host "Starting creation of user account for Tcce Agent Windows service..."

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

$serviceName = "TcCloudEngineeringAgent"
$username = "Tcce_User_Agent"
$executable = "AgentV2.exe"

$folderPath = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringAgent"
$description = "TwinCAT Cloud Engineering Agent"
$displayName = "TwinCAT Cloud Engineering Agent"

$username = "Tcce_User_Agent"
$groupName = "Tcce_Group_Agent"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

Write-Host "Password: $password"

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for Tcce Agent Windows service" -Password $passwordSec
Add-LocalGroupMember -Group $groupName -Member $username

# User account has been created, now create Windows service
$username = "$env:computername\$username"
$psCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $passwordSec

$exeName = "$executable"
$exePath = "$folderPath\$exeName"

New-Service -Name $serviceName -BinaryPathName $exePath -Credential $psCredentials -Description $description -DisplayName $displayName -StartupType Automatic