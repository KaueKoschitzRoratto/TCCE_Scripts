param ($NoPrompt=$false)

# This script isolates one CPU core
$proc = Get-WmiObject -class Win32_processor
$logicalProcessors = $proc.NumberOfLogicalProcessors
$logicalProcessorsNew = $logicalProcessors - 1
Start-Process -Wait -WindowStyle Hidden -FilePath "bcdedit" -ArgumentList "/set numproc $logicalProcessorsNew"

if (-not $NoPrompt) {
    Write-Host "Script execution finished. Press ENTER to continue and restart the system. Otherwise just clone this window."
    Read-Host
	Restart-Computer
}