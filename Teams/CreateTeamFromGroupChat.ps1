Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All,Chat.Read,Chat.ReadWrite,ChatMember.ReadWrite,Chat.ReadBasic"

Read-Host "Enter your email address"
Get-MgUserChat -UserId admin@M365x94367470.OnMicrosoft.com

$groupChat=Read-Host "Copy the desired group chat from the list and paste it here"

Write-Host "Listing members of the Group Chat"

$members=Get-MgUserChatMember -ChatId $groupChat -UserId admin@M365x94367470.OnMicrosoft.com

$memberProperties=$members.AdditionalProperties
foreach($mp in $memberproperties){$mp.email}

Connect-MicrosoftTeams

$newTeamName=Read-Host "Name your new Team"
$group = New-Team -displayname $newTeamName

foreach($mp in $memberproperties){
	
	Add-TeamUser -GroupId $group.GroupId -User $mp.email
	}
