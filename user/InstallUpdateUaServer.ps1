param ($Version='latest')

$repoUrl = "https://tcce-downloads.s3.eu-central-1.amazonaws.com/tcceuaserver/TcCloudEngineeringUaServer_" + $Version + ".zip"
$repoUrlApi = $repoUrl + "?tagging"

# Acquire repository release info - either for a specific version or latest-greatest
$releaseInfo = Invoke-RestMethod -Uri $repoUrlApi
$selectedVersion = $releaseInfo.Tagging.TagSet.Tag.Value

# Read currently installed Agent version from Windows Registry and compare with latest version on remote repo
$regKey = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT Cloud Engineering"
$regKeyAgentProp = "UaServerVersion"
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
    $downloadUrl = $repoUrl
    $tempDirectory = "C:\Temp"
    $tempFile = "$tempDirectory\TcCloudEngineeringUaServer_" + $Version + ".zip"

    if (-not(Test-Path $tempDirectory)) {
        $dir = New-Item -Path $tempDirectory -ItemType "directory"
    }

    if (Test-Path $tempFile) {
        $rmv = Remove-Item -Path $tempFile
    }

    # Download release binary via BITS or Invoke-WebRequest
    #Invoke-Expression -Command "bitsadmin /NOWRAP /transfer TcCloudEngineeringAgentUpdate /dynamic /download /priority FOREGROUND $downloadUrl $tempFile"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

    # Stop TwinCAT Cloud Engineering Agent service
    $serviceName = "TcCloudEngineeringUaServer"
    if (-not ((Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -eq $null)) {
        $svc = Stop-Service -Name $serviceName
    }

    # Check if Agent directory already exists - if not, then create it
    $agentDirectory = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringUaServer"
    if (-not (Test-Path $agentDirectory)) {
        $dir = New-Item -Path $agentDirectory -ItemType "directory"
    }

    # Remove existing Agent files
    $rmv = Remove-Item -Recurse -Force $agentDirectory

    # Extract archive to Agent directory
    $zip = Expand-Archive -Path $tempFile $agentDirectory

    # Write installed Agent version to Windows Registry
    if (Test-Path $regKey) {
        $prop = Get-ItemProperty -Path $regKey -Name $regKeyAgentProp -ErrorAction SilentlyContinue
        if ($prop -eq $null) {
            $key = New-ItemProperty -Path $regKey -Name $regKeyAgentProp -Value $selectedVersion
        }
        else {
            $rmv = Remove-ItemProperty -Path $regKey -Name $regKeyAgentProp
            $key = New-ItemProperty -Path $regKey -Name $regKeyAgentProp -Value $selectedVersion
        }
    }

    # Start TwinCAT Cloud Engineering UA Server service
    if (-not ((Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -eq $null)) {
        $svc = Start-Service -Name $serviceName
    }
}