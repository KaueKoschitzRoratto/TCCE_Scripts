Add-Type -AssemblyName System.Windows.Forms

# Global variables that are required by the base script even without init
$regKeyBeckhoff = "HKLM:\SOFTWARE\WOW6432Node\Beckhoff\"
$regKeyCloudEng = "TwinCAT Cloud Engineering"
$regKeyBase = $regKeyBeckhoff + $regKeyCloudEng
$regKeyPropertyHostname = "Hostname"

# IMDSv1 - Retrieve public hostname of instance and store in registry to detect if InitScript needs to run again (Clone)
$hostname = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/public-hostname
$publicIp = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/public-ipv4

# Check if initialization has to be started (new or cloned instance)
$init = $false
if (-Not (Test-Path $regKeyBase)) {
    $key = New-Item -Path $regKeyBeckhoff -Name $regKeyCloudEng
    $key = New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
    $init = $true # reg key does not exist -> new instance -> init
}
else {
    $hostnameReg = Get-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname
    if ($hostnameReg.Hostname -ne $hostname) {
        $init = $true # hostname differs -> cloned instance -> init
    }
}

if($init)
{
    # Total initilization steps for progress bar
    $progressStepsTotal = 12

    # Warn user about init scripts
    [System.Windows.Forms.MessageBox]::Show("A new or cloned virtual machine has been detected. This requires execution of an initialization script. Do not close the command prompt window. A separate message box will notify you once the init script has finished.",“TwinCAT Cloud Engineering init script“,0)

    # Create registry keys
    $currentStep = 1
    Write-Progress -Activity "Initialization" -Status "Initialize registry keys" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    if(Test-Path -Path "$regKeyBase") {
        # Write hostname to registry
        $key = Set-ItemProperty -Path $regKeyBase -Name $regKeyPropertyHostname -Value $hostname
        # Create registry property to store path to TCCE_InitScripts repository
        $key = New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyInitScriptsRepo -Value $repoPathInitScripts
        # Create registry property to store public IP
        $key = New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyPublicIp -Value $publicIp
    }

    # Initialize Certificate Authority
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize Certificate Authority" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\CreateCertificateAuthority.ps1"

    # Initialize TwinCAT OPC UA Server
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT OPC UA Server" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\InitializeTcOpcUaServer.ps1 -Hostname $hostname"

    # Initialize TwinCAT OPC UA Gateway
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT OPC UA Gateway" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\InitializeTcOpcUaGateway.ps1 -Hostname $hostname -PublicIp $publicIp"

    # Initialize TwinCAT System Service with ADS-over-MQTT route
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT ADS-over-MQTT" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\InitializeAdsOverMqtt.ps1 -Hostname $publicIp"

    # Initialize TwinCAT Cloud Engineering Agent
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize TwinCAT Cloud Engineering Agent" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\InitializeAgent.ps1"

    # Initialize Mosquitto message broker
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Initialize Mosquitto message broker" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\InitializeMosquitto.ps1 -Hostname $publicIp"

    # Reset AMS Net ID
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Reset AMS Net ID" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\ResetAmsNetId.ps1 -PublicIp $publicIp"

    # Create user account for TcOpcUaGateway
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Create OPC UA user" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\CreateUserOpcUa.ps1"

    # Create user account for SSH access
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Create SSH user" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\CreateUserSsh.ps1"

    # Create user account for ADS routes (TcAdmin)
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Create TcAdmin user" -PercentComplete ($currentStep / $progressStepsTotal * 100)
    Invoke-Expression "$PSScriptRoot\..\init\CreateUserTcAdmin.ps1"

    # Add Windows Firewall rules
    $currentStep = $currentStep + 1
    Write-Progress -Activity "Initialization" -Status "Add Firewall rules" -PercentComplete ($currentStep / $totalSteps * 100)
    Invoke-Expression "$PSScriptRoot\..\init\AddFirewallRules.ps1"

    # Restart Windows
    [System.Windows.Forms.MessageBox]::Show("Windows will be restarted now to finish the initialization script...",“TwinCAT Cloud Engineering init script“,0)
    Restart-Computer
}

# Start TCCE Agent update
Invoke-Expression "$PSScriptRoot\..\user\InstallUpdateAgent.ps1"