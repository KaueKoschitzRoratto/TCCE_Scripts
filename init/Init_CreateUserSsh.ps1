Write-Host "Starting creation of user account for SSH auth..."

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

$username = "Tcce_User_SSH"
$groupName = "Tcce_Group_SSH"
$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for SSH authentication" -Password $passwordSec
Add-LocalGroupMember -Group $groupName -Member $username

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$templateReadmePath\$templateReadmeFile")) {
  Copy-Item -Path "$repoPathInitScripts\configs\$templateReadmeFile" -Destination "$templateReadmePath\$templateReadmeFile"
}
$readmeContent = Get-Content -Path "$templateReadmePath\$templateReadmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameSsh%", $username)
$readmeContent = $readmeContent.Replace("%passwordSsh%", $password)

Set-Content -Path $templateReadmePath\$templateReadmeFile -Value $readmeContent