Write-Host "Creating local registry keys..."

if(Test-Path -Path "$regKeyBase") {
    # Create registry property to store CA path
    New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyCaPath -Value $caPath
    # Create registry property to store path to TCCE_InitScripts repository
    New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyInitScriptsRepo -Value $repoPathInitScripts
    # Create registry property to store public IP
    New-ItemProperty -Path $regKeyBase -Name $regKeyPropertyPublicIp -Value $publicIp
}
