<#
.Synopsis
   Grabs the Data and Log files.  If $creds exsits, this module will validate and prompt if necessary.  All modules for managing
   this application use $creds variable for storage of elevated privileges.
.DESCRIPTION
   Takes a computer name and pulls the Caradigm install folder and it's logs for analysis
.EXAMPLE
   Get-SsoLogs -comp <computer name>
.EXAMPLE
   Get-SsoLogs -comp <computer name> -outputdir <output directory>
.AUTHOR
    Darren Shady 
#>
function Get-SsoLogs
{
    Requires -Version 4.0
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help Specifies the Computer Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$comp,

        # Param2 help Specifies the Output Directory
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$outputdir = ".\"
    )

    Begin
    {


        if($creds -eq $null)
        {
            $creds = Get-Credential
        }
        #validate credentials
        $username = $creds.username
        $password = $creds.GetNetworkCredential().password

        # Get current domain using logged-on user's credentials
        $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
        $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

        if ($domain.name -eq $null)
        {
            write-host "Supplied credentials are incorrect."
            $creds = Get-Credential
        }
        
        #Map a drive
        $comp_drive = New-PSDrive -Name Y -PSProvider filesystem -Root \\$comp\C$ -Credential $creds
    }
    Process
    {
        $loglocation = "\programdata\Sentillion\Vergence\"
        $logpath = "$comp_drive`:$loglocation"
        $time = Get-Date -Format M-d-yyyy_HHmm
        if(Test-Path $outputdir\$comp)
        {
            Rename-Item $outputdir\$comp $comp"."$time -Force
        }
        else
        {
            Copy-Item -Path $logpath -Recurse -Destination $outputdir\$comp"."$time -Force
        }
    }
    End
    {
        Get-PSDrive Y | Remove-PSDrive
    }
}