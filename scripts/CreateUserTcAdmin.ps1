param ($PublicIp)

$templateReadmePath = "C:\Users\Administrator\Desktop"
$templateReadmeFile = "readme.txt"

$repoPathInitScripts = "C:\git\TCCE_Scripts"

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

$username = "Tcce_User_TcAdmin"
$groupName = "TcAdmin"

$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    $rmv = Remove-LocalUser -Name $username
}
$usr = New-LocalUser -Name $username -FullName $username -Description "Account that allows ADS routes" -Password $passwordSec
$grp = Add-LocalGroupMember -Group $groupName -Member $username

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$templateReadmePath\$templateReadmeFile")) {
  $cpy = Copy-Item -Path "$PSScriptRoot\..\templates\$templateReadmeFile" -Destination "$templateReadmePath\$templateReadmeFile"
}
$readmeContent = Get-Content -Path "$templateReadmePath\$templateReadmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $PublicIp)
$readmeContent = $readmeContent.Replace("%usernameTcAdmin%", $username)
$readmeContent = $readmeContent.Replace("%passwordTcAdmin%", $password)

$xml = Set-Content -Path $templateReadmePath\$templateReadmeFile -Value $readmeContent