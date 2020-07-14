param ($Version='latest')

$repoUrl = "https://github.com/SvenGoldstein/Tcce_Agent"
$repoUrlApi = "https://api.github.com/repos/SvenGoldstein/Tcce_Agent"
$releaseBinaryName = "TcCloudEngineeringAgent.zip"

# Acquire repository release info - either for a specific version or latest-greatest
$apiUrl = "$repoUrlApi/releases/$Version"
$releaseInfo = Invoke-RestMethod -Uri $apiUrl
$selectedVersion = $releaseInfo.tag_name

# Build download URL and temporary target path
$downloadUrl = "$repoUrl/releases/download/$selectedVersion/$releaseBinaryName"
$tempDirectory = "C:\Temp"
$tempFile = "$tempDirectory\$releaseBinaryName"

if (-not(Test-Path $tempDirectory)) {
    New-Item -Path $tempDirectory -ItemType "directory"
}

if (Test-Path $tempFile) {
    Remove-Item -Path $tempFile
}

# Download release binary via BITS
Invoke-Expression -Command "bitsadmin /transfer TcCloudEngineeringAgentUpdate /dynamic /download /priority FOREGROUND $downloadUrl $tempFile"

# Stop TwinCAT Cloud Engineering Agent service
Stop-Service -Name TcCloudEngineeringAgent

# Check if Agent directory already exists - if not, then create it
$agentDirectory = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringAgent"
if (-not (Test-Path $agentDirectory)) {
    New-Item -Path $agentDirectory -ItemType "directory"
}

# Extract archive to Agent directory
Expand-Archive -Path $tempFile $agentDirectory

# Start TwinCAT Cloud Engineering Agent service
Start-Service -Name TcCloudEngineeringAgent