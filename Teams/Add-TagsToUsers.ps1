function Add-TagsToUsers{

  #CSV file containing the team objectId, user id and tag name
  $userAndTags="usersAndTags.csv"
  $csv = Import-CSV -Delimiter ";" -Path $userAndTags

  #Authentication
  ## Let's load the great AADInternals module
  Import-Module AADInternals
  #Let's request a chat service token
  $token = Get-AADIntAccessToken -Resource https://chatsvcagg.teams.microsoft.com -ClientId "1fec8e78-bce4-4aaf-ab1b-5451cc387264"

  #Some variable definitions - Do not change this
  $urlPart1="https://teams.microsoft.com/api/csa/amer/api/v1/teams/19:"
  $urlPart3="@thread.tacv2/memberTags/?action=add"

  #For each entry in the csv we will try to add the user to the tag
  foreach($entry in $csv){

      $objectId=$entry.objectId
      $userId=$entry.userId
      $tag=$entry.tag

      $uri = $urlPart1+$objectId+$urlPart3
      Write-Verbose $uri
      $body = "{`"tagNames`":[`"$tag`"],`"memberIds`":[`"8:orgid:$userId`"]}"  
      Write-Verbose $body  
      $path="/api/csa/amer/api/v1/teams/19:$objectId@thread.tacv2/memberTags/?action=add"
      Write-Verbose $path
      $guid=(New-Guid).Guid
      
      $Result=Invoke-WebRequest -UseBasicParsing -Uri $uri `
      -Method "POST" `
      -Headers @{
      "authority"="teams.microsoft.com"
        "method"="POST"
        "path"=$path
        "scheme"="https"
        "accept"="json"
        "accept-encoding"="gzip, deflate, br"
        "accept-language"="es,es-ES;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
        "authorization"="Bearer $token"
        "origin"="https://teams.microsoft.com"
        "referer"="https://teams.microsoft.com/_"
        "sec-ch-ua"="`"Chromium`";v=`"106`", `"Microsoft Edge`";v=`"106`", `"Not;A=Brand`";v=`"99`""
        "sec-ch-ua-mobile"="?0"
        "sec-ch-ua-platform"="`"Windows`""
        "sec-fetch-dest"="empty"
        "sec-fetch-mode"="cors"
        "sec-fetch-site"="same-origin"
        "x-ms-client-env"="pds-prod-c1-ussc-01"
        "x-ms-client-type"="web"
        "x-ms-client-version"="1415/1.0.0.2022092126"
        "x-ms-scenario-id"="511"
        "x-ms-session-id"=$guid
        "x-ms-user-type"="null"
        "x-ringoverride"="general"
      } `
      -ContentType "application/json" `
      -Body $body `

      $Result
  }

}
Add-TagsToUsers
