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

$username = "Tcce_User_OpcUa"
$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for TcOpcUaGateway user authentication" -Password $passwordSec

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$readmePath\$readmeFile")) {
  Copy-Item -Path "$repoPathInitScripts\configs\$readmeFile" -Destination "$readmePath\$readmeFile"
}
$readmeContent = Get-Content -Path "$readmePath\$readmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameOpcUa%", $username)
$readmeContent = $readmeContent.Replace("%passwordOpcUa%", $password)

Set-Content -Path $readmePath\$readmeFile -Value $readmeContent