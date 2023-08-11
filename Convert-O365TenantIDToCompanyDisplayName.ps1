# TRY TO CONVERT TENANT ID TO COMPANY NAME
$tenantId = Read-Host

$webResponse = Invoke-WebRequest -Uri "https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration"
$webResponseHash = $webResponse.Content | ConvertFrom-Json -AsHashtable

# Convert second web lookup to correct tld
# TODO: Support China TLD
if ( $webResponseHash.tenant_region_scope -eq "USGov" ) { $tld = "us" } else { $tld = "com" }

# Pull company display name attribute from sign in page
$webResponse2 = Invoke-WebRequest -Uri "https://login.microsoftonline.$tld/$tenantId/oauth2/v2.0/authorize?client_id=foo&response_type=code&scope=read"

# I put on my robe and wizard hat
$regexPattern = '"sCompanyDisplayName":\"(.+?)\"'
$matches = [Regex]::Matches($webResponse2, $regexPattern)

# Remove crap
$companyDisplayName = $matches.Value.Replace('"sCompanyDisplayName":"',"")
$companyDisplayName = $companyDisplayName.Replace('"',"")

# ???

# Profit!
$companyDisplayName
