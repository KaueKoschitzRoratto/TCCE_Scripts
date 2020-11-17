param ($Version='master')

$repoUrl = "https://tcce-downloads.s3.eu-central-1.amazonaws.com/tcceinitscripts/TcCloudEngineeringInitScripts_" + $Version + ".zip"
$repoUrlApi = $repoUrl + "?tagging"

# Acquire repository release info - either for a specific version or latest-greatest
$releaseInfo = Invoke-RestMethod -Uri $repoUrlApi
$selectedVersion = $releaseInfo.Tagging.TagSet.Tag.Value

# Read currently installed Agent version from Windows Registry and compare with latest version on remote repo
$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyInitScriptsProp = "InitScriptsVersion"
$install = $false

$regKeyExists = Test-Path $regKeyBeckhoff$regKeyCloudEng
if (-not $regKeyExists) {
    $key = New-Item -Path $regKeyBeckhoff -Name $regKeyCloudEng
}

$installedVersion = Get-ItemProperty -Path $regKeyCloudEng -Name $regKeyInitScriptsProp -ErrorAction SilentlyContinue
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
	$install = $true
}

# Only install if latest version on repo is newer or if InitScripts have not been installed yet
if ($install) {

    # Build download URL and temporary target path
    $downloadUrl = $repoUrl
    $tempDirectory = "C:\Temp"
    $tempFile = "$tempDirectory\TcCloudEngineeringInitScripts_" + $Version + ".zip"

    if (-not(Test-Path $tempDirectory)) {
        $dir = New-Item -Path $tempDirectory -ItemType "directory"
    }

    if (Test-Path $tempFile) {
        $rmv = Remove-Item -Path $tempFile
    }

    # Download release binary via BITS or Invoke-WebRequest
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

    # Stop TwinCAT Cloud Engineering Agent service
    $serviceName = "TcCloudEngineeringAgent"
    if (-not ((Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -eq $null)) {
        $svc = Stop-Service -Name $serviceName
    }

	$scriptsDirectory = ""
    # Check if scripts directory already exists - if not, then create it
    $scriptsDirectory = "C:\Program Files (x86)\Beckhoff Automation\TcCloudEngineeringInitScripts"
    if (-not (Test-Path $scriptsDirectory)) {
        $dir = New-Item -Path $scriptsDirectory -ItemType "directory"
    }

    # Remove existing files
    $rmv = Remove-Item -Recurse -Force $scriptsDirectory

    # Extract archive to scripts directory
    $zip = Expand-Archive -Path $tempFile $scriptsDirectory

    # Write installed scripts version to Windows Registry
    if (Test-Path $regKeyCloudEng) {
        $prop = Get-ItemProperty -Path $regKeyCloudEng -Name $regKeyInitScriptsProp -ErrorAction SilentlyContinue
        if ($prop -eq $null) {
            $key = New-ItemProperty -Path $regKeyCloudEng -Name $regKeyInitScriptsProp -Value $selectedVersion
        }
        else {
            $rmv = Remove-ItemProperty -Path $regKeyCloudEng -Name $regKeyInitScriptsProp
            $key = New-ItemProperty -Path $regKeyCloudEng -Name $regKeyInitScriptsProp -Value $selectedVersion
        }
    }
}