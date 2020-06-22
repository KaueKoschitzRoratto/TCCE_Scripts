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

$username = "Tcce_User_SSH"
$password = Get-RandomCharacters -length 12 -characters 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?@#+'
$password = Scramble-String($password)
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force
$groupName = "SSHUsers"

$credNotePath = "C:\Users\Administrator\Desktop\Readme_SSH.txt"
$credNoteContent = @"
User credentials for SSH:`n
Username: $username`n
Password: $password`n
Please store these credentials in a save location and delete this file.
"@

# Create new user account if it does not exist
$account = Get-LocalUser -Name $username
if (-not ($account -eq $null)) {
    Remove-LocalUser -Name $username
}
New-LocalUser -Name $username -FullName $username -Description "Account for SSH authentication" -Password $passwordSec
Add-LocalGroupMember -Group $groupName -Member $username

# Store created user credentials on user's desktop as temporary note
if (Test-Path -Path $credNotePath) {
    Remove-Item -Path $credNotePath
}
New-Item -Path $credNotePath -Value $credNoteContent