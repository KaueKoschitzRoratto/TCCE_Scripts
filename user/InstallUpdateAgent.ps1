param ($Version='latest')

$repoUrl = "https://github.com/SvenGoldstein/Tcce_Agent"
$repoUrlApi = "https://api.github.com/repos/SvenGoldstein/Tcce_Agent"
$releaseBinaryName = "TcCloudEngineeringAgent.zip"

# Acquire repository release info - either for a specific version or latest-greatest
$apiUrl = "$repoUrlApi/releases/$Version"
$releaseInfo = Invoke-RestMethod -Uri $apiUrl
$selectedVersion = $releaseInfo.tag_name

# Read currently installed Agent version from Windows Registry and compare with latest version on remote repo
$regKey = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT Cloud Engineering"
$regKeyAgentProp = "AgentVersion"
$install = $false
if (Test-Path $regKey) {
    $installedVersion = Get-ItemProperty -Path $regKey -Name $regKeyAgentProp -ErrorAction SilentlyContinue
    if (-not ($installedVersion -eq $null)) {
        # Existing Agent installation found -> check if latest version on remote repo is newer
        $selectedVersionObj = [version]$selectedVersion
        $installedVersionObj = [version]$installedVersion.AgentVersion
        if ($selectedVersionObj -gt $installedVersionObj) {
            # Latest release version is newer -> install
            $install = $true
        }
    }
    else {
        # No Agent has been installed -> install
        $install = $true
    }
}

# Only install if latest version on repo is newer or if no Agent has been installed at all

if ($install) {

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
    $serviceName = "TcCloudEngineeringAgent"
    if (-not (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -eq $null) {
        Stop-Service -Name $serviceName
    }

    # Check if Agent directory already exists - if not, then create it
    $agentDirectory = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringAgent"
    if (-not (Test-Path $agentDirectory)) {
        New-Item -Path $agentDirectory -ItemType "directory"
    }

    # Remove existing Agent files
    Remove-Item -Recurse -Force $agentDirectory

    # Extract archive to Agent directory
    Expand-Archive -Path $tempFile $agentDirectory

    # Write installed Agent version to Windows Registry
    if (Test-Path $regKey) {
        $prop = Get-ItemProperty -Path $regKey -Name $regKeyAgentProp -ErrorAction SilentlyContinue
        if ($prop -eq $null) {
            New-ItemProperty -Path $regKey -Name $regKeyAgentProp -Value $selectedVersion
        }
        else {
            Remove-ItemProperty -Path $regKey -Name $regKeyAgentProp
            New-ItemProperty -Path $regKey -Name $regKeyAgentProp -Value $selectedVersion
        }
    }

    # Start TwinCAT Cloud Engineering Agent service
    if (-not (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -eq $null) {
        Start-Service -Name $serviceName
    }

}