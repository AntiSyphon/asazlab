[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
mkdir c:\ASAZ
cd c:\ASAZ
Invoke-WebRequest -URI https://github.com/Relkci/BadBlood/archive/refs/heads/master.zip -OutFile BadBlood.zip
Expand-Archive .\BadBlood.zip
Remove-Item .\BadBlood.zip
cd c:\ASAZ\BadBlood\BadBlood-master\
Set-ExecutionPolicy bypass -force
.\Invoke-BadBlood.ps1 -GroupCount 50 -Usercount 50 -ComputerCount 50 -NonInteractive

