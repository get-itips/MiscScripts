# Author: Andrés Gorzelany

   <# 
    .SYNOPSIS
        Find Teams Media logs, zip them and send them using local Outlook
    .DESCRIPTION
        Find Teams Media logs, zip them and send them using local Outlook
        This version doesn't take any parameters.
    .EXAMPLE
        Copy-TeamsMediaLogsML.ps1
    #>

$BuildVersion="0.1"
$loggedOnuser=(Get-CimInstance -ClassName Win32_ComputerSystem).Username
#Variable definitions

$emailTo="replace@this.com"
$emailSubject="Teams Media Logs from: "+$loggedOnuser

$MediaStackPath="$env:APPDATA\Microsoft\Teams\media-stack\"
$TempMediaStackPath=$MediaStackPath+"Temp"

$SkyLibPath="$env:APPDATA\Microsoft\Teams\skylib\"
$TempSkylibPath=$SkyLibPath+"Temp"

$MediaStackZipPath=$MediaStackPath+"TeamsMedia-StackLogs.Zip"

$SkylibZipPath=$SkyLibPath+"TeamsSkylibLogs.Zip"

function WriteCatchInfo {
    $Script:ErrorOccurred = $true
}

function TestPaths{
    if (!(Test-Path($MediaStackPath)) -or !(Test-Path($SkyLibPath)))
    {
        throw "Could not determine Media Logs path"
    }
}

function Main{


#Show information to user
Write-Host "-----------------------" -ForegroundColor Blue -BackgroundColor Red
Write-Host ""
Write-Host "It's better to close Microsoft Teams exe before gathering logs" -ForegroundColor Blue -BackgroundColor Red
Write-Host "Teams Media Logging policy must be enabled for the user" -ForegroundColor Blue -BackgroundColor Red
Write-Host "The script is intended to be running on the computer where you need to get logs from" -ForegroundColor Blue -BackgroundColor Red

Write-Host "Start"
Write-Host "The script will try to get the logs from:"  -ForegroundColor Blue
Write-Host "Media Stack Path:"   -ForegroundColor DarkMagenta
Write-Host $MediaStackPath   -ForegroundColor DarkMagenta

Write-Host "Skylib Path:"  -ForegroundColor DarkMagenta
Write-Host $SkyLibPath   -ForegroundColor DarkMagenta

Write-Host "The script will try to create temp folder in:"   -ForegroundColor DarkMagenta
Write-Host "Media Temp Stack Path:"   -ForegroundColor DarkMagenta
Write-Host $TempMediaStackPath  -ForegroundColor DarkMagenta

Write-Host "Skylib Temp Path:" -ForegroundColor DarkMagenta
Write-Host $TempSkylibPath -ForegroundColor DarkMagenta

Read-Host "The script will try to find, zip and send the Teams media logs files using Outlook, hit any key to continue or Ctrl-C to exit"

TestPaths

# Copy logs to a temp folder
New-Item $TempMediaStackPath -itemType Directory -Verbose
Copy-item -Path $MediaStackPath* -Destination $TempMediaStackPath -Exclude Temp

New-Item $TempSkylibPath -itemType Directory -Verbose
Copy-item -Path $SkyLibPath* -Destination $TempSkylibPath -Exclude Temp

#Find and zip media logs

# %appdata%\Microsoft\Teams\media-stack\\\*\.blog

# %appdata%\Microsoft\Teams\skylib\\\*\.blog


$compress = @{
    Path = $TempMediaStackPath
    CompressionLevel = "Optimal"
    DestinationPath = $MediaStackZipPath
  }
  Compress-Archive @compress


$compress = @{
    Path = $TempSkylibPath
    CompressionLevel = "Optimal"
    DestinationPath = $SkylibZipPath
  }
  Compress-Archive @compress


#Thanks https://tekcookie.com/send-email-from-outlook-using-powershell/
$outlook = new-object -comobject outlook.application

$email = $outlook.CreateItem(0)
$email.To = $emailTo
$email.Subject = $emailSubject
$email.Body = "Files attached" 
$email.Attachments.add($MediaStackZipPath)
$email.Attachments.add($SkylibZipPath)
$email.send()

#Cleanup temp files and folders
remove-item $MediaStackZipPath -Verbose
remove-item $SkylibZipPath  -Verbose

remove-item $TempMediaStackPath -Confirm:$false -Recurse -Verbose
remove-item $TempSkylibPath -Confirm:$false -Recurse -Verbose

}

try{
    Write-Host "Copy-TeamsMedialogsML.ps1 Build "$BuildVersion -ForegroundColor Blue -BackgroundColor Red
    Main
}
catch {
    Write-Host "Something failed - Check output"
    Write-Host $Error[0]
    WriteCatchInfo
}
finally {
    if ($Script:ErrorOccurred) {
        Write-Warning ("Ran into an issue with the script.")
    }
}
