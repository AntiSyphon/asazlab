
configuration Addspns {
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
        xScript GenerateSPNS
        {
            SetScript = 
            {
                Write-Host "add SPNs DSC started "

                              
                Write-Host "add user accounts for spns "

                try {
                    cd c:\ASAZ
                    New-ADUser -UserPrincipalName 'Braylen.Ewing@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Braylen' -Surname 'Ewing' -Enabled 1 -Name 'Braylen.Ewing' -AccountPassword (ConvertTo-SecureString 'qwertyuiopDE#'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Emelia.Chaney@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Emelia' -Surname 'Chaney' -Enabled 1 -Name 'Emelia.Chaney' -AccountPassword (ConvertTo-SecureString 'Spring2005!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Shaylee.Griffith@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Shaylee' -Surname 'Griffith' -Enabled 1 -Name 'Shaylee.Griffith' -AccountPassword (ConvertTo-SecureString 'MaryJane13!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Rodney.Mullen@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Rodney' -Surname 'Mullen' -Enabled 1 -Name 'Rodney.Mullen' -AccountPassword (ConvertTo-SecureString 'GreatP@assword#'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Jaslyn.Casey@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Jaslyn' -Surname 'Casey' -Enabled 1 -Name 'Jaslyn.Casey' -AccountPassword (ConvertTo-SecureString 'LetMeInAlready!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Arely.Wu@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Arely' -Surname 'Wu' -Enabled 1 -Name 'Arely.Wu' -AccountPassword (ConvertTo-SecureString 'NoBodyKnowsItYet!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Niko.Byrd@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Niko' -Surname 'Byrd' -Enabled 1 -Name 'Niko.Byrd' -AccountPassword (ConvertTo-SecureString 'LostPassword2@'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Mitchell.Fernandez@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Mitchell' -Surname 'Fernandez' -Enabled 1 -Name 'Mitchell.Fernandez' -AccountPassword (ConvertTo-SecureString 'CorrectHorseBattery4'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Case.Wagner@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Case' -Surname 'Wagner' -Enabled 1 -Name 'Case.Wagner' -AccountPassword (ConvertTo-SecureString 'NegativeTractionUpHill3'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Kamari.Frazier@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Kamari' -Surname 'Frazier' -Enabled 1 -Name 'Kamari.Frazier' -AccountPassword (ConvertTo-SecureString 'Winter2022!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Kyson.Curry@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Kyson' -Surname 'Curry' -Enabled 1 -Name 'Kyson.Curry' -AccountPassword (ConvertTo-SecureString 'Summer2020!'  -AsPlainText -Force) 
                    New-ADUser -UserPrincipalName 'Lilianna.Figueroa@asazlab.com' -Path 'OU=DomainUsers,dc=asazlab,DC=com' -GivenName 'Lilianna' -Surname 'Figueroa' -Enabled 1 -Name 'Lilianna.Figueroa' -AccountPassword (ConvertTo-SecureString 'LetsG000!'  -AsPlainText -Force)
                }
                catch
                {
                    Write-Host "error creating New ADUsers for SPNS"
                }

                Write-Host "add SPNs complete "

                try
                {
                    setspn -a ws05/luis.graves.asazlab.com:1433 asazlab.com\luis.graves
                    setspn -a ws05/Braylen.Ewing.asazlab.com:1433 asazlab.com\Braylen.Ewing
                    setspn -a ws05/Emelia.Chaney.asazlab.com:1433 asazlab.com\Emelia.Chaney
                    setspn -a ws05/Shaylee.Griffith.asazlab.com:4000 asazlab.com\Shaylee.Griffith
                    setspn -a ws05/Rodney.Mullen.asazlab.com:674 asazlab.com\Rodney.Mullen
                    setspn -a ws05/Jaslyn.Casey.asazlab.com:333 asazlab.com\Jaslyn.Casey
                    setspn -a ws05/Arely.Wu.asazlab.com:4000 asazlab.com\Arely.Wu
                    setspn -a ws05/Niko.Byrd.asazlab.com:4000 asazlab.com\Niko.Byrd
                    setspn -a ws05/Mitchell.Fernandez.asazlab.com:2022 asazlab.com\Mitchell.Fernandez
                    setspn -a ws05/Case.Wagner.asazlab.com asazlab.com\Case.Wagner
                    setspn -a ws05/Kamari.Frazier.asazlab.com asazlab.com\Kamari.Frazier
                    setspn -a ws05/Kyson.Curry.asazlab.com:2352 asazlab.com\Kyson.Curry
                    setspn -a ws05/Lilianna.Figueroa.asazlab.com:1433 asazlab.com\Lilianna.Figueroa
                }
                catch
                {
                Write-Host "error creating New SPNs "
                }

                 Write-Host "add SPNs DSC complete "

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