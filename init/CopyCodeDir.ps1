$downloadUrl = "https://tcce-downloads.s3.eu-central-1.amazonaws.com/tcflare/TcFlare_Code.zip"
$tempDirectory = "C:\Temp"
$tempFile = "$tempDirectory\TcFlare_Code.zip"
$destDir = "C:\Users\Administrator\Desktop"

if (-not(Test-Path $tempDirectory)) {
	$dir = New-Item -Path $tempDirectory -ItemType "directory"
}

if (Test-Path $tempFile) {
	$rmv = Remove-Item -Path $tempFile
}

# Download samples via BITS or Invoke-WebRequest
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

# Remove existing files if there are any
if (Test-Path "$destDir\code") {
	$rmv = Remove-Item -Recurse -Force "$destDir\code"
}

# Extract archive to Administrator Desktop directory
$zip = Expand-Archive -Path $tempFile "C:\Users\Administrator\Desktop"