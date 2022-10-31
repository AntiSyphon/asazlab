[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
mkdir c:\ASAZ
cd c:\ASAZ
Add-MpPreference -ExclusionPath C:\ASAZ
IEX(New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/AntiSyphon/asazlab/main/1-AD/scripts/1-vmbootstrap/9-disable-defender%20.ps1') 
                                              



