# Clear All Microsoft Teams Notifications

Import-Module AADInternals

# This will prompt for credentials so it supports MFA login

if($null -eq $global:Token) {

	Write-Host 'Getting Token...'

	$global:Token 	= Get-AADIntAccessTokenForTeams
	$global:Token 	= Get-AADIntSkypeToken -AccessToken $global:Token

}
else {
	Write-Host 'We Already Have A Token, Proceeding...'
}

$Root	= 'https://amer.ng.msg.teams.microsoft.com';
$Path	= '/v1/users/ME/conversations/48%3Anotifications/messages/';
$Query	= '?view=msnp24Equivalent|supportsMessageProperties&pageSize='+$args[0];
$URI 	= $Path+$Query;
$URL 	= $Root+$URI;

while($URL) {

	$Result	= Invoke-WebRequest -UseBasicParsing -Uri "$URL" `
	-Headers @{
	"method"="GET"
	"authority"="amer.ng.msg.teams.microsoft.com"
	"scheme"="https"
	"path"="$URI"
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
	"authentication"="skypetoken=$global:Token"
	"sec-ch-ua-platform"="`"Windows`""
	"origin"="https://teams.microsoft.com"
	"sec-fetch-site"="same-site"
	"sec-fetch-mode"="cors"
	"sec-fetch-dest"="empty"
	"referer"="https://teams.microsoft.com/"
	"accept-encoding"="gzip, deflate, br"
	"accept-language"="es,es-ES;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
	}

	$Data					= ConvertFrom-Json -InputObject $result.Content
	$URL 					= $Data._metadata.backwardLink
	$NotificationsToClear	= $Data.messages | where-object {$_.properties.isread -ne "True"}
	
	foreach($N in $NotificationsToClear) {
		
		$_PathEnd_Query	= "/properties?name=isread"
		$PUT			= $Root+$Path+$N.Id+$_PathEnd_Query

		Write-Host "Clearing Notification: "$N.Id

		try {

			$Result = Invoke-WebRequest -UseBasicParsing -Uri $PUT `
			-Method "PUT" `
			-Headers @{
			"method"="PUT"
			"authority"="amer.ng.msg.teams.microsoft.com"
			"scheme"="https"
			"path"=$Path+$N.Id+$_PathEnd_Query
			"sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"96`", `"Microsoft Edge`";v=`"96`""
			"x-ms-user-type"="null"
			"x-ms-client-type"="web"
			"x-ms-client-version"="1415/1.0.0.2021120940"
			"authentication"="skypetoken=$Token"
			"sec-ch-ua-platform"="`"Windows`""
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

			Start-Sleep -Milliseconds 500;

		}
		catch {

			Start-Sleep -Milliseconds 2500;
			Write-Warning("Code: "+$_.Exception.Response.StatusCode+" | Description: "+$_.Exception.Response.StatusDescription);

			Continue;
			

		}

	}

	Write-Host "Next URL = "$URL;

}
