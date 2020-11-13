$downloadUrl = "https://tcce-downloads.s3.eu-central-1.amazonaws.com/tcflare/TcFlare_Code.zip"
$tempDirectory = "C:\Temp"
$tempFile = "$tempDirectory\TcFlare_Code.zip"

if (-not(Test-Path $tempDirectory)) {
	$dir = New-Item -Path $tempDirectory -ItemType "directory"
}

if (Test-Path $tempFile) {
	$rmv = Remove-Item -Path $tempFile
}

# Download samples via BITS or Invoke-WebRequest
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

# Extract archive to Administrator Desktop directory
$zip = Expand-Archive -Path $tempFile "C:\Users\Administrator\Desktop"