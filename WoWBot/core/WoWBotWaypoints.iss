
function main()
{
	turbo 1000
	
	declare Zoom int global 8
	declare ShowWayPoints bool global FALSE
	declare PointsShown bool script FALSE
	declare TransX float
	declare TransY float
	declare PointCount int script 1
	declare HudCommand string script
	declare HudPointX float script
	declare HudPointY float script
	declare CharacterName string script ${Me.Name} /* Your characters name */
	declare Realm string script ${ISXWoW.RealmName}	/* The Current Realm */
	declare HomeDir filepath script ${Script.CurrentDirectory}	/* Holds the full path to wowbot.iss */
	declare PathFile string "${HomeDir}/../${Realm}/${CharacterName}/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml" /* Name of the Path file to use*/
	
	Navigation -reset
	Navigation -load "${PathFile}"
	declare World string script "WoWBot"	

	do
	{
		if ${Zoom}<1
		{
			Zoom:Set[1]
		}
		
		if ${Zoom}>10
		{
			Zoom:Set[10]
		}
		if ${ShowWayPoints}
		{
			TransX:Set[(-(${Me.Y})*${Zoom})-(${Display.Width}/2)]
			TransY:Set[(-(${Me.X})*${Zoom})-(${Display.Height}/2)]
	
			HudPointX:Set[${Math.Calc[(-(${Me.Y})*${Zoom})-${TransX}]}]
			HudPointY:Set[${Math.Calc[(-(${Me.X})*${Zoom})-${TransY}]}]
			HudCommand:Set[Squelch hud -add "${CharacterName}" ${HudPointX.Int}\,${HudPointY.Int} *]
			execute ${HudCommand}
			PointCount:Set[1]
			do
			{
				HudPointX:Set[${Math.Calc[(-(${Navigation.World[${World}].Point[${PointCount}].Y})*${Zoom})-${TransX}]}]
				HudPointY:Set[${Math.Calc[(-(${Navigation.World[${World}].Point[${PointCount}].X})*${Zoom})-${TransY}]}]
				if (${HudPointX}>0&&${HudPointX}<${Display.Width})&&(${HudPointY}>0&&${HudPointY}<${Display.Height})
				{
					HudCommand:Set[Squelch hud -add "${Navigation.World[${World}].Point[${PointCount}].Name}" ${HudPointX.Int}\,${HudPointY.Int} *]
					execute ${HudCommand}
				}
				else
				{
					HudCommand:Set[Squelch hud -remove "${Navigation.World[${World}].Point[${PointCount}].Name}"] 
					execute ${HudCommand}			
				}
			}
			while ${PointCount:Inc}<=${Navigation.World[${World}].Points}
			PointsShown:Set[TRUE]
			waitframe
		}
		if !${ShowWayPoints}&&${PointsShown}
		{
			PointCount:Set[1]
			HudCommand:Set[Squelch hud -remove "${CharacterName}"] 
			execute ${HudCommand}			
			do
			{
				HudCommand:Set[Squelch hud -remove "${Navigation.World[${World}].Point[${PointCount}].Name}"] 
				execute ${HudCommand}
			}
			while ${PointCount:Inc}<=${Navigation.World[${World}].Points}
			PointsShown:Set[FALSE]
			waitframe
		}
		waitframe
	}
	while TRUE
}

function atexit()
{
	PointCount:Set[1]
	HudCommand:Set[Squelch hud -remove "${CharacterName}"] 
	execute ${HudCommand}			
	do
	{
		HudCommand:Set[Squelch hud -remove "${Navigation.World[${World}].Point[${PointCount}].Name}"] 
		execute ${HudCommand}
	}
	while ${PointCount:Inc}<=${Navigation.World[${World}].Points}

}
