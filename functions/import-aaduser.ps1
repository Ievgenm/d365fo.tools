##############################
#.SYNOPSIS
# Used to import Aad users into D365FO
#
#.DESCRIPTION
# Provides a method for importing a AAD UserGroup or a comma seperated list of AadUsers into D365FO.
#
#.PARAMETER AadGroupName
# Azure Active directory usergroup containing users to be importet
#
#.PARAMETER UserList
# A comma seperated list of Aad users to be importet into D365FO
#
#.PARAMETER StartupCompany
# Startup company of users importet, Default USMF
#
#.PARAMETER DatabaseServer
# Alternative SQL Database server, Default is the one provided by the DataAccess object
#
#.PARAMETER DatabaseName
# Alternative SQL Database, Default is the one provieded by the DataAccess object
#
#.PARAMETER SqlUser
# Alternative SQL user, Default is the one provieded by the DataAccess object
#
#.PARAMETER SqlPwd
# Alternative SQL user password, Default is the one provieded by the DataAccess object
#
#.EXAMPLE
# Import 2 users into D365FO
# Import-AadUser -Userlist "user1@myCompany.com,user2@mycompany.com"
# Import-AadUser -AadGroupName "CustomerTeam1"
#.NOTES
# The import is done using TSQL for copying the Admin Account,
# The RecId is from SystemSequences
##############################
function Import-AadUser {
    param (
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "GroupImport")]
        [String]$AadGroupName,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "UserListImport")]
        [string]$UserList,
        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "UserListImport")]
        [string]$StartupCompany = 'USMF',
        [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "UserListImport")]
        [string]$DatabaseServer = $Script:DatabaseServer,
        [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "UserListImport")]
        [string]$DatabaseName = $Script:DatabaseName,
        [Parameter(Mandatory = $false, Position = 5, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 5, ParameterSetName = "UserListImport")]
        [string]$SqlUser = $Script:DatabaseUserName,
        [Parameter(Mandatory = $false, Position = 6, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 6, ParameterSetName = "UserListImport")]
        [string]$SqlPwd = $Script:DatabaseUserPassword,
        [Parameter(Mandatory = $false, Position = 7, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 7, ParameterSetName = "UserListImport")]
        [string]$IdPrefix = "",
        [Parameter(Mandatory = $false, Position = 8, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 8, ParameterSetName = "UserListImport")]
        [string]$NameSuffix = "",
        [Parameter(Mandatory = $false, Position = 9, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 9, ParameterSetName = "UserListImport")]
        [ValidateSet('Login', 'FirstName')]
        [string]$IdValue = "Login",
        [Parameter(Mandatory = $false, Position = 9, ParameterSetName = "GroupImport")]
        [Parameter(Mandatory = $false, Position = 9, ParameterSetName = "UserListImport")]
        [ValidateSet('FirstName', 'DisplayName')]
        [string]$NameValue = "DisplayName"
    
    )
    

    
    $instanceProvider = Get-InstanceIdentityProvider
    $canonicalProvider = Get-CanonicalIdentityProvider 
    Write-Verbose "CanonicalIdentityProvider $Provider"

    $msonline = Get-Module -ListAvailable -Name msonline
    if ($msonline -eq $null) { throw  "Import-AadUser with GroupImport requires MSOnline Please install-Module MSonline" }

    import-Module MSOnline -Force -ErrorAction Stop
    Connect-MsolService -ErrorAction Stop
    [System.Collections.ArrayList]$msolUsers = New-Object -TypeName "System.Collections.ArrayList"

    if ( $PSCmdlet.ParameterSetName -eq "GroupImport") {

        $group = Get-MsolGroup -SearchString $AadGroupName

        if ($group -eq $null) { Write-Error "Group not found $group" -ErrorAction Stop }
        
        $users = Get-MsolGroupMember -GroupObjectId $group[0].ObjectId

        foreach ($user in $users) {
            if ($user.GroupMemberType -eq "User") {
                $null = $msolUsers.Add((Get-MsolUser -ObjectId $user.ObjectId))
            }
        }
    }
    else {
        $usersFromList = $UserList.Split(";")

        foreach ($str in $usersFromList) {
            $null = $msolUsers.Add((Get-MsolUser -SearchString $str))
        }
    }
    try {

        $sqlCommand = Get-SqlCommand $DatabaseServer $DatabaseName $SqlUser $SqlPwd
        $sqlCommand.Connection.Open()
    }
    catch {
    
        Write-Error $_ -ErrorAction Stop
    }

    
    foreach ($user in $msolUsers) {            

        $identityProvider = $canonicalProvider 
        $tenant = Get-TenantFromEmail $user.SignInName 
        $networkDomain = get-NetworkDomain $user.SignInName

        if ($instanceProvider.ToLower().Contains($tenant.ToLower()) -ne $True) {
            $identityProvider = Get-IdentityProvider $user.SignInName
        }

        $sid = Get-UserSIDFromAad $user.SignInName $identityProvider
        Write-Verbose "Importing $($user.SignInName) - SID $sid - Provider $identityProvider"
    
        $id = ""
        if ($IdValue -eq 'Login') { 
            $id = $IdPrefix + $(Get-LoginFromEmail $user.SignInName) 
        }
        else {
            $id = $IdPrefix + $user.FirstName
        }

        $name = ""
        if ($NameValue -eq 'DisplayName') { 
            $name = $user.DisplayName + $NameSuffix
        }
        else {
            $name = $user.FirstName + $NameSuffix
        }
        Import-AadUserIntoD365FO $SqlCommand $user.SignInName $name $id $sid $StartupCompany $identityProvider $networkDomain $user.ObjectId
    }

    $sqlCommand.Dispose()
    
    

}
