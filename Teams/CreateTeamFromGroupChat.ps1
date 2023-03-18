# Author: Andrés Gorzelany

   <# 
    .SYNOPSIS
        Creates a Microsoft Teams team from a Group Chat.
    .DESCRIPTION
        Creates a Microsoft Teams team from a Group Chat that you are part of, with the same members.
	It requires Graph PowerShell and Microsoft Teams PowerShell module.
    .EXAMPLE
        CreateTeamFromGroupChat.ps1
    #>

#Connect to Graph
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All,Chat.Read,Chat.ReadWrite,ChatMember.ReadWrite,Chat.ReadBasic" -ForceRefresh

$sipURI=Read-Host "Enter your SIP URI"
Write-Host "Entered user has the following active chats" -ForegroundColor Green
Write-Host "-------------------------------------------" -ForegroundColor Green
Get-MgUserChat -UserId $sipURI -Verbose

foreach($userChat in $userChats){$userChat.id}
Write-Host "To better identify chats, open teams web, browse to chats and look the URL for the desired chat." -ForegroundColor Green

$groupChat=Read-Host "Copy the desired group id chat from the list and paste it here:"

Write-Host "Listing members of the entered Group Chat" -ForegroundColor Green

$members=Get-MgUserChatMember -ChatId $groupChat -UserId $sipURI

$memberProperties=$members.AdditionalProperties
foreach($mp in $memberproperties){$mp.email}

Write-Host "Done, now connecting to Teams PowerShell..." -ForegroundColor Green

Connect-MicrosoftTeams

$newTeamName=Read-Host "Name your new Team"
$newTeamNick=$newTeamName -replace " ",""
$newTeamVisibility=Read-Host "Enter public or private"
$group = New-Team -displayname $newTeamName

foreach($mp in $memberproperties){
	
	Add-TeamUser -GroupId $group.GroupId -User $mp.email -MailNickname $newTeamNick -visibility $newTeamVisibility
	}
	
Write-Host "Done, now showing results..." -ForegroundColor Green

Get-Team -GroupId $group.GroupId

Get-TeamUser -GroupId $group.GroupId
