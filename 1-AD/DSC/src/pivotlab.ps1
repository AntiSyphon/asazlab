
configuration pivotlab1 {
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
        xScript pivotlab1
        {
            SetScript = 
            {
                 Write-Host "starting pivotlab setup"

                 try
                 {
                     Import-Module ActiveDirectory

                     New-ADOrganizationalUnit -Name "Helpdesk" -Path "DC=asazlab,DC=com"
                     New-ADOrganizationalUnit -Name "SecurityGroups" -Path "OU=Helpdesk,DC=asazlab,DC=com"

                     DSADD user -upn charlieadmin@asazlab.com "cn=charlieadmin,ou=AdminAccounts,dc=asazlab,dc=com" -fn "Charlie" -ln "admin" -disabled no -display "ITAdmin" -desc "Charlie Admin" -office "Administration" -title "Controller" -company "DevLabs" -PWD "ImpossiblePasswordYouWontGetThis3033@@!"
                     Add-ADGroupMember -Identity "Domain Admins" -Members charlieadmin
                     DSADD user -upn helpdeskuser@asazlab.com "cn=helpdeskuser,ou=Helpdesk,dc=asazlab,dc=com" -fn "Chris" -ln "HelpDeskUser" -disabled no -display "HelpdeskUser" -desc "Helpdesk User" -office "Administration" -title "Controller" -company "DevLabs" -PWD "H3lpD3skPass!"
                     DSADD user -upn Dataanalyst@asazlab.com "cn=Dataanalyst,ou=Helpdesk,dc=asazlab,dc=com" -fn "Samantha" -ln "Dataanalyst" -disabled no -display "DataAnalyst" -desc "Helpdesk Analyst" -office "Administration" -title "Data Analyst" -company "DevLabs" -PWD "@nalystsPa55!Tough"
                     DSADD user -upn Dataanalystjr@asazlab.com "cn=Dataanalystjr,ou=Helpdesk,dc=asazlab,dc=com" -fn "Benny" -ln "DataanalystJr" -disabled no -display "DataAnalystJr" -desc "Helpdesk Analyst Jr" -office "Administration" -title "Data Analyst Jr" -company "DevLabs" -PWD "jrbuthasareallyG00dP@55ThisTime@!"

                     New-ADGroup "usr_helpdesk" -Path "OU=HelpDesk,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru –Verbose
                     New-ADGroup "usr_helpdesk_analysts" -Path "OU=HelpDesk,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru –Verbose
                     New-ADGroup "usr_helpdesk_analysts_jr" -Path "OU=HelpDesk,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru –Verbose

                     New-ADGroup "sec_PWDChangers" -Path "OU=SecurityGroups,OU=Helpdesk,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru –Verbose
                     New-ADGroup "sec_ouadmins" -Path "OU=SecurityGroups,OU=Helpdesk,DC=asazlab,DC=com" -GroupCategory Security -GroupScope DomainLocal -PassThru –Verbose

                     ADD-ADGroupMember "sec_PWDChangers" –members "usr_helpdesk"
                     ADD-ADGroupMember "sec_ouadmins" –members "usr_helpdesk_analysts"
                     ADD-ADGroupMember "usr_helpdesk_analysts" –members "usr_helpdesk_analysts_jr"

                     ADD-ADGroupMember "usr_helpdesk" –members "helpdeskuser"
                     ADD-ADGroupMember "usr_helpdesk_analysts" –members "Dataanalyst"
                     ADD-ADGroupMember "usr_helpdesk_analysts_jr" –members "Dataanalystjr"

                     setspn -a ws05/helpdeskuser.asazlab.com:1423 asazlab.com\helpdeskuser
                     setspn -a ws05/Dataanalyst.asazlab.com:2233 asazlab.com\Dataanalyst
                                 
                     New-PSDrive -Name asazlab -PSProvider ActiveDirectory -Root "//RootDSE/" -server dc01.asazlab.com
                     $acl = Get-ACL "asazlab:\dc=asazlab,dc=com"
                     $sid = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Server dc01.asazlab.com sec_PWDChangers).SID
                     $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $sid,"ExtendedRight","Allow",([GUID]("00299570-246d-11d0-a768-00aa006e0529")).guid,"Descendents",([GUID]("bf967aba-0de6-11d0-a285-00aa003049e2")).guid))
                     Set-ACL "asazlab:\dc=asazlab,dc=com" $acl
                                                   
                     Set-Location AD:\
                     $OrganizationalUnit = "OU=AdminAccounts,DC=asazlab,DC=com"
                     $GroupName = "sec_ouadmins" 
                     $Group = Get-ADGroup -Identity $GroupName
                     $GroupSID = [System.Security.Principal.SecurityIdentifier] $Group.SID
                     $ACL = Get-Acl -Path $OrganizationalUnit
                     $Identity = [System.Security.Principal.IdentityReference] $GroupSID
                     $ADRight = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
                     $Type = [System.Security.AccessControl.AccessControlType] "Allow"
                     $InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
                     $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type,  $InheritanceType)
                     $ACL.AddAccessRule($Rule)
                     Set-Acl -Path $OrganizationalUnit -AclObject $ACL
                 }
                 catch
                 {
                     Write-Host "pivotlab setup failed"
                 }
                 
                 Write-Host "pivotlab DSC end"

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