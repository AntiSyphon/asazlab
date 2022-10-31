# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Resolve-DnsName github.com
Resolve-DnsName raw.githubusercontent.com
Resolve-DnsName live.sysinternals.com

$wc = new-object System.Net.WebClient
# Download BgInfo
$wc.DownloadFile('http://live.sysinternals.com/bginfo.exe', 'C:\ProgramData\bginfo.exe')

# Copy Wallpaper
$wc.DownloadFile('https://github.com/AntiSyphon/asazlab/raw/main/1-AD/resources/AS.jpg', 'C:\ProgramData\AS.jpg')

# Copy BGInfo config
$wc.DownloadFile('https://github.com/AntiSyphon/asazlab/raw/main/1-AD/resources/asazlab.bgi', 'C:\ProgramData\asazlab.bgi')

# Set Run Key
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "BgInfo" -Value "C:\ProgramData\bginfo.exe C:\ProgramData\asazlab.bgi /silent /timer:0 /nolicprompt" -PropertyType "String" -force