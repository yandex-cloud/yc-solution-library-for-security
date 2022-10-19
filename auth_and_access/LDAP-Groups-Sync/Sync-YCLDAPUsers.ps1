<#
.NOTES
    Copyright (c) LLC Yandex Cloud.  All rights reserved.

    THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.SYNOPSIS
    Creates and synchronize LDAP Groups and its users with Yandex Cloud Groups and Federated users.
    LDAP administrator can control YC Group membeship through LDAP group.
    If user been excluded from LDAP group, his federated account in YC will be excluded from YC Group during next sync.
    To successfully run source code user have to be organization.admin in Yandex Cloud and have user priveleges in LDAP Domain.

.DESCRIPTION
    1. The sample script creates YC Group if its does not exist.
    2. After that checks users and creates them if accounts don't exist in specified federation
    3. After groups and users been created - validates group membership based on LDAP group membersip.
    4. Excludes or includes users based on LDAP group membersip.

.PARAMETER GroupNames
    Mandatory.
    Array @() of LDAP group names. Group name must contains only latin characters and special character "-".
    All other characters such as white space, dot, underscore, etc are unsupported by YC Naming Convertion.

.PARAMETER YCToken
    Mandatory.
    An IAM token is a unique sequence of characters issued to a user after authentication.
    The user needs this token for authorization in the Yandex Cloud API and access to resources.
    for example using yc cli:
    yc iam create-token

.PARAMETER YCOrgID
    Mandatory.
    Yandex Cloud Organization ID.

.PARAMETER FederationName
    Mandatory.
    Specifies Yandex Cloud Federation's name. 

.PARAMETER MailAsLogin
    Setting user's attribute mail as login in Yandex Cloud federation. Incompatible with parameter UPNAsLogin.

.PARAMETER UPNAsLogin
    Setting user's attribute userprincipalname as login in Yandex Cloud federation. Incompatible with parameter MailAsLogin.

.PARAMETER LogDirectory
    Specifies the directory where the log file should be generated.
    The default value is the current directory ($pwd).

.EXAMPLE  
    # Getting IAM token
    $env:YC_TOKEN = $(yc iam create-token)

    # Setting up organization ID
    $env:YCOrgID = "bpf..."

    # Synchronizing groups and users
    .\Sync-YCLDAPUsers.ps1 -GroupNames @("group1","Group2") -YC_TOKEN $env:YC_TOKEN -YCOrgID $env:YCOrgID FederationName = "dev-federation" -LoginType UPN

    This command will create and sync groups group1 and Group2 
    in specifien organization and federation and using UPN as login.

.EXAMPLE
    $Params = @{
        GroupNames = @("group-allow","group-deny")
        YC_TOKEN = $env:YC_TOKEN
        YCOrgID = $env:YCOrgID
        FederationName = "dev-federation"
        LoginType = "Mail"
    }  
    
    .\Sync-YCLDAPUsers.ps1 @Params

    This command will create and sync groups group1 and Group2 
    in specifien organization and federation and using UPN as login.

.OUTPUTS
    System.IO.FileInfo
#>

param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $GroupNames = @(),
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $YCToken = $env:YC_TOKEN,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $YCOrgID = "bpfncbpfnadtqjhoacqi",
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $FederationName,
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Mail", "UPN")]
    $LoginType = "UPN",
    $LogDirectory = "C:\work"
)

#region helpers
# API Endpoints
$APIEndpoints =@{
    IAMGroups = "https://organization-manager.api.cloud.yandex.net/organization-manager/v1/groups"
    IAMFederations = "https://organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/federations"
    IAMOrganizations = "https://organization-manager.api.cloud.yandex.net/organization-manager/v1/organizations"
}

function WriteLog
{
    param([string]$message, 
        [string]$filename, 
        [switch]$NoDate,
        [switch]$skipWriteToFile, 
        [ValidateSet("Info","Warning","Error")]
        [string]$EventType
    )
                    
    if (!$NoDate)
    {
        $logString = "{0}: {1}: {2}" -f (Get-Date).ToString("dd.MM.yyyy hh:mm:ss"), $EventType.ToUpper(), $message
    }
    else
    {
        $logString = $message
    }
            
    switch ($EventType) 
    {
        "Warning" { Write-Warning $logString }
        "Error" { Write-Host $logString -ForegroundColor Red }
        "Info" { Write-Host $logString }
        Default { Write-Host $logString }
    }

    if (!$skipWriteToFile)
    {
        $mtx = New-Object System.Threading.Mutex($false, "WriteLogMutex")
        [void]$mtx.WaitOne()
        $logString | Out-File -FilePath $("$($LogDirectory)\\{1}_{0}.log" -f (Get-Date).ToString("dd.MM.yyyy"), $filename) -Append
        [void]$mtx.ReleaseMutex()
    }
}

function Get-YCService {
    param (
        $token,
        $service_uri,
        $id,
        $method,
        $body
    )
    $Headers = @{
        Authorization="Bearer $token"
    }

    if($body) {
        $Params = @{
            Uri = $service_uri
            Method = $method
            Headers = $Headers
            Body = $body
        }
    }
    else {
        $Params = @{
            Uri = $service_uri
            Method = $method
            Headers = $Headers
        }
    }

    $Result = Invoke-RestMethod @Params
    return $Result
}

#endregion

function Get-LDAPUsersInGroup {
    [CmdletBinding()]
  param (
    $GroupName
  )

  $Filter = "(&(objectClass=group)(cn=$GroupName))"
  $Searcher = New-Object DirectoryServices.DirectorySearcher
  $Searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($rootDSE.defaultNamingContext)")
  $Searcher.Filter = $Filter
  $Searcher.SearchScope = "Subtree" # Either: "Base", "OneLevel" or "Subtree"
  $Group = $Searcher.FindAll()
  
  #$GroupDN = $Group.Properties.distinguishedname

  $Filter="(&(objectClass=user)(memberof:1.2.840.113556.1.4.1941:=$($Group.Properties.distinguishedname)))"
  $Searcher = New-Object DirectoryServices.DirectorySearcher
  $Searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($rootDSE.defaultNamingContext)")
  $Searcher.Filter = $Filter
  $Searcher.SearchScope = "Subtree" # Either: "Base", "OneLevel" or "Subtree"
  $Searcher.PropertiesToLoad.Add("userPrincipalName") > $Null
  $Searcher.PropertiesToLoad.Add("sAMAccountName") > $Null
  $Searcher.PropertiesToLoad.Add("displayName") > $Null
  $Searcher.PropertiesToLoad.Add("sn") > $Null
  $Searcher.PropertiesToLoad.Add("givenName") > $Null
  $Searcher.PropertiesToLoad.Add("mail") > $Null
  $Searcher.PropertiesToLoad.Add("telephoneNumber") > $Null
  $Searcher.PropertiesToLoad.Add("thumbnailPhoto") > $Null

  $UserList = $Searcher.FindAll()
  return $UserList
}


#region Groups operations
function Get-YCIAMGroup {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $Name,
        $Id
    )
    
    $Result = (Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)?organizationId=$YCOrgID" -method "GET").groups
    
    if($Name) {
        $Result = $Result | Where-Object {$_.name -eq $Name}
    }

    if($Id) {
        $Result = $Result | Where-Object {$_.id -eq $Id}
    }

    return $Result
}

function Create-YcIAMGroup {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $Name,
        $Description
    )

    if($Description) {
        $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)?organizationId=$YCOrgID&name=$Name&description=$Description" -method "POST"
    }
    else {
        $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)?organizationId=$YCOrgID&name=$Name" -method "POST"
    }

    return $Result
}

function Delete-YcIAMGroup {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $Name,
        $Id
    )

    if($Name -and !$Id) {
        $Id = (Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $Name).id
    }

    $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)/$Id" -method "DELETE"

    return $Result
}

function Get-YcIAMGroupMember {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $GroupName,
        $GroupId,
        $FederationID,
        $FederationName,
        # GetYcIAMUser
        $UserName
    )
    
    if($GroupName -and !$GroupId) {
        $GroupId = (Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName).id
    }

    $Ids = @()
    if($FederationName -and !$FederationID) {
        $Ids = (Get-YcOrgFederation -YCToken $YCToken -YCOrgID $YCOrgID -Name $FederationName).id
    }
    else {
        $Ids = $FederationID
    }

    $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)/$GroupId`:listMembers" -method "GET"

    if($UserName) {
        $ID = (Get-YcOrgFederatedUser -YCToken $YCToken -YCOrgID $YCOrgID -FederationID $Ids -NameID $UserName).id
        if($Result.members -match $ID) {
            $Result = $Result.members -match $ID
        }
        else {
            $Result = $null
        }
    }

    if($Result) {
        return $Result
    }
}

#endregion

#region Federations
function Get-YcOrgFederation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $Name,
        $Id
    )

    $Result = (Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMFederations)?organizationId=$YCOrgID" -method "GET").federations
    
    if($Name) {
        $Result = $Result | Where-Object {$_.name -eq $Name}
    }

    if($Id) {
        $Result = $Result | Where-Object {$_.id -eq $Id}
    }

    return $Result
}

function Get-YcOrgFederatedUser {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $FederationID,
        $FederationName,
        $NameID
    )
    # organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/federations/{federationId}:listUserAccounts
    $Ids = @()
    if($FederationName -and !$FederationID) {
        $Ids = (Get-YcOrgFederation -YCToken $YCToken -YCOrgID $YCOrgID -Name $FederationName).id
    }
    else {
        $Ids = $FederationID
    }

    if(!$FederationName -and !$FederationID) {
        $Ids = (Get-YcOrgFederation -YCToken $YCToken -YCOrgID $YCOrgID).id
    }

    $Result = @()
    foreach($ID in $Ids) {
        $Result += (Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMFederations)/$ID`:listUserAccounts" -method "GET").userAccounts
    }

    if($NameID) {
        $tmp = @()
        foreach($UserId in $Result) {
            if($UserID.samlUserAccount -match $NameID) {
                $tmp += $UserID
            }
        }
        $Result = $tmp
    }
    return $Result
}

function Add-YcOrgFederatedUser {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $FederationID,
        $FederationName,
        $NameIDs
    )
    # organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/federations/{federationId}:listUserAccounts
    if($FederationName -and !$FederationID) {
        $FederationID = (Get-YcOrgFederation -YCToken $YCToken -YCOrgID $YCOrgID -Name $FederationName).id
    }

    if(!$FederationName -and !$FederationID) {
        throw "Federation Name or Federation ID must be specified."
    }

    $Result = Get-YCService -token $YCToken -service_uri "https://organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/federations/$FederationID`:addUserAccounts?nameIds=$NameIDs" -method "POST"

    return $Result
}

function Delete-YcOrgFederatedUser {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        $Id,
        $Name,
        $FederationID,
        $FederationName
    )
    # organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/federations/{federationId}:listUserAccounts
    if($FederationName -and !$FederationID) {
        $FederationID = (Get-YcOrgFederation -YCToken $YCToken -YCOrgID $YCOrgID -Name $FederationName).id
    }

    if(!$FederationName -and !$FederationID) {
        throw "Federation Name or Federation ID must be specified."
    }

    $OrgID = (Get-YcOrgFederation -Id $FederationID).organizationId

    if($Name -and !$Id){
        $Id = (Get-YcOrgFederatedUser -Name $Name -FederationID $FederationID).id
    }

    $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMOrganizations)/$OrgID/users/$Id" -method "DELETE"

    return $Result
}

function Add-YCOrgFederatedUsersToGroup {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        [ValidateNotNullOrEmpty()]
        $GroupName,
        $GroupID,
        [Object[]]$FederatedUsers,
        [Object[]]$FederatedUserIDs,
        $FederationName
    )
    
    if($GroupName -and !$GroupId) {
        $GroupId = (Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName).id
    }

    $UsersToAdd = @()
    if($FederatedUsers -and !$FederatedUserIDs){
        foreach($FederatedUserName in $FederatedUsers) {
            $FederatedUserID = (Get-YcOrgFederatedUser -NameID $FederatedUserName -FederationName $FederationName).id

            $Object = "" | select @{n="action";e={"ADD"}},@{n="subjectId";e={"$FederatedUserID"}}
            $UsersToAdd += $Object
        }
    }
    else {
        foreach($FederatedUserID in $FederatedUserIDs) {
            $Object = "" | select @{n="action";e={"ADD"}},@{n="subjectId";e={"$FederatedUserID"}}
            $UsersToAdd += $Object
        }
    }
    
    $Deltas = [PSCustomObject]@{
        memberDeltas = $UsersToAdd
    } | ConvertTo-Json

    $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)/$GroupID`:updateMembers" -method "POST" -Body $Deltas

    $Result
}

function Remove-YCOrgFederatedUsersFromGroup {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $YCToken = $env:YC_TOKEN,
        [ValidateNotNullOrEmpty()]
        $YCOrgID = $env:YC_ORG,
        [ValidateNotNullOrEmpty()]
        $GroupName,
        $GroupID,
        [Object[]]$FederatedUsers,
        [Object[]]$FederatedUserIDs,
        $FederationName
    )
    
    if($GroupName -and !$GroupId) {
        $GroupId = (Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName).id
    }

    $UsersToRemove = @()
    if($FederatedUsers -and !$FederatedUserIDs){
        foreach($FederatedUserName in $FederatedUsers) {
            $FederatedUserID = (Get-YcOrgFederatedUser -NameID $FederatedUserName -FederationName $FederationName).id

            $Object = "" | select @{n="action";e={"REMOVE"}},@{n="subjectId";e={"$FederatedUserID"}}
            $UsersToRemove += $Object
        }
    }
    else {
        foreach($FederatedUserID in $FederatedUserIDs) {
            $Object = "" | select @{n="action";e={"ADD"}},@{n="subjectId";e={"$FederatedUserID"}}
            $UsersToRemove += $Object
        }
    }
                                           
    $Deltas = [PSCustomObject]@{
        memberDeltas = $UsersToRemove
    } | ConvertTo-Json

    $Result = Get-YCService -token $YCToken -service_uri "$($APIEndpoints.IAMGroups)/$GroupID`:updateMembers" -method "POST" -Body $Deltas

    $Result
}

#endregion

#region Main
$filename = (Get-Date -f MMddyyyy_hh_mm).Tostring()+"_YCGroupSyncLog.log"
$errorlog = (Get-Date -f MMddyyyy_hh_mm).Tostring()+"_YCGroupSyncErrorLog.log"

if(!$LogDirectory) {
    $LogDirectory = (Get-Location).Path
}

WriteLog -message "Getting RootDSE" -EventType Info -filename $filename
try {
  $rootDSE = [adsi]"LDAP://rootDSE"
}
catch {
    {
      1: throw "Could not find RootDSE or [adsi] does not exist."
      WriteLog -message "Could not find RootDSE or [adsi] does not exist." -EventType Error -filename $filename
      WriteLog -message "Could not find RootDSE or [adsi] does not exist." -EventType Error -filename $errorlog
    }
}

foreach ($GroupName in $GroupNames){
    WriteLog -message "Processing group $GroupName" -EventType Info -filename $filename
    if($rootDSE) {
        WriteLog -message "Getting LDAP users in group $GroupName" -EventType Info -filename $filename
        $LDAPUsers = Get-LDAPUsersInGroup -GroupName $GroupName

        WriteLog -message "Getting YC Group $GroupName in Cloud Organization $YCOrgID" -EventType Info -filename $filename
        $YCGroup = Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName.ToLower()
        
        if(!$YCGroup) {
            WriteLog -message "YC Group $GroupName not found in Cloud Organization $YCOrgID" -EventType Info -filename $filename
            WriteLog -message "Creating YC Group $GroupName not found in Cloud Organization $YCOrgID" -EventType Info -filename $filename
            try {
                $outNull = Create-YcIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName.ToLower() -ErrorAction stop
                $YCGroup = Get-YCIAMGroup -YCToken $YCToken -YCOrgID $YCOrgID -Name $GroupName.ToLower()
            }
            catch {
                WriteLog -message "Could not create group $GroupName in Cloud Organization $YCOrgID. Please check YC Groups naming convention and try again." -EventType Error -filename $filename
                WriteLog -message "Could not create group $GroupName in Cloud Organization $YCOrgID. Please check YC Groups naming convention and try again." -EventType Error -filename $errorlog
                throw "Could not create group $GroupName in Cloud Organization $YCOrgID. Please check YC Groups naming convention and try again."
            }
        }
        else {
            WriteLog -message "Found YC Group group $($GroupName.ToLower())" -EventType Info -filename $filename
        }

        $UsersToAdd = @()
        foreach($LDAPUser in $LDAPUsers) {
            WriteLog -message "Processing user $($LDAPUser.Properties.userprincipalname)" -EventType Info -filename $filename

            if($LDAPUser.Properties.userprincipalname -ne $null -or $LDAPUser.Properties.mail -ne $null) {
                if($LoginType -eq "Mail") {
                    if($LDAPUser.Properties.mail) {
                        $username = $LDAPUser.Properties.mail.ToLower()
                        WriteLog -message "Mail as login is selected. Login is: $username" -EventType Info -filename $filename
                    }
                    else {
                        $DomainName = $rootDSE.ldapServiceName.ToString()
                        $username = "$($LDAPUser.Properties.samaccountname)@$($DomainName.Substring(0, $DomainName.IndexOf(':')))"
                        WriteLog -message "Mail as login is selected, but attribute Mail is empty. Using UPN for user: $username" -EventType Info -filename $filename
                    }
                }

                if($LoginType -eq "UPN") {
                    if($LDAPUser.Properties.userprincipalname) {
                        $username = $LDAPUser.Properties.userprincipalname.ToLower()
                        WriteLog -message "UPN as login is selected. Login is: $username" -EventType Info -filename $filename
                    }
                    else {
                        $DomainName = $rootDSE.ldapServiceName.ToString()
                        $username = "$($LDAPUser.Properties.samaccountname)@$($DomainName.Substring(0, $DomainName.IndexOf(':')))"
                        WriteLog -message "UPN as login is selected, but attribute UserPrincipalName is empty. Login is: $username" -EventType Info -filename $filename
                    }
                    
                }

                WriteLog -message "Searching $username in federation $FederationName" -EventType Info -filename $filename
                $FederatedUser = Get-YcOrgFederatedUser -YCToken $YCToken -YCOrgID $YCOrgID -FederationName $FederationName -NameID $username

                if(!$FederatedUser) {
                    WriteLog -message "User $username not found in federation $FederationName. Creating..." -EventType Info -filename $filename
                    $outNull = Add-YcOrgFederatedUser -YCToken $YCToken -YCOrgID $YCOrgID -FederationName $FederationName -NameIDs @("$username")
                }
                
                WriteLog -message "Checking $username for membership in group $GroupName" -EventType Info -filename $filename
                $YCGroupMembership = Get-YcIAMGroupMember -YCToken $YCToken -YCOrgID $YCOrgID -GroupName $GroupName.ToLower() -UserName $username -FederationName $FederationName
                
                if(!$YCGroupMembership) {
                    WriteLog -message "User $username added for membership in group $GroupName" -EventType Info -filename $filename
                    $UsersToAdd += $username
                }
            }
        }
        
        if($UsersToAdd) {
            $outNull = Add-YCOrgFederatedUsersToGroup -YCToken $YCToken -YCOrgID $YCOrgID -GroupID $YCGroup.id -FederatedUsers $UsersToAdd -FederationName $FederationName
            WriteLog -message "Users $UsersToAdd has been added to group $($GroupName.ToLower())" -EventType Info -filename $filename
        }

        WriteLog -message "Validating group membership in group $($GroupName.ToLower())" -EventType Info -filename $filename
        $YCGroupMembers = Get-YcIAMGroupMember -YCToken $YCToken -YCOrgID $YCOrgID -GroupName $GroupName.ToLower()
        foreach($YCGroupMember in $YCGroupMembers.members) {
            $NameID = (Get-YcOrgFederatedUser -YCToken $YCToken -YCOrgID $YCOrgID -FederationName $FederationName | where {$_.id -eq $YCGroupMember.subjectId}).samlUserAccount.nameId
            if($NameID -and !($LDAPUsers.Properties.userprincipalname -match $NameID)) {
                WriteLog -message "User $NameID been excluded from LDAP group $GroupName excluding from YC Group $($GroupName.ToLower())" -EventType Info -filename $filename
                $outNull = Remove-YCOrgFederatedUsersFromGroup -YCToken $YCToken -YCOrgID $YCOrgID -GroupName $GroupName.ToLower() -FederatedUsers @("$NameID") -FederationName $FederationName
                WriteLog -message "User $NameID has been removed from group $($GroupName.ToLower())" -EventType Info -filename $filename
            }
        }
    }
}
#endregion