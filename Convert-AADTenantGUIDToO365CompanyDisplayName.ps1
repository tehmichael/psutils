
<#PSScriptInfo

.VERSION 1.0

.GUID b9c0f941-3d6c-4e1f-8484-fc5d9a11aeee

.AUTHOR MichaelBendel-Paulso

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/tehmichael/psutils

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 
.SYNOPSIS
 Convert Azure AD GUID to Office365 company display name

.DESCRIPTION 
 Attempts to find the company display name from the sign in page for a specific Azure AD GUID.

#> 
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateLength(36, 36)]
    [string]$tenantId
)

# TRY TO CONVERT TENANT ID TO COMPANY NAME

# Lookup tenant region scope
try {
    $webResponse = Invoke-WebRequest -Uri "https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration"
    $webResponseHash = $webResponse.Content | ConvertFrom-Json -AsHashtable
} catch {
    $_
    Exit 1
}

# Convert second web lookup to correct tld
# TODO: Support China TLD
if ( $webResponseHash.tenant_region_scope -eq "USGov" ) { $tld = "us" } else { $tld = "com" }

# Pull company sign in page that may contain a valid Company Display Name
$webResponse2 = Invoke-WebRequest -Uri "https://login.microsoftonline.$tld/$tenantId/oauth2/v2.0/authorize?client_id=foo&response_type=code&scope=read"

# I put on my robe and wizard hat
$regexPattern = '"sCompanyDisplayName":\"(.+?)\"'
$regexMatch = [Regex]::Matches($webResponse2, $regexPattern)

# Remove crap
$companyDisplayName = $regexMatch.Value.Replace('"sCompanyDisplayName":"',"")
$companyDisplayName = $companyDisplayName.Replace('"',"")

# ???
$companyDisplayNameObject = [PSCustomObject]@{
    "CompanyDisplayName" = $companyDisplayName
}

# Profit!
$companyDisplayNameObject
