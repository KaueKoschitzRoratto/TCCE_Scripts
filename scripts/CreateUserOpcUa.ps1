$templateReadmePath = "C:\Users\Administrator\Desktop"
$templateReadmeFile = "readme.txt"

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

$username = "Tcce_User_OpcUaGtwy"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    $rmv = Remove-LocalUser -Name $username
}
$usr = New-LocalUser -Name $username -FullName $username -Description "Account for TCCE OPC UA Server" -Password $passwordSec

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$templateReadmePath\$templateReadmeFile")) {
  $cpy = Copy-Item -Path "$PSScriptRoot\..\templates\$templateReadmeFile" -Destination "$templateReadmePath\$templateReadmeFile"
}
$readmeContent = Get-Content -Path "$templateReadmePath\$templateReadmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameOpcUa%", $username)
$readmeContent = $readmeContent.Replace("%passwordOpcUa%", $password)

$xml = Set-Content -Path $templateReadmePath\$templateReadmeFile -Value $readmeContent