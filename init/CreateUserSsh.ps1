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
$usernameAdmin = "Tcce_User_SSHAdmin"
$groupName = "Tcce_Group_SSH"
$groupNameAdmin = "Tcce_Group_SSHAdmins"
$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force
$passwordAdmin = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$passwordAdmin = Scramble-String($password)
$passwordSecAdmin = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for SSH authentication" -Password $passwordSec
Add-LocalGroupMember -Group $groupName -Member $username

# Create new user account if it does not exist
$account = Get-LocalUser -Name $usernameAdmin -ErrorAction SilentlyContinue
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $usernameAdmin
}
New-LocalUser -Name $usernameAdmin -FullName $usernameAdmin -Description "Account for SSH authentication" -Password $passwordSecAdmin
Add-LocalGroupMember -Group $groupNameAdmin -Member $usernameAdmin

# Store created user credentials on user's desktop as temporary note
if (-not (Test-Path -Path "$templateReadmePath\$templateReadmeFile")) {
  Copy-Item -Path "$repoPathInitScripts\templates\$templateReadmeFile" -Destination "$templateReadmePath\$templateReadmeFile"
}
$readmeContent = Get-Content -Path "$templateReadmePath\$templateReadmeFile" -Raw
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameSsh%", $username)
$readmeContent = $readmeContent.Replace("%passwordSsh%", $password)
$readmeContent = $readmeContent.Replace("%publicIp%", $publicIp)
$readmeContent = $readmeContent.Replace("%usernameSshAdmin%", $usernameAdmin)
$readmeContent = $readmeContent.Replace("%passwordSshAdmin%", $passwordAdmin)

Set-Content -Path $templateReadmePath\$templateReadmeFile -Value $readmeContent