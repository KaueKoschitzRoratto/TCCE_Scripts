Write-Host "Starting creation of user account for TcOpcUaGateway auth..."

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
$executable = "TcCloudEngineeringUaServer.exe"

$folderPath = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringUaServer"
$description = "TwinCAT Cloud Engineering OPC UA Server"
$displayName = "TwinCAT Cloud Engineering OPC UA Server"

$username = "Tcce_User_OpcUa"
$groupName = "Tcce_Group_OpcUa"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for TCCE OPC UA Server" -Password $passwordSec
Add-LocalGroupMember -Group $groupName -Member $username

# User account has been created, now create Windows service
$usernameInclComputername = "$env:computername\$username"
$psCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $usernameInclComputername, $passwordSec

$exeName = "$executable"
$exePath = "$folderPath\$exeName"

New-Service -Name $serviceName -BinaryPathName $exePath -Credential $psCredentials -Description $description -DisplayName $displayName -StartupType Automatic

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$templateReadmePath\$templateReadmeFile")) {
  Copy-Item -Path "$repoPathInitScripts\templates\$templateReadmeFile" -Destination "$templateReadmePath\$templateReadmeFile"
}
$readmeContent = Get-Content -Path "$templateReadmePath\$templateReadmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameOpcUa%", $username)
$readmeContent = $readmeContent.Replace("%passwordOpcUa%", $password)

Set-Content -Path $templateReadmePath\$templateReadmeFile -Value $readmeContent