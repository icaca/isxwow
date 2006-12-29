;+-----------------------------------------------------------------------------------------------------
;| Name: Misc.iss
;| Description: Misc. functions for WoWBot
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CheckDurability
;| In:
;| Returns:
;| Description: Loops through your inventory and sets a flag if anything is below the repair percentage 
;|              level set in your config file.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function CheckDurability()
{
	declare Index int
	while ${Index:Inc} <= 19
	{
		if ${Me.Equip[${Index}](exists)} && ${Me.Equip[${Index}].PctDurability}<${RepairPctLevel}
		{
			call UpdateHudStatus "${Me.Equip[${Index}].Name} is too Broken best Repair"			
			NeedRepair:Set[TRUE]	
		}
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: CheckInventory
;| In:
;| Returns:
;| Description: Loops through your inventory and counts free slots, while excluding quivers, ammo pouches, and soul bags
;|
;| ©2006 Vendan
;+-----------------------------------------------------------------------------------------------------
function CheckInventory()
{
	declare Bag int
	declare Slots int
	Slots:Set[0]
	Bag:Set[-1]
	
	while ${Bag:Inc} <= 4
	{
		if ${Me.Bag[${Bag}](exists)} && !${Me.Bag[${Bag}].Name.Find["Quiver"]} && !${Me.Bag[${Bag}].Name.Find["Ammo Pouch"]} && !${Me.Bag[${Bag}].Name.Find["Soul"]} && !${Me.Bag[${Bag}].Name.Find["Bandolier"]} && !${Me.Bag[${Bag}].Name.Find["Felcloth"]} && !${Me.Bag[${Bag}].Name.Find["Lamina"]}
		{
			Slots:Inc[${Me.Bag[${Bag}].EmptySlots}]
		}
	}
	return ${Slots}
}
;+-----------------------------------------------------------------------------------------------------
;| Name: DistPointLine
;| In:  px py x1 y1 x2 y2
;| Returns: distance
;| Description: Calculates the distance of point the defined by px,py from the line defined by
;|              x1,y1 and x2,y2
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function DistPointLine(float px,float py,float x1,float y1,float x2,float y2)
{
	;Make sure the line is in fact a point
	if ${x1}==${x2} && ${y1}==${y2}
	{
	
		Return ${Math.Distance[${px},${py},${x1},${y1}]}
	}
	declare sx float ${Math.Calc[${x2}-${x1}]}
	declare sy float ${Math.Calc[${y2}-${y1}]}
	declare q float ${Math.Calc[((${px}-${x1}) * (${x2}-${x1}) + (${py} - ${y1}) * (${y2}-${y1})) / (${sx}*${sx} + ${sy}*${sy})]}
	If ${q} < 0.0
	 q:Set[0]
	If ${q} > 1.0
	 q:Set[1]
	Return ${Math.Distance[${px},${py},${Math.Calc[(1-${q})*${x1}+${q}*${x2}]},${Math.Calc[(1-${q})*${y1} + ${q}*${y2}]}]}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: ExitGame
;| In: none
;| Returns: none
;| Description: Activates our hearthstone then logs.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function ExitGame()
{
			;Warping out
			debug("ExitGame:Using Hearthstone")
			Item[Hearthstone]:Use
			wait 100
			logout
			Script:End
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Beep
;| In: none
;| Returns: none
;| Description: Just makes a beep using the system speaker.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Beep()
{
	APICall ${System.GetProcAddress["Kernel32.dll","Beep"].Hex} Math.Dec[500] 250
}

;+-----------------------------------------------------------------------------------------------------
;| Name: UpdateStats
;| In: none
;| Returns: none
;| Description: Updates the running stats displayed in the WoWBot report.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function UpdateStats()
{
	wait 10
	TotalKills:Inc
	if ${Me.Level}<60
	{
		if ${Me.Exp}<${CurrentXP}
		{
			TotalXPGained:Set[${TotalXPGained}+(${XPToLevel})+${Me.Exp}]
		}
		else
		{
			TotalXPGained:Set[${TotalXPGained}+(${Me.Exp}-${CurrentXP})]
		}
		
		CurrentXP:Set[${Me.Exp}]		
		XPToLevel:Set[${Me.NextLevelExp}-${Me.Exp}]
		
		if ${TotalXPGained}>0
		{
			XPSec:Set[${TotalXPGained}/(${Script.RunningTime}/1000)]
			TimeNextLevel:Set[${XPToLevel}/${XPSec}]
		}
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: DumpStats
;| In: none
;| Returns: none
;| Description: Dumps the Running stats for WoWBot into a logfile and console
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function DumpStats()
{
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo WoWBot VERSION Running Stats for ${CharacterName} on ${Time.Date} ${Time}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo -------------------------------------------------------------------
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo           Running Time: ${Script.RunningTime}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo            Total kills: ${TotalKills}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo           Total Deaths: ${TotalDeaths}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo        Total XP Gained: ${TotalXPGained}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo          Total XP/Hour: ${Math.Calc[${XPSec}*3600]}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo Exp left to Next Level: ${XPToLevel}
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo           Money Earned: ${Math.Calc[${moneygain} / 10000].Int.LeadingZeroes[2]}g ${Math.Calc[(${moneygain} / 100) % 100].Int.LeadingZeroes[2]}s ${Math.Calc[${moneygain} % 100].Int.LeadingZeroes[2]}c
	redirect -append "${HomeDir}/${Realm}/${CharacterName}/StatsLog.txt" echo -------------------------------------------------------------------
}

;+-----------------------------------------------------------------------------------------------------
;| Name: CheckAggro
;| In: none
;| Returns: none
;| Description: Loops through nearby Units to see if they have aggroed. if they have aggroed then 
;|              sets TargetGUID to the GUID of the aggroing Unit,
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function CheckAggro()
{
	declare aggroIndex int local 1
	declare NearestGUID string local "NOTARGET"
	declare NearestDistance float local 100
	declare AggroList guidlist local

	; We have aggroed something so lets check what it is
	AggroList:Search[-players,-units,-pvp,-alive,-hostile,-nearest,-targetingme,-range 0-50]
  if !${AggroList.Count}
  {
  	debug("No aggro detected, clearing TargetGUID, setting FalseAggro")
    FalseAggro:Set[TRUE]
	  FalseAggroTimer:Set[${Script.RunningTime}+3000]
	  TargetGUID:Set[NOTARGET]
	  return
	}  
	; make sure we have got some units nearby (we should!)
	
	debug("CheckAggro:Possible Aggros:${AggroList.Count}")
	;If we found some Aggro units
	if ${AggroList.Count}
	{
		; The closest aggro mob might not be your so we will search them all checking if they
		; have you or your pet targeted
		do
		{
			debug("CheckAggro:Checking aggro on ${Object[${AggroList.GUID[${aggroIndex}]}].Name} at distance ${Object[${AggroList.GUID[${aggroIndex}]}].Distance}")
			if (${Object[${AggroList.GUID[${aggroIndex}]}].Target.GUID.Equal[${Me.GUID}]}||${Object[${AggroList.GUID[${aggroIndex}]}].Target.GUID.Equal[${Me.Pet.GUID}]})&&!${Object[${AggroList.GUID[${aggroIndex}]}].Mine}
			{
				TargetGUID:Set[${AggroList.GUID[${aggroIndex}]}]
				debug("Aggro detected from: ${Object[${AggroList.GUID[${aggroIndex}]}].Name} at ${Object[${AggroList.GUID[${aggroIndex}]}].Distance} yards away.")
				call UpdateHudStatus "${Object[${TargetGUID}].Name} Aggrod"
				return
			}
			else
			{
			  TargetGUID:Set[NOTARGET]
			}
		}
		while ${aggroIndex:Inc}<=${AggroList.Count}
	}
	else	
	{
		;Just in case we have got aggro but the search isnt picking it up lets check if we have a target
		; and its targeting us.
		debug("CheckAggro:${Object[${Target.GUID}].AttackingUnit.GUID.Equal[${Me.GUID}]}")
		if ${Object[${Target.GUID}](exists)}&&${Object[${Target.GUID}].AttackingUnit.GUID.Equal[${Me.GUID}]}
		{
			TargetGUID:Set[${Target.GUID}]
			call UpdateHudStatus "${Object[${TargetGUID}].Name} has us targeted so I'll go with it"
			debug ("A${AggroList.GUID[${aggroIndex}].Name} has us targeted at ${AggroList.GUID[${aggroIndex}].Distance} yards away.")
			Target ${TargetGUID}
			return
		}
		else
		{
			;debug("False Aggro delaying checks")
			FalseAggro:Set[TRUE]
			TargetGUID:Set[NOTARGET]
			FalseAggroTimer:Set[${Script.RunningTime}+3000]
		}
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Loot
;| In: LootGUID
;| Returns: none
;| Description: Loots the Unit specified by LootGUID then space allowing in the inventory
;|              checks for nearby corpses and loots thoose too. If enabled all Units are
;|              also skinned.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
;
; function to loot nearby lootable corpses
;
function Loot(string LootGUID)
{
	declare Index int 1
	declare Corpses guidlist local

	call UpdateHudStatus "Looting ${Unit[${LootGUID}].Name}"

	
	;Target the corpse
	Target ${LootGUID}

	;Make sure we are close enough to loot it
	call movetoobject ${LootGUID} 5

	;Check were not sat down
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}	


	;Wait for unit to be lootable
	wait 40 ${Unit[${LootGUID}].CanLoot}

	;Hold down shift so that we loot all.
	press -hold SHIFT
	waitframe

	;Use the target to loot it.
	Unit[${LootGUID}]:Use

	;Wait for looting to finish
	wait 40 !${Unit[${LootGUID}].Lootable}

	;Release the shift key
	press -release SHIFT
	waitframe

	; If we want to skin then wait for a bit for the unit to be flagged skinnable
	if ${DoSkinning}
	{
		wait 30 ${Unit[${LootGUID}].Skinnable}
		
		; If unit is now skinnable skin it
		if ${Unit[${LootGUID}].Skinnable}
		{
			call Skin ${LootGUID}
		}
	}
	
	; Reset the target
	TargetGUID:Set[NOTARGET]

	; Only cleanup corpses if I have free inventory slots.
	; This may mean you dont loot adds that have coin but better then keep
	; on checking the same corpses.
	call CheckInventory
	if ${Return}-${KeepEmpty}>=0
	{
		;Use the object search to find all nearby lootable corpses  
		Corpses:Search[-units,-lootable,-nearest,-range 0-${MaxRoam}]
		
		;If we found lootable corpses then cycle through them
		if ${Corpses.Count}>0
		{
			do
			{
				LootGUID:Set[${Corpses.GUID[${Index}]}]

				;Make sure the unit is still lootable and its not too far off.
				if ${Unit[${LootGUID}](exists)}&&${Unit[${LootGUID}].Lootable}&&${Unit[${LootGUID}].Distance}<${MaxRoam}
				{
					call UpdateHudStatus "Looting ${Unit[${LootGUID}].Name}"
	
					;Target the corpse
					Target ${LootGUID}
	
					;Make sure we are close enough to loot it
					call movetoobject ${LootGUID} 5
	
					;Hold down shift so that we loot all.
					press -hold SHIFT
					waitframe
	
					;Use the target to loot it.
					Unit[${LootGUID}]:Use
	
					;Wait for looting to finish
					wait 40 !${Unit[${LootGUID}].Lootable}
	
					;Release the shift key
					press -release SHIFT
					waitframe
	
					; If we want to skin then wait for a bit for the unit to be flagged skinnable
					if ${DoSkinning}
					{
						wait 30 ${Unit[${LootGUID}].Skinnable}
		
						; If unit is now skinnable skin it
						if ${Unit[${LootGUID}].Skinnable}
						{
							call Skin ${LootGUID}
						}
					}
		
				; Reset the target
				TargetGUID:Set[NOTARGET]
				}
			}
			while ${Index:Inc}<=${Corpses.Count}&&!${Me.InCombat}
		}
	}
	
	; Clean out our Inventory
	if ${AutoDestroy}
	{
		call CleanInventory
	}
	
	;Calculate our money gained
	moneygain:Set[${moneygain} + ${WoWScript[GetMoney()]} - ${storedmoney}]
	storedmoney:Set[${WoWScript[GetMoney()]}] 
}


;+-----------------------------------------------------------------------------------------------------
;| Name: Skin
;| In: SkinGUID - The GUID of the Unit to skin
;| Returns: none
;| Description: Skins and loots the Unit specified by SkinGUID
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Skin(string SkinGUID)
{
  do
  {
		call UpdateHudStatus "Skinning ${SkinGUID}"
		;Hold down shift so that we loot all one skinning has finished.
		press -hold SHIFT
		waitframe
		;Use the target to loot it.
		Unit[${SkinGUID}]:Use
		wait 15
		wait 40 !${Me.Casting}
		;Release the shift key
		press -release SHIFT
  }
  while ${Unit[${LootGUID}](exists)}&&${Unit[${LootGUID}].Skinnable}&&!${Me.InCombat}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: FindChest
;| In: none
;| Returns: none
;| Description: Searches for a chest, mines, herbs etc
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function FindChest()
{
	declare Index int 1
	declare ChestList guidlist local
	declare ChestGUID string local
	declare RangeMod float local 1

	call UpdateHudStatus "Look for GameObjects"
		;Use the object search to find all nearby lootable Chests
	
	debug("FindChest: DistPointLine ${Me.X} ${Me.Y} ${LastWaypointX} ${LastWaypointY} ${CurrentWaypointX} ${CurrentWaypointY}")
	call DistPointLine ${Me.X} ${Me.Y} ${LastWaypointX} ${LastWaypointY} ${CurrentWaypointX} ${CurrentWaypointY}
	debug("FindChest: ${Return} ${MaxRoam}")
	;Set the range to search for based upon our distance from the path
	if ${Return}>0 && ${Return}<${MaxRoam}
	  RangeMod:Set[${MaxRoam}-${Return}]
	debug("FindChest: ChestList:Search[-gameobjects,-chest,-usable,-unlocked,-nearest,-range 0-${RangeMod}]")   
	ChestList:Search[-gameobjects,-chest,-usable,-unlocked,-nearest,-range 0-${RangeMod}]
	if ${ChestList.Count}
	{
		do
		{
			ChestGUID:Set[${ChestList.GUID[${Index}]}]
			;Make sure we have actualy found something to loot and its not too far off.
			if ${GameObject[${ChestGUID}](exists)} && ${Object[${ChestGUID}].Field[15]} == 1
			{
				debug("FindChest:Found ${GameObject[${ChestGUID}].Name}")
				TargetGUID:Set[${ChestGUID}]
				NoObjectCount:Set[0]
				return
			}
		}
		while ${Index:Inc}<=${ChestList.Count}&&!${Me.InCombat}

	}

	;If we didnt find anything report it
	NoObjectCount:Inc
	debug("No Objects found (${NoObjectCount})")
	return "NOTARGET"		
}

;+-----------------------------------------------------------------------------------------------------
;| Name: FindTarget
;| In: none
;| Returns: none
;| Description: Searches for a target attempting to make sure its not too close to aggro any nearby
;|              Units and ensuring you will not run past any Aggro Units
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function FindTarget()
{
	declare indexx int local 1
	declare NearestGUID string local "NOTARGET"
	declare MinLevel int local 1
	declare MaxLevel int local 1
	declare TargetList guidlist local
	declare UnitList guidlist local
	declare Innerindexx int local
	declare BadPull bool local
	declare CompGUID string local
	declare tempdist float local
	declare RangeMod float local 1
			
	call UpdateHudStatus "Acquiring Target...."

	MinLevel:Set[${Me.Level}-${TargetMinLevelDiff}]
	; Make sure we dont try looking for negative level units
	if ${MinLevel}<0
	{
		MinLevel:Set[1]
	}
	MaxLevel:Set[${Me.Level}+${TargetMaxLevelDiff}]
	
	;Check how far we are from our path
	call DistPointLine ${Me.X} ${Me.Y} ${LastWaypointX} ${LastWaypointY} ${CurrentWaypointX} ${CurrentWaypointY}
	;Set the range to search for based upon our distance from the path
	if ${Return}>0 && ${Return}<${MaxRoam}
  RangeMod:Set[${TargetingRange}-${Return}]

	;Find a target using the object search
	debug("FindTarget: Targeting range ${RangeMod}")
	TargetList:Search[-players,-units,-hostile,-levels ${MinLevel}-${MaxLevel},-nearest,-nopets,-noelite,-alive,-untapped,-lineofsight,-range 0-${RangeMod}]   
	;Check we have found something
	if !${TargetList.Count}
	{
		;If we didnt find anything report it
		NoTargetCount:Inc
		;echo "No targets found (${NoTargetCount})"
		return "NOTARGET"
	  if !${Me.InCombat}&&(${Me.PctMana}<${MinManaPct})||(${Me.PctHPs}<${MinHealthPct})
	  {
		  ;sometimes lag will cause us to be in this routine when we are not ready`
	    call UpdateHudStatus "HP or Mana Low... aborting FindTarget"
	    DoDowntime:Set[TRUE]
		  Return
	  }	
	}
	else
	{
		debug("FindTarget:${TargetList.Count} Potential Targets")
		;Generate a list of all units nearby to compare with
		UnitList:Search[-units,-hostile,-lineofsight,-nearest,-nopets,-alive,-untapped,-range 0-${Math.Calc[${MaxRoam}+${ObjectAssistRadius}]}]
		debug("FindTarget:${UnitList.Count} potential Adds")
		;Loop around each Unit found from the object search
		do
		{
			; Here we compare the current Unit to all the other Units we found
			Innerindexx:Set[1]
			BadPull:Set[FALSE]
			do
			{
				debug("FindTarget:${Object[${TargetList.GUID[${indexx}]}].Name} at distance ${Object[${TargetList.GUID[${indexx}]}].Distance}")
				; Check if we dont want critters
				if ${NoCritters}&&${Unit[${TargetList.GUID[${indexx}]}].CreatureType.Equal[Critter]}
				{
					echo "FindTarget:${Unit[${TargetList.GUID[${indexx}]}].Name} is a critter ignoring"
					BadPull:Set[TRUE]
				}
   			; Check its not one of our units (pet, totems etc)
				if ${Unit[${TargetList.GUID[${indexx}]}].Mine}
				{
					echo "FindTarget:${Object[${TargetList.GUID[${indexx}]}].Name} is mine ignoring"
					BadPull:Set[TRUE]
				}
				;Check its not to far above or below us
				if ${Math.Distance[${Object[${TargetList.GUID[${indexx}]}].Z},${Me.Z}]}>10
				{
					echo "FindTarget:${Object[${TargetList.GUID[${indexx}]}].Name} is too far above or below us"
					BadPull:Set[TRUE]
				}
				; Check Blacklist
				if ${GUIDBlacklist.Element[${TargetList.GUID[${indexx}]}](exists)}
				{
					echo "FindTarget:${TargetList.GUID[${indexx}]} is blacklisted"
					BadPull:Set[TRUE]
				}
				; Only compare if we have 2 different Units and we are doing complex targeting
				CompGUID:Set[${TargetList.GUID[${indexx}]}]
				debug("Comparing FindTarget:${CompGUID} to ${UnitList.GUID[${Innerindexx}]}")
				if ${CompGUID.NotEqual[${UnitList.GUID[${Innerindexx}]}]} && ${ComplexTargeting} && ${UnitList.GUID.NotEqual[NULL]}
				{
					tempdist:Set[${Object[${TargetList.GUID[${indexx}]}].Distance}]
					; Check if the 2 Units are social
					echo "FindTarget:Checking if ${TargetList.GUID[${indexx}]} is friendly to ${UnitList.GUID[${Innerindexx}]}"
					if ${Object[${TargetList.GUID[${indexx}]}].CanCooperate[${UnitList.GUID[${Innerindexx}]}]}
					{
						; Since they are social lets check if they are near to each other		
						if (${Math.Distance[${Object[${TargetList.GUID[${indexx}]}].X},${Object[${TargetList.GUID[${indexx}]}].Y},${Object[${UnitList.GUID[${Innerindexx}]}].X},${Object[${UnitList.GUID[${Innerindexx}]}].Y}]}<${ObjectAssistRadius})
						{
							BadPull:Set[TRUE]
							;debug("FindTarget:${Object[${TargetList.GUID[${indexx}]}].Name} will probably assist ${Object[${UnitList.GUID[${Innerindexx}]}].Name}")
						}
					}
					
					; Check if I run past a unit to this unit
					if (${Object[${TargetList.GUID[${indexx}]}].Distance}>${Object[${UnitList.GUID[${Innerindexx}]}].Distance})&&(${Me.WillCollide[${Me.HeadingTo[${Object[${TargetList.GUID[${indexx}]}].X},${Object[${TargetList.GUID[${indexx}]}].Y}]},${Object[${UnitList.GUID[${Innerindexx}]}].X},${Object[${UnitList.GUID[${Innerindexx}]}].Y},20]})
					{
						echo "FindTarget:Will collide with ${Object[${UnitList.GUID[${Innerindexx}]}].Name} ${UnitList.GUID[${Innerindexx}]}"
						if ${Object[${TargetList.GUID[${indexx}]}].ReactionLevel}<3
						{
							echo "FindTarget:And he dont like me"
							BadPull:Set[TRUE]
						}
					}
				}
			}
			while ${Innerindexx:Inc}<=${UnitList.Count}&&!${BadPull}
			; If the current Units has no aggro friends nearby or we dont have to run past
			; an aggro Unit to got it it should be a good target check if its nearer than
			; our current good target.
			if !${BadPull}
			{
				NearestGUID:Set[${TargetList.GUID[${indexx}]}]
				echo "FindTarget: Target:${Object[${TargetList.GUID[${indexx}]}].Name} Distance:${Object[${TargetList.GUID[${indexx}]}].Distance}"
			}
		}
		while ${indexx:Inc}<=${TargetList.Count}&&${BadPull}
		;We should have checked every Unit now so make sure we still have a valid target
		debug("Object[nearestGUID]: ${Object[${NearestGUID}].Name} ${Object[${NearestGUID}](exists)}")
		if ${Object[${NearestGUID}](exists)}
		{
			call UpdateHudStatus "${Object["${NearestGUID}"].Name} ${NearestGUID} Selected"
			NoTargetCount:Set[0]
			debug("Target:Set[${Object["${NearestGUID}"].Name}]")
			TargetGUID:Set[${NearestGUID}]
		}
		else
		{
			;debug("No Target Found (${NoTargetCount})")
			NoTargetCount:Inc
		}
	}
}


;+-----------------------------------------------------------------------------------------------------
;| Name: Eat
;| In: none
;| Returns: none
;| Description: Loops through the Food section of FoodNDrink.xml and Eats the first food item found
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Eat()
{
	declare Count int 1
	SettingXML[${FoodNDrinkSettingFile}]:Unload
	do
	{
		if ${Item[${SettingXML[${FoodNDrinkSettingFile}].Set[Food].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Food].Key[${Count}]}]}](exists)}
		{
			call UpdateHudStatus "Eating ${SettingXML[${FoodNDrinkSettingFile}].Set[Food].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Food].Key[${Count}]}]}"
			Item[${SettingXML[${FoodNDrinkSettingFile}].Set[Food].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Food].Key[${Count}]}]},-Inventory]:Use
			break
		}
	}
	while ${Count:Inc}<=${SettingXML[${FoodNDrinkSettingFile}].Set[Food].Keys}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Drink
;| In: none
;| Returns: none
;| Description: Loops through the Drink section of FoodNDrink.xml and Drinks the first drink item found
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Drink()
{
	declare Count int 1
	SettingXML[${FoodNDrinkSettingFile}]:Unload
	do
	{
		if ${Item[${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].Key[${Count}]}]}](exists)}
		{
			call UpdateHudStatus "Drinking ${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].Key[${Count}]}]}"
			Item[${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].GetString[${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].Key[${Count}]}]},-Inventory]:Use
			break
		}
	}
	while ${Count:Inc}<=${SettingXML[${FoodNDrinkSettingFile}].Set[Drink].Keys}
}


;+-----------------------------------------------------------------------------------------------------
;| Name: Sell
;| In: none
;| Returns: none
;| Description: Targets the nearest vendor that can also repair. Then loops through your inventory
;|              selling items that are listed in the Sell section of InventoryManagement.xml
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Sell()
{
	declare Bags int local 0
	declare Slots int local 0
	declare Vendor guidlist local
	declare Count int 1
	
	;Unload the setting to ensure we are getting a fresh copy
	SettingXML[${InventorySettingFile}]:Unload
	
	; Do an objects search and find the nearest merchant Unit
	if ${AutoRepair}
	{
		Vendor:Search[-units,-merchant,-repair,-nearest]
	}
	else
	{
		Vendor:Search[-units,-merchant,-nearest]
	}
	
	; If we dont find a vendor disable selling and exit.
	if ${Vendor.Count}<1
	{
		AutoSell:Set[FALSE]
		AutoRepair:Set[FALSE]
		Return
	}
	;Make sure we are close enough
	call movetoobject ${Vendor.GUID[1]} 5
	
	;Use the target to open the merchant window
	Unit[${Vendor.GUID[1]}]:Use

	;Wait for the vendor window to open.
	wait 400 ${WoWScript[MerchantFrame:IsShown()]}

	;If we are auto selling then sell
	if ${AutoSell}
	{
		;Loop through our inventory and sell if required 
		do
		{
			Slots:Set[1]
			do
			{
				if ${Me.Bag[${Bags}].Item[${Slots}](exists)}&&!${WoWBotInv.IsInKeep[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
				{
					if (${WoWBotInv.IsInSell[${Me.Bag[${Bags}].Item[${Slots}].Name}]}&&${SellByName})||(${SellByRarity} && ${Me.Bag[${Bags}].Item[${Slots}].Rarity}<=${SellByRarityLevel})
					{
						call UpdateHudStatus "Selling ${Me.Bag[${Bags}].Item[${Slots}]}"
						Me.Bag[${Bags}].Item[${Slots}]:Use
						wait 20
					}

				}
			}
			while ${Slots:Inc}<=${Me.Bag[${Bags}].Slots}&&!${Me.InCombat}
		}
		while ${Me.Bag[${Bags:Inc}](exists)}&&!${Me.InCombat}
	}
	
	;Repair all our gear
	WoWScript RepairAllItems()
	wait 20
	
	;Calculate our money gained
	moneygain:Set[${moneygain} + ${WoWScript[GetMoney()]} - ${storedmoney}]
	storedmoney:Set[${WoWScript[GetMoney()]}] 

	; Check we are not still full if so disable selling
	if ${Me.EmptyInventorySlots}-${KeepEmpty}<1
	{
		AutoSell:Set[FALSE]
	}

	;All done carry on.
	AtMerchant:Set[FALSE]
	NeedRepair:Set[FALSE]
	TravelState:Set[PATROLING]
	TargetGUID:Set[NOTARGET]
	ForcedSell:Set[FALSE]
	checkinv
}

;+-----------------------------------------------------------------------------------------------------
;| Name: CleanInventory
;| In: none
;| Returns: none
;| Description: Loops through your inventory deleting items that are listed in the Destroy section 
;|              of InventoryManagement.xml
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function CleanInventory()
{
	declare Bags int local 0
	declare Slots int local 0
	declare Count int 1
	
	;Unload the setting to ensure we are getting a fresh copy
	SettingXML[${InventorySettingFile}]:Unload
	
	call UpdateHudStatus "Cleaning Inventory"
	
	;Loop through our inventory and delete if required 
	do
	{
		Slots:Set[1]
		do
		{
			if ${Me.Bag[${Bags}].Item[${Slots}](exists)}&&!${WoWBotInv.IsInKeep[${Me.Bag[${Bags}].Item[${Slots}].Name}]}&&!${WoWBotInv.IsInSell[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
			{
				if (${WoWBotInv.IsInDestroy[${Me.Bag[${Bags}].Item[${Slots}].Name}]}&&${DestroyByName})||(${Me.Bag[${Bags}].Item[${Slots}].Rarity}<=${DestroyByRarityLevel}&&${DestroyByRarity})
				{
					call UpdateHudStatus "Deleting ${Me.Bag[${Bags}].Item[${Slots}]} in ${Bags}:${Slots}"
					Me.Bag[${Bags}].Item[${Slots}]:PickUp
					wait 10
					CursorItem:Delete
					wait 10
				}
			}
			if ${Me.Bag[${Bags}].Item[${Slots}](exists)}&&${WoWBotInv.IsInOpen[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
			{
				call UpdateHudStatus "Opening ${Me.Bag[${Bags}].Item[${Slots}]} in ${Bags}:${Slots}"
				press -hold SHIFT
				wait 10
				Me.Bag[${Bags}].Item[${Slots}]:Use
				wait 10
				press -Release SHIFT
			}
		}
		while ${Slots:Inc}<=${Me.Bag[${Bags}].Slots}&&!${Me.InCombat}
	}
	while ${Me.Bag[${Bags:Inc}](exists)}&&!${Me.InCombat}
	checkinv
}

;+-----------------------------------------------------------------------------------------------------
;| Name: ReleaseCorpse
;| In: none
;| Returns: none
;| Description: Saves our current location to our config file and then releases our corpse to the
;|              graveyard.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function ReleaseCorpse()
{
	;update death count
	TotalDeaths:Inc
	;reset our fleeing state and target
	RLG:Set[FALSE]
	TargetGUID:Set[NOTARGET]
	;wait a few seconds then release out spirit
	wait 30
	WoWScript RepopMe()
	; wait to give us time to pop in the graveyard
	wait 50
}

;+-----------------------------------------------------------------------------------------------------
;| Name: RessurectMe
;| In: none
;| Returns: none
;| Description: Makes sure we are close enough tou our corpse to resurrect then ressurects us.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function RessurectMe()
{
	;If our path didnt take us close enough then run closer
	call UpdateHudStatus "Moving to my corpse at ${Me.Corpse.X} ${Me.Corpse.Y}"
	call moveto ${Me.Corpse.X} ${Me.Corpse.Y} 35

	;Move to a safe spot
	call MoveToSafeSpot
	; Wait for a few seconds
	wait 30
	
	;Rez ourselves
	WoWScript RetrieveCorpse()
	wait 30

	; Check durability
	call CheckDurability

	DoCombatPrep:Set[TRUE]
	DoDowntime:Set[TRUE]
}

;+-----------------------------------------------------------------------------------------------------
;| Name: LootChest
;| In: none
;| Returns: none
;| Description: Finds any nearby usable gameobjects and loots them.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function LootChest(string ChestGUID)
{

	call UpdateHudStatus "Looting ${GameObject[${ChestGUID}].Name}"
	;Make sure we are close enough to loot it
	call movetoobject ${ChestGUID} 5

	while ${Object[${ChestGUID}](exists)}&&!${Me.InCombat}&&(${Me.EmptyInventorySlots}-${KeepEmpty})>0
	{
		;Hold down shift so that we loot all.
		press -hold SHIFT
		waitframe
		;Use the target to loot it.
		Object[${ChestGUID}]:Use
		wait 40 ${WoWScript[LootFrame:IsShown()]}
		wait 20 !${WoWScript[LootFrame:IsShown()]}
		;Release the shift key
		press -release SHIFT
	}
	wait 10
	; Clear target
	TargetGUID:Set[NOTARGET]
	
	; Clean out our Inventory
	if ${AutoDestroy}
	{
		call CleanInventory
	}
	
	;Calculate our money gained
	moneygain:Set[${moneygain} + ${WoWScript[GetMoney()]} - ${storedmoney}]
	storedmoney:Set[${WoWScript[GetMoney()]}] 
}
