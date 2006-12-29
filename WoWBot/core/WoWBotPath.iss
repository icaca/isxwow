
;Check to see if ISXWoW has loaded.
#if !${InnerSpace:LoadExtension[isxwow](exists)}
#error ISXWoW is required but could not be loaded
#endif

#include debug.iss
#include moveto.iss
#include uibits.iss
#include HudStat.iss

function AddPoint(string PointName,float PointX,float PointY,float PointZ)
{

	NavPoint -set "${World}" "${PointName}" ${PointX} ${PointY} ${PointZ} 
	NavPoint -connect -bidirectional "${World}" "${LastPoint}" "${PointName}"
	call UpdateHudStatus "Added Point ${PointName} ${PointX} ${PointY} ${PointZ}"
	call UpdateHudStatus "Connected Point ${PointName} ${LastPoint}"

	LastPoint:Set[${PointName}]
}



Function MakePath(string Name)
{
	declare CurrentX float local ${Me.X}
	declare CurrentY float local ${Me.Y}
	declare CurrentZ float local ${Me.Z}
	declare CurrentHeading float local ${Me.Heading}
	declare LastX float local ${CurrentX}
	declare LastY float local ${CurrentY}
	declare LastZ float local ${CurrentZ}
	declare LastHeading float local ${CurrentHeading}
	declare Counter int local 1

	FinishedPath:Set[FALSE]
	
	UI -load "${Script.CurrentDirectory}/../interface/WoWBotFinishedPathUI.xml"

	call AddPoint "${Name}_Start" ${CurrentX} ${CurrentY} ${CurrentZ}

	do
	{
		if !${PauseMakePath}
		{
			CurrentX:Set[${Me.X}]	
			CurrentY:Set[${Me.Y}]	
			CurrentZ:Set[${Me.Z}]
			CurrentHeading:Set[${Me.Heading}]

			if ${Math.Distance[${CurrentX},${CurrentY},${CurrentZ},${LastX},${LastY},${LastZ}]}>10||(${Math.Distance[${CurrentX},${CurrentY},${CurrentZ},${LastX},${LastY},${LastZ}]}>3 && ${Math.Abs[${CurrentHeading}-${LastHeading}]}>2)
			{
				call AddPoint "${Name}_${Counter}" ${CurrentX} ${CurrentY} ${CurrentZ}
				LastX:Set[${CurrentX}]	
				LastY:Set[${CurrentY}]	
				LastZ:Set[${CurrentZ}]
				Counter:Inc
				LastHeading:Set[${CurrentHeading}]
			}	
		}
		wait 10		
	}
	while !${FinishedPath}

	call AddPoint "${Name}_End" ${CurrentX} ${CurrentY} ${CurrentZ}
	UI -unload "${Script.CurrentDirectory}/../interface/WoWBotFinishedPathUI.xml"
}

function main(string NewPathFile2)
{
	turbo 1000
	declare CharacterName string script ${Me.Name} /* Your characters name */
	declare Realm string script ${ISXWoW.RealmName}	/* The Current Realm */
	declare NewPathFile string script "../pathfiles/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml"
	declare SettingFile string script "../${Realm}/${CharacterName}/WoWBot_${CharacterName}.xml"
	declare World string script "WoWBot"
	declare LastPoint string script
	declare SafePoint string script
	declare FinishedPath bool script FALSE
	declare PauseMakePath bool script FALSE 
	if ${NewPathFile2(exists)}
	{
		NewPathFile:Set["../pathfiles/${NewPathFile2}"]
	}
	
	if !${Me(exists)}
	{
		call ShowMessage "ERROR: Please only run this script when you have a character loaded"
		return
	}

	ui -load "${Script.CurrentDirectory}/../interface/wowskin.xml"

	call SetDebugFile "../${Realm}/${CharacterName}/WoWBotPath_Debug.log"
	call SetupHudStatus
	Navigation -reset
	Navigation -load ${NewPathFile}

	if ${Navigation.World[${World}](exists)}
	{
		call ShowMessage "ERROR: Path file ${NewPathFile} already exists.\nThis script only supports creating new path files.\nPlease delete or rename it before restarting"
		Script:End
	}
	
	call ShowMessage "To start creating a path first run to a safe point. \nThis will be the hub that all other path start from. \nClick OK when you are there."
	call AddPoint "Safe_Point" ${Me.X} ${Me.Y} ${Me.Z}
	call ShowMessage "Now you will create a path to the Graveyard.\nClick OK to continue"
	call MakePath CorpseRun
	call ShowMessage "Click OK to auto run back to safe point."
	call WalkPath "${World}" "${LastPoint}" "Safe_Point"
	LastPoint:Set[Safe_Point]
	call ShowMessage "Now you will create a path to the Nearest Merchant.\nClick OK to continue"
	call MakePath MerchantRun
	call ShowMessage "Click OK to auto run back to safe point."
	call WalkPath "${World}" "${LastPoint}" "Safe_Point"
	LastPoint:Set[Safe_Point]
	call ShowMessage "Now you will create a path to the start of your Hunting Route.\nClick OK to continue"
	call MakePath Advance
	call ShowMessage "Now you will make your hunting route.\nClick OK to continue"
	call MakePath Patrol
	call ShowMessage "All done.\nClick OK to Finish"
}

function atexit()
{
	; Clean up if the script is ended
	SettingXML[${SettingFile}].Set[Pathing Options]:Set[GraveyardPoint,"CorpseRun_End"]
	SettingXML[${SettingFile}].Set[Pathing Options]:Set[SafePoint,"Safe_Point"]
	SettingXML[${SettingFile}].Set[Pathing Options]:Set[MerchantPoint,"MerchantRun_End"]
	SettingXML[${SettingFile}].Set[Pathing Options]:Set[PatrolWaypoints,"Patrol_Start\\,Patrol_End"]}]
	SettingXML[${SettingFile}]:Save
	Navigation -dump "${NewPathFile}"
	if ${Script[WoWBotWaypoints](exists)}
	{
		EndScript WoWBotWaypoints
	}
	ui -unload "${Script.CurrentDirectory}/../interface/wowskin.xml"

}
