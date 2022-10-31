# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$SetupType
)

# Install DSC Modules
& .\2-Install-DSC-Modules.ps1 -SetupType $SetupType

# Custom Settings applied
& .\3-Prepare-Box.ps1

# Windows Security Audit Categories
if ($SetupType -eq 'DC')
{
    & .\4-Enable-WinAuditCategories.ps1 -SetDC
}
else
{
    & .\4-Enable-WinAuditCategories.ps1
}

# PowerShell Logging
& .\5-Enable-PowerShell-Logging.ps1

# Set SACLs
& .\6-Set-SACLs.ps1

# Set Wallpaper
& .\7-Set-WallPaper.ps1

# Disable Defender Bits
& .\8-disable-defender.ps1