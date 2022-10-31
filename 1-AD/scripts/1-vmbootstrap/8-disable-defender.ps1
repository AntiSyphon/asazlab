[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
mkdir c:\ASAZ
cd c:\ASAZ
Add-MpPreference -ExclusionPath C:\ASAZ
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender” -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
Uninstall-WindowsFeature -Name Windows-Defender –whatif
IEX(New-Object Net.Webclient).DownloadString('https://github.com/AntiSyphon/asazlab/raw/main/1-AD/scripts/1-vmbootstrap/9-disable-defender.ps1') 



