# Retrieve user-data to find corresponding repository + branch
$userData = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/user-data
$scriptRepo = $userData.Script_Repo
$scriptBranch = $userData.Script_Branch
if ($scriptBranch -eq $null) {
    $scriptBranch = $userData.Image_Version
}

$localRepoDir = "C:\git"
$localScriptsRepoName = "TCCE_Scripts"
$localScriptsRepoDir = "$localRepoDir\$localScriptsRepoName"

# Remove local repo clone if it exists
if (Test-Path -Path $localScriptsRepoDir) {
    Remove-Item -Recurse -Force $localScriptsRepoDir
}

# Clone repo branch
git clone --single-branch --branch $scriptBranch $scriptRepo $localScriptsRepoDir
cd $localScriptsRepoDir