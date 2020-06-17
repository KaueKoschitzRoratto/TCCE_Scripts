Add-Type -AssemblyName System.Windows.Forms

# Global variables that are required by the base script even without init
$global:regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$global:regKeyCloudEng = "TwinCAT Cloud Engineering"
$global:regKeyBase = $regKeyBeckhoff + $regKeyCloudEng
$global:regKeyPropertyHostname = "Hostname"

# Retrieve public hostname of instance and store in registry to detect if InitScript needs to run again (Clone)
# IMDSv2
#$token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token
#$global:hostname = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/public-hostname
#$global:publicIp = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/public-ipv4
# IMDSv1
$global:hostname = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/public-hostname
$global:publicIp = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/public-ipv4

$init = $false
if (-Not (Test-Path $regKeyBase)) {
    New-Item -Path $regKeyBeckhoff -Name $regKeyCloudEng
    New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
}
else {
    $hostnameReg = Get-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname
    if ($hostnameReg.Hostname -ne $hostname) {
        Set-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
        $init = $true
    }
}

if($init)
{
    # Load global settings
    Invoke-Expression ".\scripts\Init_Settings.ps1"
    
    # Warn user about init scripts
    [System.Windows.Forms.MessageBox]::Show("A new or cloned virtual machine has been detected, which requires the one-time execution of an initialization script. Please click on OK to continue and do not close the command prompt window. A separate message box will notify you once the script has been executed.",“TwinCAT Cloud Engineering init script“,0)

    # Start initialization scripts
    Invoke-Expression ".\scripts\Init_Start.ps1"

    # Restart Windows
    [System.Windows.Forms.MessageBox]::Show("Windows will be restarted now to finish the initialization script...",“TwinCAT Cloud Engineering init script“,0)
    Restart-Computer
}