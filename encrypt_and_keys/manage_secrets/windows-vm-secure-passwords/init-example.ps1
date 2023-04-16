#ps1
# ^^^ 'ps1' is only for cloudbase-init, some sort of sha-bang in linux

# logging
Start-Transcript -Path "$ENV:SystemDrive\provision2.txt" -IncludeInvocationHeader -Force
"Bootstrap script started" | Write-Host

# You have to create Lockbox secret 
# and assign service account with roles lockbox.payloadViewer and kms.key.encryptorDecryptor to VM

# HERE'S ENTER YOUR SECRET'S ID OF IMPORT FROM TERRAFORM VARIABLE:
$SecretID = "e6qseoj5kfu132vb6cgf"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$SecretURL = "https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/$SecretID/payload"

"Secret ID is $SecretID"
"Payload URL is $SecretURL"

$YCToken = (Invoke-RestMethod -Headers @{'Metadata-Flavor'='Google'} -Uri "http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token").access_token
if (!$YCToken) {
    throw "Service Account doesn't connected to VM. Please, add Service account with roles lockbox.payloadViewer and kms.key.encryptorDecryptor to VM and try again."
}

# Creating parameters for REST-invokations
$Headers = @{
    Authorization="Bearer $YCToken"
}

$Params = @{
    Uri = $SecretURL
    Method = "GET"
    Headers = $Headers
}

# Getting secret via REST invoke
$Secret = Invoke-RestMethod @Params
$SecretAdministratorPlainTextPassword = $Secret.entries[0].textValue

# inserting value's from terraform
if (-not [string]::IsNullOrEmpty($SecretAdministratorPlainTextPassword)) {
    "Set local administrator password" | Write-Host
    $SecretAdministratorPassword = $SecretAdministratorPlainTextPassword | ConvertTo-SecureString -AsPlainText -Force
    # S-1-5-21domain-500 is a well-known SID for Administrator
    # https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/security-identifiers-in-windows
    $Administrator = Get-LocalUser | Where-Object -Property "SID" -like "S-1-5-21-*-500"
    $Administrator | Set-LocalUser -Password $SecretAdministratorPassword
}

# Creating new users if any
if($Secret.entries.count -gt 1) {
    foreach($User in $Secret.entries[1..($Secret.entries.count-1)]){
        $SecretUserPassword = $User.textValue | ConvertTo-SecureString -AsPlainText -Force
        New-LocalUser -Name $User.key -Password $SecretUserPassword -FullName $User.key
        Add-LocalGroupMember -Group Users -Member $User.key
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $User.key
    }
}

"Bootstrap script ended" | Write-Host