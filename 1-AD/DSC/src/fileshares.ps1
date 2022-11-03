


configuration fileshares {
    param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds

    ) 
    
    Import-DscResource -ModuleName ActiveDirectoryDsc, NetworkingDsc, xPSDesiredStateConfiguration, xDnsServer, ComputerManagementDsc
    
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
 
                Write-Host "add SPNs DSC complete "

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

                Write-Host "adding OUs "

                try
                {
                    New-ADOrganizationalUnit -Name "SecurityGroups" -Path "DC=asazlab,DC=com"
                    New-ADOrganizationalUnit -Name "SG_FileShares" -Path "OU=SecurityGroups,DC=asazlab,DC=com"
                    New-ADOrganizationalUnit -Name "ServiceAdmins" -Path "DC=asazlab,DC=com"
                }
                catch 
                {
                    Write-Host "error attempting to make new OUs for fileshare groups"
                }

                Write-Host "adding fileadmin"

                try
                {
                    DSADD user -upn fileadmin@asazlab.com "cn=fileadmin,ou=ServiceAdmins,dc=asazlab,dc=com" -fn "file" -ln "admin" -disabled no -display "FileServiceAdmin"  -office "Administration"  -PWD "Adm1nP@55!"
                }
                catch
                {
                     Write-Host "error attempting adding fileadmin"
                }

                Write-Host "adding fileadmin  SPN"

                try
                {
                     setspn -a srv01/fileadmin.asazlab.com:1433 asazlab.com\fileadmin
                }
                catch
                {
                     Write-Host "error attempting adding fileadmin SPN"
                }

                Write-Host "adding groups "

                try 
                {
                    New-ADGroup "sec_filesadmins" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Accounting-rw" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_HR-rw" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_ExecutiveOffice-rw" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_IT-rw" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Security-rw" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Accounting-ro" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_HR-ro" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_ExecutiveOffice-ro" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_IT-ro" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Security-ro" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Accounting-d" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_HR-d" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_ExecutiveOffice-d" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_IT-d" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                    New-ADGroup "sec_files_Security-d" -Path "OU=SG_FileShares,OU=SecurityGroups,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru �Verbose
                }
                catch 
                {
                    Write-Host "error attempting to make newgroupos for fileshares"
                }

                Write-Host "adding group memberships "

                try
                {
                    ADD-ADGroupMember "sec_filesadmins" �members "fileadmin"
                    ADD-ADGroupMember "sec_filesadmins" �members "Domain Admins"
                    ADD-ADGroupMember "sec_files_Accounting-ro" �members "Domain Users"
                    ADD-ADGroupMember "sec_files_HR-ro" �members "Domain Users"
                    ADD-ADGroupMember "sec_files_ExecutiveOffice-ro" �members "Domain Users"
                    ADD-ADGroupMember "sec_files_IT-ro" �members "Domain Users"
                    ADD-ADGroupMember "sec_files_Security-ro" �members "Domain Users"
                }
                catch
                {
                    Write-Host "error attempting to add users to fileshare groups"
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