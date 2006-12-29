;Settings.iss

function CreateDirectories()
{
	if !${HomeDir.FileExists[${Realm}]}
	{
		mkdir "${HomeDir}/${Realm}"
		debug("CreateDirectories:Creating Directory ${HomeDir}/${Realm}")
		mkdir "${HomeDir}/${Realm}/${CharacterName}"
		debug("CreateDirectories:Creating Directory ${HomeDir}/${Realm}/${CharacterName}")
	}
	
	if !${HomeDir.FileExists[${Realm}/${CharacterName}]}
	{
		mkdir "${HomeDir}/${Realm}/${CharacterName}"
		debug("CreateDirectories:Creating Directory ${HomeDir}/${Realm}/${CharacterName}")
	}
}

function LoadSettings()
{
	Declare FileGenerated bool local FALSE
	;Load or generate config files.

	if !${SettingFile.PathExists}
	{
		call UpdateHudStatus "Generating default configuration files"
		echo "${HomeDir}/${Realm}/${CharacterName}"
		mkdir "${HomeDir}/${Realm}"
		mkdir "${HomeDir}/${Realm}/${CharacterName}"
		SettingXML[${SettingFile}].Set[General Options]:Set[MaxRoam,20]
		SettingXML[${SettingFile}].Set[General Options]:Set[NoTargetCountMax,3]
		SettingXML[${SettingFile}].Set[General Options]:Set[SitWhenRest,1]
		SettingXML[${SettingFile}].Set[General Options]:Set[MinHealthPct,50]
		SettingXML[${SettingFile}].Set[General Options]:Set[MinManaPct,80]
		SettingXML[${SettingFile}].Set[General Options]:Set[DoSkinning,0]
		SettingXML[${SettingFile}].Set[General Options]:Set[SearchGameObjects,0]
		SettingXML[${SettingFile}].Set[General Options]:Set[ComplexTargeting,1]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[CombatBailout,30]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[CombatMaxDist,5]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[CombatMinDist,1]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[RangedMaxDist,35]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[RangedMinDist,11]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[TargetMinLevelDiff,5]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[TargetMaxLevelDiff,2]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[NoCritters,1]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[PullBeforeContinue,1]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[TargetingRange,50]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[PullingRange,25]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[PanicThreshold,5]
		SettingXML[${SettingFile}].Set[Combat Options]:Set[UnitAssistRadius,15]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[Skirmish,1]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[UseFaceFast,0]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[LoopPatrolPath,0]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[PathFile,"${HomeDir}/PathFiles/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[World,"WoWBot"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[GraveyardPoint,"CorpseRun_End"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[SafePoint,"Safe_Point"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[PatrolStartPoint,"Patrol_Start"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[MerchantPoint,"MerchantRun_End"]
		SettingXML[${SettingFile}].Set[Pathing Options]:Set[PatrolWaypoints,"Patrol_Start\\,Patrol_End"]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[KeepEmpty,0]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[AutoSell,1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[AutoRepair,1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[AutoDestroy,1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[RepairPctLevel,20]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[SellByName,1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[SellByRarity,0]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[SellByRarityLevel,-1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[DestroyByName,1]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[DestroyByRarity,0]
		SettingXML[${SettingFile}].Set[Inventory Options]:Set[DestroyByRarityLevel,-1]
		SettingXML[${SettingFile}]:Save
		
		call UpdateHudStatus "${SettingFile} Saved"
		call ShowMessage "New character configuration file created with default settings.\nPlease edit ${SettingFile} to suit before restarting WoWBot."
		FileGenerated:Set[TRUE]
	}

	if !${FoodNDrinkSettingFile.PathExists}
	{

		;Generate Empty FoodNDrink config files
		SettingXML[${FoodNDrinkSettingFile}]:Unload
		SettingXML[${FoodNDrinkSettingFile}].Set[Food]:Set[1,"Add Food Items Here"]		
		SettingXML[${FoodNDrinkSettingFile}].Set[Drink]:Set[1,"Add Drink Items Here"]		
		SettingXML[${FoodNDrinkSettingFile}]:Save

		call UpdateHudStatus "${FoodNDrinkSettingFile} Saved"
		call ShowMessage "New Food and Drink settings file created with default settings.\nPlease edit ${FoodNDrinkSettingFile} to suit before restarting WoWBot."
		FileGenerated:Set[TRUE]
	}

	if !${InventorySettingFile.PathExists}
	{
		;Generate Empty Inventory config files
		SettingXML[${InventorySettingFile}]:Unload
		SettingXML[${InventorySettingFile}]:Save

		call UpdateHudStatus "${InventorySettingFile} Saved"
	}		
	
	
	; See if we have a routines file
	if !${HomeDir.FileExists[${Realm}/${CharacterName}/Routines.iss]}
	{
		
		call ShowMessage "ERROR: No character specific routines found. \nYou will need to copy Routines.iss from the WoWBot directory and \n place it in the ${Realm}/${CharacterName} directory \n and customise it to your needs."
		FileGenerated:Set[TRUE]
	}

	; If we have generated new files or are missing our routines file then end the script.
	if ${FileGenerated}
	{
		Script:End
	}

	call UpdateHudStatus "Loaded configuration file ${SettingFile}"
	SettingXML[${SettingFile}]:Unload

	MaxRoam:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[MaxRoam,20]}]
	NoTargetCountMax:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[NoTargetCountMax,3]}]
	SitWhenRest:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[SitWhenRest,1]}]
	MinHealthPct:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[MinHealthPct,50]}]
	MinManaPct:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[MinManaPct,80]}]
	DoSkinning:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[DoSkinning,0]}]
	SearchGameObjects:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[SearchGameObjects,0]}]
	ComplexTargeting:Set[${SettingXML[${SettingFile}].Set[General Options].GetInt[ComplexTargeting,1]}]
	CombatBailout:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[CombatBailout,30]}]
	CombatMaxDist:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[CombatMaxDist,5]}]
	CombatMinDist:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[CombatMinDist,1]}]
	RangedMaxDist:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[RangedMaxDist,35]}]
	RangedMinDist:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[RangedMinDist,11]}]
	TargetMinLevelDiff:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[TargetMinLevelDiff,5]}]
	TargetMaxLevelDiff:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[TargetMaxLevelDiff,2]}]
	NoCritters:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[NoCritters,1]}]
	PullBeforeContinue:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[PullBeforeContinue,1]}]
	TargetingRange:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[TargetingRange,30]}]
	PullingRange:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[PullingRange,25]}]
	PanicThreshold:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[PanicThreshold,5]}]
	UnitAssistRadius:Set[${SettingXML[${SettingFile}].Set[Combat Options].GetInt[UnitAssistRadius,15]}]
	Skirmish:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetInt[Skirmish,1]}]
	UseFaceFast:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetInt[UseFaceFast,0]}]
	LoopPatrolPath:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetInt[LoopPatrolPath,0]}]
	PathFile:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[PathFile,"${HomeDir}/Pathfiles/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml"]}]
	World:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[World,"WoWBot"]}]
	GraveyardPoint:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[GraveyardPoint,"CorpseRun_End"]}]
	SafePoint:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[SafePoint,"Safe_Point"]}]
	PatrolStartPoint:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[PatrolStartPoint,"Patrol_Start"]}]
	MerchantPoint:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[MerchantPoint,"MerchantRun_End"]}]
	PatrolWaypoints:Set[${SettingXML[${SettingFile}].Set[Pathing Options].GetString[PatrolWaypoints,"Patrol_Start,Patrol_End"]}]	
	KeepEmpty:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[KeepEmpty,0]}]
	AutoSell:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[AutoSell,1]}]
	AutoRepair:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[AutoRepair,1]}]
	AutoDestroy:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[AutoDestroy,1]}]
	RepairPctLevel:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[RepairPctLevel,20]}]
	SellByName:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[SellByName,1]}]
	SellByRarity:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[SellByRarity,0]}]
	SellByRarityLevel:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[SellByRarityLevel,-1]}]
	DestroyByName:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[DestroyByName,1]}]
	DestroyByRarity:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[DestroyByRarity,0]}]
	DestroyByRarityLevel:Set[${SettingXML[${SettingFile}].Set[Inventory Options].GetInt[DestroyByRarityLevel,-1]}]
}