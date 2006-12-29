
;Initialize our Navigation System.
function InitNavigation()
{
	Navigation -reset
	Navigation -load "${PathFile}"
	if !${Navigation.World["${World}"].Points(exists)}
	{
		Messagebox -template WoW.messagebox -yesno "ERROR: Navigation path not found.\n If you have not yet created one you can use.\n WoWBotPath.iss to do it. Do you want to run it now ?"
		Switch ${UserInput}
		{	
			case Yes
				RunScript ./core/WoWBotPath "../pathfiles/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml"
				Script:End
				break
			
			case No
			case NULL
				Script:End
				break
		}
	}
	;Our patrol path should remain the same throughout a session so calculate it now.
	PatrolPath:GetPath[${World},${PatrolWaypoints}]
}

;Set a path to our Patrol path.
function SetAdvancePath()
{
	call UpdateHudStatus "Generating a Path to Patrol Path"
	TravelingPath:GetPath[${World},${Navigation.World[${World}].Point[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}].Name},${PatrolPath.PointName[${PatrolPath.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]}]
	TempPath:GetPath[${World},${Navigation.World[${World}].Point[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}].Name},${PatrolStartPoint}]
	debug("SetAdvancePath:Travel Points:${TravelingPath.Points}") 
	debug("SetAdvancePath:Travel Points:${TempPath.Points}")
	if ${TravelingPath.Points}<${TempPath.Points}
	{
		CurrentPath:Set[TravelingPath]
	}
	else
	{
		CurrentPath:Set[TempPath]
	}
	; Check we have a path to follow
	debug("SetAdvancePath:Total Points:${${CurrentPath}.Points}")
	if ${${CurrentPath}.Points}
	{
		CurrentWaypointIndex:Set[1]
		LastWaypointX:Set[${CurrentWaypointX}]
		LastWaypointY:Set[${CurrentWaypointY}]
		LastWaypointZ:Set[${CurrentWaypointZ}]
		CurrentWaypointX:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].X}]
		CurrentWaypointY:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Y}]
		CurrentWaypointZ:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Z}]
		TravelState:Set[ADVANCING]
		CurrentWaypointIndex:Set[0]
		call DumpPath "${CurrentPath}"
	}
	; If no then we must already be near the patrol path.
	else
	{
		debug("SetAdvancePath:Already close to path")
		TravelState:Set[PATROLING]
		CurrentPath:Set[PatrolPath]
		CurrentWaypointIndex:Set[${PatrolPath.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]				
		LastWaypointX:Set[${CurrentWaypointX}]
		LastWaypointY:Set[${CurrentWaypointY}]
		LastWaypointZ:Set[${CurrentWaypointZ}]
		CurrentWaypointX:Set[${PatrolPath.Point[${CurrentWaypointIndex}].X}]
		CurrentWaypointY:Set[${PatrolPath.Point[${CurrentWaypointIndex}].Y}]
		CurrentWaypointZ:Set[${PatrolPath.Point[${CurrentWaypointIndex}].Z}]

	}
}

; Run to our lifless husk and rez.
function SetCorpseRunPath()
{
	;Clear out current path
	TravelingPath:Clear

	;Generate a Path to the nearest waypoint to our death location
	debug("SetCorpseRunPath:Corpse at ${Me.Corpse.X} ${Me.Corpse.Y} ${Me.Corpse.Z} nearest point ${Navigation.World[${World}].Point[${Navigation.World["${World}"].NearestPoint[${Me.Corpse.X},${Me.Corpse.Y},${Me.Corpse.Z}]}].Name}")
	TravelingPath:GetPath[${World},${Navigation.World[${World}].Point[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}].Name},${Navigation.World[${World}].Point[${Navigation.World["${World}"].NearestPoint[${Me.Corpse.X},${Me.Corpse.Y},${Me.Corpse.Z}]}].Name}]


	CurrentPath:Set[TravelingPath]
	call DumpPath "${CurrentPath}"
	CurrentWaypointIndex:Set[1]
	LastWaypointX:Set[${CurrentWaypointX}]
	LastWaypointY:Set[${CurrentWaypointY}]
	LastWaypointZ:Set[${CurrentWaypointZ}]
	CurrentWaypointX:Set[${TravelingPath.Point[${CurrentWaypointIndex}].X}]
	CurrentWaypointY:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Y}]
	CurrentWaypointZ:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Z}]
	TravelState:Set[CR]
	
}

;Set a path to our Merchant.
function SetMerchantPath()
{
	call UpdateHudStatus "Generating a Path to Merchant"
	TravelingPath:Clear
	TravelingPath:GetPath[${World},${Navigation.World["${World}"].Point[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}].Name},${MerchantPoint}]
	CurrentPath:Set[TravelingPath]
	call DumpPath "${CurrentPath}"
	CurrentWaypointIndex:Set[1]
	LastWaypointX:Set[${CurrentWaypointX}]
	LastWaypointY:Set[${CurrentWaypointY}]
	LastWaypointZ:Set[${CurrentWaypointZ}]
	CurrentWaypointX:Set[${TravelingPath.Point[${CurrentWaypointIndex}].X}]
	CurrentWaypointY:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Y}]
	CurrentWaypointZ:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Z}]
	TravelState:Set[SELLING]
}

;Set a path to our Safe Point.
function SetSafePointPath()
{
	call UpdateHudStatus "Generating a Path to Safe Point"
	TravelingPath:Clear
	TravelingPath:GetPath[${World},${Navigation.World["${World}"].Point[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}].Name},${SafePoint}]
	CurrentPath:Set[TravelingPath]
	call DumpPath "${CurrentPath}"
	CurrentWaypointIndex:Set[1]
	LastWaypointX:Set[${CurrentWaypointX}]
	LastWaypointY:Set[${CurrentWaypointY}]
	LastWaypointZ:Set[${CurrentWaypointZ}]
	CurrentWaypointX:Set[${TravelingPath.Point[${CurrentWaypointIndex}].X}]
	CurrentWaypointY:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Y}]
	CurrentWaypointZ:Set[${TravelingPath.Point[${CurrentWaypointIndex}].Z}]
	TravelState:Set[FLEEING]
}

; This functions walks you along the the next point along a path defined by CurrentPath
function Roam()
{
  if (${Me.Ghost} || ${Me.Dead}) && ${TravelState}!=CR
  {
    debug("In Roam, but dead and not on CR")
  	call SetAdvancePath
  	move -stop
  	wait 10
  	return
  }
  call CheckAggro
  if !${TargetGUID.Equal[NOTARGET]}
  {
    debug("I should stop roaming, I have agro!")
    debug("My target is: ${Object[${TargetGUID}].Name}, ${Object[${TargetGUID}].Distance} yards away...");
    return
  }
	declare NearestPatrolPointIndex int local
	NearestPatrolPointIndex:Set[${PatrolPath.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
	if (!${Me.InCombat}||${FalseAggro}) && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${PatrolPath.Point[${NearestPatrolPointIndex}].X},${PatrolPath.Point[${NearestPatrolPointIndex}].Y},${PatrolPath.Point[${NearestPatrolPointIndex}].Z}]}>${MaxRoam} && ${TravelState}==PATROLING
	{
		debug("I'm more than 50 yards from my nearest waypoint...")
		call SetAdvancePath
	}

  ;Check which is the next nearest point along our path and make it our current destination point
	if ${${CurrentPath}.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}>${CurrentWaypointIndex}
	{
		CurrentWaypointIndex:Set[${${CurrentPath}.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
	}
	else
	{
		CurrentWaypointIndex:Inc
	}
	;If we reach the end of our path

	if ${CurrentWaypointIndex}>${${CurrentPath}.Points}
	{
		call UpdateHudStatus "${TravelState}"
		switch ${TravelState}
		{
			;If we are patroling then reverse our path
			case PATROLING
				call UpdateHudStatus "Arrived at end of patrol route."
				if !${LoopPatrolPath}
				{
					debug("Roam:Reversing path")
					${CurrentPath}:Reverse
					CurrentWaypointIndex:Set[2]
					break
				}
				debug("Roam:Looping path")
				CurrentWaypointIndex:Set[1]
				LastWaypointX:Set[${CurrentWaypointX}]
				LastWaypointY:Set[${CurrentWaypointY}]
				LastWaypointZ:Set[${CurrentWaypointZ}]
				CurrentWaypointX:Set[${PatrolPath.Point[${CurrentWaypointIndex}].X}]
				CurrentWaypointY:Set[${PatrolPath.Point[${CurrentWaypointIndex}].Y}]
				CurrentWaypointZ:Set[${PatrolPath.Point[${CurrentWaypointIndex}].Z}]

				if ${Skirmish}
				{
					call skirmishtocont ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
				}
				else
				{
					call movetocont ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
				}
				break
			;If we were fleeing then we have made it to the safe point
			case FLEEING
				call UpdateHudStatus "Arrived at Safe Point."
				TravelState:Set[ADVANCING]
				break
			;If we were fleeing then we have made it to the safe point
			case CR
				call UpdateHudStatus "Arrived at Corpse."
				call RessurectMe
				TravelState:Set[ADVANCING]
				break
			;If we were heading to merchant we should be there
			case SELLING
				call UpdateHudStatus "Arrived at Merchant."
				AtMerchant:Set[TRUE]
				break
			;If we were advancing to patrol path were there now
			case ADVANCING
				call UpdateHudStatus "Arrived at start of Patrol Route."
				TravelState:Set[PATROLING]
				CurrentPath:Set[PatrolPath]
				CurrentWaypointIndex:Set[1]				
				break			
		}
		return
	}

	debug("State:${TravelState} Path:${CurrentPath} Point:${${CurrentPath}.PointName[${CurrentWaypointIndex}]} ${CurrentWaypointIndex} of ${${CurrentPath}.Points} Points ")
	
	LastWaypointX:Set[${CurrentWaypointX}]
	LastWaypointY:Set[${CurrentWaypointY}]
	LastWaypointZ:Set[${CurrentWaypointZ}]
	CurrentWaypointX:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].X}]
	CurrentWaypointY:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Y}]
	CurrentWaypointZ:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Z}]
	call UpdateHudStatus "Running to Next Waypoint"
	switch ${TravelState}
	{
		case FLEEING
			call fleeto ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
			break
			
		case PATROLING
			if ${Skirmish}
			{
				call skirmishtocont ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
				break
			}
		default
			call movetocont ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
			break
	}
	NoTargetCount:Set[0]	
	NoObjectCount:Set[0]	
}

;
; Run like a girl to a safe point.
;
function FallBack()
{
	declare FallBackPath navpath
	declare FallBackPathIndex int 1
	
	;Generate a Path to the nearest waypoint to our death location
	FallBackPath:GetPath[${World},${Navigation.World["${World}"].Point[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y}]}].Name},${SafePoint}]

	; Run to within 35 of our corpse
	call UpdateHudStatus "Running like a girl to Safe Point"
	do
	{
		call UpdateHudStatus "Heading to point ${FallBackPath.Point[${FallBackPathIndex}].X} ${FallBackPath.Point[${FallBackPathIndex}].Y}"
		call fleeto ${FallBackPath.Point[${FallBackPathIndex}].X} ${FallBackPath.Point[${FallBackPathIndex}].Y} 2
	}
	while ${FallBackPathIndex:Inc}<=${FallBackPath.Points}&&${Me.InCombat}&&!${Me.Dead}
	RLG:Set[FALSE]
	DoDowntime:Set[TRUE]
	DoCombatPrep:Set[TRUE]	
}

function GoHome()
{
	;Return to home point
	CurrentWaypointIndex:Set[${${CurrentPath}.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
	LastWaypointX:Set[${CurrentWaypointX}]
	LastWaypointY:Set[${CurrentWaypointY}]
	LastWaypointZ:Set[${CurrentWaypointZ}]
	CurrentWaypointX:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].X}]
	CurrentWaypointY:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Y}]
	CurrentWaypointZ:Set[${${CurrentPath}.Point[${CurrentWaypointIndex}].Z}]
	call UpdateHudStatus "Running to home point"
	call moveto ${CurrentWaypointX} ${CurrentWaypointY} WPPRECISION
}