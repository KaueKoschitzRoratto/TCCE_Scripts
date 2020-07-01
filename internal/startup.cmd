cd C:\git
rmdir /s /q TCCE_InitScripts
git clone https://github.com/Beckhoff/TCCE_InitScripts.git TCCE_InitScripts
cd TCCE_InitScripts
PowerShell C:\git\TCCE_InitScripts\system\Startup.ps1