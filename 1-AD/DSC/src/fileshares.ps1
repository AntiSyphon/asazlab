


configuration fileshares {
    param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds

    ) 
    
    Import-DscResource -ModuleName ActiveDirectoryDsc, NetworkingDsc, xPSDesiredStateConfiguration, ComputerManagementDsc
    
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)

    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminCreds.Password)
    $AdminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $ComputerName = Get-Content env:computername

    Node localhost
    {
        LocalConfigurationManager
        {           
            ConfigurationMode   = 'ApplyOnly'
            RebootNodeIfNeeded  = $true
        }

        # ***** Create Domain Users *****
        xScript CreateFileShares
        {
            SetScript = 
            {
 
                Write-Host "adding directories "

                try
                {
                    mkdir c:\ASAZ\FileShares\
                    mkdir c:\ASAZ\FileShares\Accounting
                    mkdir c:\ASAZ\FileShares\HR
                    mkdir c:\ASAZ\FileShares\ExecutiveOffice
                    mkdir c:\ASAZ\FileShares\IT
                    mkdir c:\ASAZ\FileShares\Security
                }
                catch 
                {
                    Write-Host "error attempting to make new directories for fileshares"
                }


                Write-Host "adding fileshares"

                try
                {
                    New-SMBShare -Name "Accounting" -Path c:\ASAZ\FileShares\Accounting -FullAccess sec_filesadmins -ChangeAccess sec_files_Accounting-rw -ReadAccess sec_files_Accounting-ro -NoAccess sec_files_Accounting-d
                    New-SMBShare -Name "HR" -Path c:\ASAZ\FileShares\Accounting -FullAccess sec_filesadmins -ChangeAccess sec_files_HR-rw -ReadAccess sec_files_HR-ro -NoAccess sec_files_HR-d
                    New-SMBShare -Name "ExecutiveOffice" -Path c:\ASAZ\FileShares\Accounting -FullAccess sec_filesadmins -ChangeAccess sec_files_ExecutiveOffice-rw -ReadAccess sec_files_ExecutiveOffice-ro -NoAccess sec_files_ExecutiveOffice-d
                    New-SMBShare -Name "IT" -Path c:\ASAZ\FileShares\Accounting -FullAccess sec_filesadmins -ChangeAccess sec_files_IT-rw -ReadAccess sec_files_IT-ro -NoAccess sec_files_IT-d
                    New-SMBShare -Name "Security" -Path c:\ASAZ\FileShares\Accounting -FullAccess sec_filesadmins -ChangeAccess sec_files_Security-rw -ReadAccess sec_files_Security-ro -NoAccess sec_files_Security-d
                }
                catch 
                {
                    Write-Host "error attempting to create fileshares"
                }


                Write-Host "completed fileshares DSC"

            }

            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                return $false
            }
        }
    }
}



function Get-NetBIOSName {
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length = $DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length = 15
        }
        return $DomainFQDN.Substring(0, $length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0, 15)
        }
        else {
            return $DomainFQDN
        }
    }
}