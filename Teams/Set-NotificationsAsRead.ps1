# Clear all Microsoft Teams notifications

Import-Module AADInternals

$user = "meganb@M---.onmicrosoft.com" #Replace this with your tenant's username
$password = "" #And your password
$secpwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($user,$secpwd)

$token = Get-AADIntAccessTokenForTeams -Credentials $cred

$skypeToken = Get-AADIntSkypeToken -AccessToken $token

$result=Invoke-WebRequest -UseBasicParsing -Uri "https://amer.ng.msg.teams.microsoft.com/v1/users/ME/conversations/48%3Anotifications/messages?view=msnp24Equivalent|supportsMessageProperties&pageSize=200" `
-Headers @{
"method"="GET"
  "authority"="amer.ng.msg.teams.microsoft.com"
  "scheme"="https"
  "path"="/v1/users/ME/conversations/48%3Anotifications/messages?view=msnp24Equivalent|supportsMessageProperties&pageSize=200"
  "sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"96`", `"Microsoft Edge`";v=`"96`""
  "x-ms-session-id"="ae16f178-a088-a7bb-603b-27aad38b6c88"
  "behavioroverride"="redirectAs404"
  "x-ms-scenario-id"="130"
  "x-ms-client-cpm"="ApplicationLaunch"
  "x-ms-client-env"="pds-prod-azsc-usce-01"
  "x-ms-client-type"="web"
  "sec-ch-ua-mobile"="?0"
  "clientinfo"="os=windows; osVer=10; proc=x86; lcid=en-us; deviceType=1; country=us; clientName=skypeteams; clientVer=1415/1.0.0.2021120940; utcOffset=-06:00; timezone=America/Costa_Rica"
  "x-ms-client-version"="1415/1.0.0.2021120940"
  "x-ms-user-type"="null"
  "authentication"="skypetoken=$skypeToken"
  "sec-ch-ua-platform"="`"Windows`""
  "origin"="https://teams.microsoft.com"
  "sec-fetch-site"="same-site"
  "sec-fetch-mode"="cors"
  "sec-fetch-dest"="empty"
  "referer"="https://teams.microsoft.com/"
  "accept-encoding"="gzip, deflate, br"
  "accept-language"="es,es-ES;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
}

$messages=ConvertFrom-Json -InputObject $result.Content


$NotificationsToClear=$messages.messages | where-object {$_.properties.isread -ne "True"}


foreach($notifications in $notificationsToClear)
{

$urlFQDN="https://amer.ng.msg.teams.microsoft.com"
$urlPart1="/v1/users/ME/conversations/48%3Anotifications/messages/"
$urlPart3="/properties?name=isread"
$finalUrl=$urlFQDN+$urlPart1+$notifications.Id+$urlPart3

Write-Host "Clearing notification" $notifications.Id

$result=Invoke-WebRequest -UseBasicParsing -Uri $finalUrl `
-Method "PUT" `
-Headers @{
"method"="PUT"
  "authority"="amer.ng.msg.teams.microsoft.com"
  "scheme"="https"
  "path"=$urlPart1+$notifications.Id+$urlPart3
  "sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"96`", `"Microsoft Edge`";v=`"96`""
  "x-ms-user-type"="null"
  "x-ms-client-type"="web"
  "x-ms-client-version"="1415/1.0.0.2021120940"
  "authentication"="skypetoken=$skypeToken"
  "sec-ch-ua-platform"="`"Windows`""
  "x-ms-session-id"="a5ad4294-5752-458b-7bf0-7cdd06de88c9"
  "x-ms-scenario-id"="716"
  "x-ms-client-env"="pckgsvc-prod-c1-usea-01"
  "sec-ch-ua-mobile"="?0"
  "clientinfo"="os=windows; osVer=10; proc=x86; lcid=en-us; deviceType=1; country=us; clientName=skypeteams; clientVer=1415/1.0.0.2021120940; utcOffset=-06:00; timezone=America/Costa_Rica"
  "behavioroverride"="redirectAs404"
  "x-ms-client-caller"="markReadStatus"
  "origin"="https://teams.microsoft.com"
  "sec-fetch-site"="same-site"
  "sec-fetch-mode"="cors"
  "sec-fetch-dest"="empty"
  "referer"="https://teams.microsoft.com/"
  "accept-encoding"="gzip, deflate, br"
  "accept-language"="es,es-ES;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
} `
-ContentType "application/json" `
-Body "{`"isread`":true}"

}
