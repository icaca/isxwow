#define VERSION Alpha12a

;Check to see if ISXWoW has loaded.
#if !${InnerSpace:LoadExtension[isxwow](exists)}
#error ISXWoW is required but could not be loaded
#endif

;Check we have a character loaded
#if !${Me(exists)}
#error Please have a character loaded before running WoWBot
#endif


;Defines for Travel State
#define PATROLING 0
#define ADVANCING 1
#define SELLING 2
#define FLEEING 3
#define CR 4
#define SKIRMISH

;Define for waypoint precision
#define WPPRECISION 4

#include ./core/Debug.iss
#includeoptional "${ISXWoW.RealmName.Replace}/${Me.Name}/Routines.iss"
#include ./core/moveto.iss
#include ./core/inventory.iss
#include ./core/Sorter.iss
#include ./core/misc.iss
#include ./core/HudStat.iss
#include ./core/Settings.iss
#include ./core/spell.iss
#include ./core/navigation.iss
#include ./core/uibits.iss
#include ./core/Whisper.iss



;Determine State funtion
function DetermineState()
{
	declare NearestPatrolPointIndex int local
	declare HotList guidlist local
	HotList:Search[-players,-units,-targetingme,-levels ${MinLevel}-${MaxLevel},-nearest,-nopets,-noelite,-alive,-untapped,-lineofsight,-range 0-50]   
	;debug("DetermineState:Checking State")
  ;debug("Dead: ${Me.Dead}")
  ;debug("Ghost: ${Me.Ghost}")
  ;debug("Combat: ${Me.InCombat}")
  ;debug("Hotlist.Count: ${Hotlist.Count}")
  ;debug("FalseAgro: ${FalseAggro}")
	if ${Me.Dead}
	{
		Return "DEAD"
	}

	if ${Me.Ghost} && ${TravelState}!=CR
	{
		Return "GHOST"
	}
	
	if ${RLG}
	{
		Return "FALLBACK"
	}
	
	; If I am in combat but not attacking find aggro mob
	if ${Me.InCombat} && (${TargetGUID.Equal[NOTARGET]} || ${Object[${TargetGUID}].Dead}) && ${HotList.Count}
	{
		Return "AGGROED"
	}

	; Check I am not dead and not a ghost and if neither then do downtime.
	if !${Me.Dead}&&!${Me.Ghost}&&${DoDowntime}&&!${Me.InCombat}&&!${HotList.Count}
	{
		wowpress -release moveforward
		Return "DOWNTIME"
	}

	;If our inventory is full we need to head back to town.
	call CheckInventory
	if ((!${Me.InCombat}||${FalseAggro})&&${TravelState}!=SELLING&&${TravelState}!=CR&&((${AutoSell}&&${Return}<1)||(${AutoRepair}&&${NeedRepair})))||${ForcedSell}
	{
		Return "RESUPPLY"
	}
	
	;If not patroling and close to the merchant point sell
	if (!${Me.InCombat}||${FalseAggro})&&${AtMerchant}&&${AutoSell}
	{
		Return "SELL"
	}

	; If I have target that is dead loot it.
	if ${Object[${TargetGUID}].Dead} && (!${Me.InCombat} || ${FalseAggro} || !${Me.Dead} || !${Me.Ghost}) && ${DoLooting}
	{
		Return "LOOT"
	}

	;If I am patroling but too far from my patrol path then plot a route to it
	NearestPatrolPointIndex:Set[${PatrolPath.NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
	if (!${Me.InCombat}||${FalseAggro}) && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${PatrolPath.Point[${NearestPatrolPointIndex}].X},${PatrolPath.Point[${NearestPatrolPointIndex}].Y},${PatrolPath.Point[${NearestPatrolPointIndex}].Z}]}>${MaxRoam} && ${TravelState}==PATROLING
	{
		Return "ADVANCE"
	}

	;If we have failed to find a unit multiple times or we should be heading somewhere then roam
	if (${TravelState}==PATROLING && ${NoTargetCount}>${NoTargetCountMax} && (!${SearchGameObjects} || ${NoObjectCount}>1))||(${TravelState}>0&&(!${Me.InCombat}||${FalseAggro})&&!(${Object[${TargetGUID}](exists)}&&!${Object[${TargetGUID}].Dead}))||${TravelState}==FLEEING
	{
		Return "ROAM"
	}
	; If I dont have target and I am patroling then find one.
	if ${TargetGUID.Equal[NOTARGET]}&&${TravelState}==PATROLING
	{
		Return "TARGET"
	}
	; If I have a target and havent done it already do combat prep
	if ${Object[${TargetGUID}](exists)}&&!${Object[${TargetGUID}].Dead}&&${DoCombatPrep}&&(!${Me.InCombat}||${FalseAggro})
	{
		Return "COMBATPREP"
	}

	; If I have target then attack it.
	if ${Object[${TargetGUID}](exists)}&&!${Object[${TargetGUID}].Dead}
	{
		Return "ATTACK"
	}

	;If i am not aggroed and I want to check for chest, mines, herbs etc then look for some
	if ${TargetGUID.Equal[NOTARGET]} && ${TravelState}==PATROLING && ${SearchGameObjects} && (!${Me.InCombat}||${FalseAggro}) && !${GameObject[${TargetGUID}](exists)} && ${NoObjectCount}<2
	{
		Return "FINDCHESTS"
	}

	; If I have GameObject target then Loot it.
	if ${GameObject[${TargetGUID}](exists)} && (!${Me.InCombat}||${FalseAggro}) && ${SearchGameObjects}
	{
		Return "LOOTCHEST"
	}

	Return "ROAM"
}


function main()
{
	turbo 1000
	declare TurnedOnAFK bool script	FALSE		/* Used to determine if we turned on AFK so we can turn it back off again when were done */
	declare CharacterName string script ${Me.Name.Replace} /* Your characters name */
	declare Realm string script ${ISXWoW.RealmName.Replace}	/* The Current Realm */
	declare BotState string	global					/* Holds the current state of the bot */
	declare HomeDir filepath script ${Script.CurrentDirectory}	/* Holds the full path to wowbot.iss */
	declare TargetGUID string script "NOTARGET"	/* this is used to hold out current target */
	declare CurrentWaypointIndex int script 1	/* This keeps track of where we are in our Path */
	declare CurrentWaypointX float script ${Me.X}	/* The X location we are currently heading towards */
	declare CurrentWaypointY float script ${Me.Y}	/* The Y location we are currently heading towards */
	declare CurrentWaypointZ float script ${Me.Z}	/* The Z location we are currently heading towards */
	declare LastWaypointX float script ${Me.X}	/* The last X location we were at */
	declare LastWaypointY float script ${Me.Y}	/* The last Y location we were at */
	declare LastWaypointZ float script ${Me.Z}	/* The last Z location we were at */	
	declare DoDowntime bool script TRUE		/* Flag to control when we do downtime */
	declare DoCombatPrep bool script TRUE	/* Flag to control combat prep */
	declare CurrentPath string script PatrolPath		/* This variable hold the name of the current path you are following */
	declare MaxRoam int script 20			/* Maximum Distance to roam from waypoint and distance to search for mobs */.
	declare NoTargetCount int script 1		/* Count for the number of times you fail to get a target */
	declare NoObjectCount int script 0		/* Count for the number of times you fail to find an Object */
	declare RLG bool script				/* Flag for running like a girl */
	declare NoTargetCountMax int script 0		/* The number of times you search for a target before giving up and moving on */
	declare SitWhenRest bool script 1		/* Do you want to sit down when resting */
	declare MinHealthPct int script 50		/* The minimum percentage value your health can be before you start to rest*/
	declare MinManaPct int script 80		/* The minimum percentage value your mana can be before you start to rest */
	declare DoSkinning bool script FALSE		/* Do you wan to skin or not */
	declare SearchGameObjects bool script FALSE		/* Do you want to search for chests, mines, herbs, etc whilst roaming */
	declare ComplexTargeting bool global TRUE		/* Do you want to check for possible proximity aggro etc when selecting a target*/
	declare KeepEmpty int script 0			/* The number of bag slots you want to keep empty (Hunters can add the number of slot in there ammo pouch here  */
	declare CombatBailout int script 30		/* How long to run attack routine before giving up */
	declare CombatMaxDist float script 5		/* The maximum distance to the mob for melee (used for combat positioning) */
	declare CombatMinDist float script 1		/* The minimum distance to the mob for melee (used for combat positioning) */
	declare RangedMaxDist float script 35		/* The maximum distance to the mob for ranged (used for combat positioning) */
	declare RangedMinDist float script 11		/* The minimum distance to the mob for ranged (used for combat positioning) */
	declare TargetMinLevelDiff int script 5		/* The targeting routine will target mobs no less then this number lower than your current level */
	declare TargetMaxLevelDiff int script 2		/* The targeting routine will target mobs no higher then this number above your current level */
	declare NoCritters bool script TRUE			/* Do we want to avoid targeting critters */
	declare PullBeforeContinue bool script TRUE			/* Do we want to make sure we have pulled before casting other spells. */
	declare TargetingRange float script 50		/* Target the mob once its closer than this distance */
	declare PullingRange float script 28		/* Execute the pull routine once the mob is closer than this distance */
	declare PanicThreshold int script 5		/* If we have this many aggro mobs on us then run like a girl to the start of our path*/
	declare UnitAssistRadius int script 15	/* The range that is used when checking how close units that assist are */
	declare SettingFile filepath script "${HomeDir}/${Realm}/${CharacterName}/WoWBot_${CharacterName}.xml" /* Name of the configuration file to use*/
	declare FoodNDrinkSettingFile filepath script "${HomeDir}/${Realm}/${CharacterName}/FoodNDrink.xml" /* Name of the configuration file to use*/
	declare InventorySettingFile filepath script "${HomeDir}/${Realm}/${CharacterName}/InventoryManagement.xml" /* Name of the configuration file to use*/
	declare PathFile string global "${HomeDir}/Pathfiles/WoWBotPath_${CharacterName}_${WoWScript[GetRealZoneText()]}.xml" /* Name of the Path file to use*/
	declare World string global "WoWBot"		/* This is the name of the world within the navigation file */
	declare GraveyardPoint string script		/* This is the name of the waypoint to the graveyard */
	declare SafePoint string script			/* This is the name of a safe waypoint to flee too */
	declare PatrolStartPoint string script			/* This is the name of a start point of our patrol path */
	declare MerchantPoint string script			/* This is the name of a Merchant waypoint */
	declare PatrolWaypoints string script			/* This variable holds a comma seperated list of waypoints used to generate the Patrol Route path*/
	declare PatrolPath navpath script			/* This variable hold our patrol navigation path */
	declare TravelingPath navpath script			/* This variable will be used to generate path for moving to and from the Patrol Path */ 
	declare TempPath navpath script				/* Var for temporary paths.*/
	declare CorpseX float script				/* This is the X loc of our corpse */
	declare CorpseY float script				/* This is the Y loc of our corpse */
	declare CorpseZ float script				/* This is the Z loc of our corpse */
	declare ShowStats bool script FALSE			/* Toggle for WoWBot Report display */
	declare ShowStatus bool script TRUE			/* Toggle for WoWBot running status display */
	declare CurrentXP int global ${Me.Exp}			/* Starting XP */
	declare TotalKills int global 0				/* Count of mobs we kill */
	declare TotalDeaths int global 0			/* Count of times we have died */
	declare TotalXPGained int global 0			/* Total XP gained this session */
	declare XPToLevel int global ${Math.Calc[${Me.NextLevelExp}-${Me.Exp}]}	/* amount of XP needed to gt the next level */
	declare XPSec float global 0				/* XP per second */
	declare TimeNextLevel float global 0			/* Estimated Seconds until next level */
	declare GUIDBlacklist collection:string script		/* Blacklist of bad GUIDs */
	declare Skirmish bool script TRUE			/* Do we want to search for targets whilst running between patrol points */
	declare AtMerchant bool script FALSE			/* Used to decide if we are at a merchant or not */
	declare NeedRepair bool script FALSE			/* Used to decide if we need to repair or not */
	declare TravelState int script 0			/* Used to keep track of what type of path we are on. */
	declare UseFaceFast bool script FALSE			/* Set this to TRUE if you want to use face -fast */
	declare LoopPatrolPath bool global FALSE		/* If set to tru then when you reach the end of your patrol path you will walk to the start directly instead of reversing path */
	declare AutoSell bool script TRUE			/* Do you want wowbot to auto sell */
	declare ForcedSell bool script FALSE			/*A variable for forced selling
	declare AutoRepair bool script TRUE			/* Do you want wowbot to auto repair */
	declare AutoDestroy bool script TRUE			/* Do you want wowbot to auto destroy */
	declare RepairPctLevel int script 20			/* The minimum pct durabilty before we go to repair */
	declare SellByName bool script TRUE			/* Do you want to sell items out of your inventory by name ?*/
	declare SellByRarity bool script FALSE			/* Do you want to sell items out of your inventory by name ?*/
	declare DestroyByName bool script TRUE			/* Do you want to sell items out of your inventory by name ?*/
	declare DestroyByRarity bool script FALSE		/* Do you want to sell items out of your inventory by name ?*/
	declare DestroyByRarityLevel int script -1		/* Destroy items that are less than this quality level */
	declare SellByRarityLevel int script -1			/* Sell items that are less than this quality level */
	declare moneygain int global 0            		/* Holds the total copper gained from the money loot */
	declare storedmoney int script ${WoWScript[GetMoney()]} /* Holds the amount of cash you have after each kill */	
	declare FalseAggro bool script FALSE			/* Flag to deal with false aggro */
	declare FalseAggroTimer int script 0			/* Timer to deal with false aggro */
	declare LogoutTimer int global				/* Logout Timer */
	declare LogoutTimerStartTime int global			/* Logout Timer Start Time */
	declare ReceivedWhispers int global			/* Whispers received */
	declare StartTime string global "${Time.Hour}.${Time.Minute} ${Time.Month}-${Time.Day}-${Time.Year}"
	declare WoWBotInv WoWBotInventory global "${HomeDir}/${Realm}/${CharacterName}/InventoryManagement.xml"
	declare TAUNT int global 0

	WoWBotInv:Load["${HomeDir}/${Realm}/${CharacterName}/InventoryManagement.xml"]
	call LoadSettings
	ui -load "${HomeDir}/interface/wowskin.xml"
	call SetupHudStatus
	call CreateDirectories
	call SetDebugFile "${HomeDir}/${Realm}/${CharacterName}/WoWBot.log"
	call UpdateHudStatus "Stared WoWBot VERSION"
	call UpdateHudStatus "${CharacterName} on Realm ${Realm}"
	run "${HomeDir}/core/wowbotwaypoints"
	ui -load "${HomeDir}/interface/wowbotui.xml"
	bind WoWBotDisplay SHIFT+ALT+W "UIElement -toggle wowbot"
	call InitNavigation
	call UpdateHudStatus "Loaded ${CharacterName} specific routines"
	
	checkinv

	Redirect "${Realm}/${CharacterName}/Logs/${StartTime}.txt" Echo "Log Started"
	AddTrigger AddWhisper "[Event:@eventid@:CHAT_MSG_WHISPER](\"@message@\",\"@speaker@\",\"@language@\",\"@something@\",\"@something@\",\"@something@\",@something@,@something@,\"@something@\",@something@)"	
	AddTrigger AddWhisper "[Event:@eventid@:CHAT_MSG_SAY](\"@message@\",\"@speaker@\",\"@language@\",\"@something@\",\"@something@\",\"@something@\",@something@,@something@,\"@something@\",@something@)"	
	

;	Script[WoWBot]:Pause
	
	While ${BotState.NotEqual[END]}
	{
		;Reset our False Aggro Flag
		if ${FalseAggro}&&${Script.RunningTime}>${FalseAggroTimer}
		 FalseAggro:Set[FALSE]

		; Check what we are supposed to be doing
		call DetermineState
		
		BotState:Set[${Return}]
		;debug("Main:${BotState}")

		; Check to see if we should Hearth and Logout		
		call LogoutTimerFunction

		; Act on our current state
		Switch ${BotState}
		{
			case DEAD
				call UpdateHudStatus "Entered ${BotState} State"
				wowpress moveforward
				wowpress moveback
				waitframe
				wowpress -release moveforward
				wowpress -release moveback
				call ReleaseCorpse
				do 
				{
				  debug("I'm dead, but not a ghost?!")
				  move -stop
				  wait 15
				  call DetermineState
				  if ${Me.Ghost}
				    break
				}
				while !${Me.Ghost} && ${Me.Dead}
				break

			case GHOST
				call UpdateHudStatus "Entered ${BotState} State"
				wait 25
				if ${WoWScript[GetBattlefieldInstanceRunTime()]}
				{
				  do
				  {
   				  move -stop
				    wait 5
				  }
				  while ${Me.Ghost}
				  call SetAdvancePath
				}
				else
				{
				  call SetCorpseRunPath
				}
				break
				
			case FALLBACK
				call UpdateHudStatus "Entered ${BotState} State"
				call FallBack
				break
				
			case AGGROED
				call UpdateHudStatus "Entered ${BotState} State"
				call CheckAggro
				break
				
			case DOWNTIME
				call UpdateHudStatus "Entered ${BotState} State"
				move -stop
				call Downtime
				break

			case COMBATPREP
				call UpdateHudStatus "Entered ${BotState} State"
				call CombatPrep
				break

			case FINDCHESTS
				call UpdateHudStatus "Entered ${BotState} State"
				call FindChest
				break

			case LOOTCHEST
				call UpdateHudStatus "Entered ${BotState} State"
				call LootChest ${TargetGUID}
				break

			case TARGET
				call UpdateHudStatus "Entered ${BotState} State"
				call FindTarget
				break

			case GOHOME
				call UpdateHudStatus "Entered ${BotState} State"
				call GoHome
				break

			case ATTACK
				call UpdateHudStatus "Entered ${BotState} State"
				call Attack ${TargetGUID}
				break

			case LOOT
				call UpdateHudStatus "Entered ${BotState} State"
				call Loot ${TargetGUID}
				break
			
			case ROAM
				call UpdateHudStatus "Entered ${BotState} State"
				call Roam
				break
				
			case RESUPPLY
				ForcedSell:Set[FALSE]
				call UpdateHudStatus "Entered ${BotState} State"
				call SetMerchantPath
				break

			case ADVANCE
				call UpdateHudStatus "Entered ${BotState} State"
				call SetAdvancePath
				break

			case SELL
				call UpdateHudStatus "Entered ${BotState} State"
				call Sell
				break

			case END
				call UpdateHudStatus "Entered ${BotState} State"
				break
		}
	}

}

function atexit()
{
	; Dump our running stats to the console.
	call DumpStats
	; Clean up if the script is ended
	press -release SHIFT
	wowpress -release moveforward
	wowpress -release movebackward
	if ${Script[WoWBotWaypoints](exists)}
	{
		EndScript WoWBotWaypoints
	}
	if ${TurnedOnAFK}
	{
		;debug("atexit:Turned off AFK")
		AntiAfk off
	}

	ui -unload "${HomeDir}/interface/wowbotui.xml"
	bind -delete WoWBotDisplay

}



function LogoutTimerFunction()
{
	if ${LogoutTimer}!=0 && ${Script.RunningTime}>=${Math.Calc[(${LogoutTimerStartTime})+((${LogoutTimer})*1000)]}
	{
		press -release SHIFT
		wowpress -release moveforward
		wowpress -release movebackward

		logout
		this:end
	}
}


atom(global) changepath(string NewPath)
{
	PathFile:Set[${HomeDir}/PathFiles/${NewPath.Escape}]
	echo "Attemping Init Nav"
	echo ${NewPath}
	call InitNavigation
}

atom(global) changeoptions(string newHP, string newMP, string newRoam, string newTR, string newPR, string newTMinLD, string newTMaxLD, string newRPL)
{

	TargetingRange:Set[${newTR}]
	RangeMod:Set[${newTR}]
	MaxRoam:Set[${newRoam}]
	MinHealthPct:Set[${newHP}]
	MinManaPct:Set[${newMP}]
	PullingRange:Set[${newPR}]
	RepairPctLevel:Set[${newRPL}]
	TargetMinLevelDiff:Set[${newTMinLD}]
	TargetMaxLevelDiff:Set[${newTMaxLD}]
}

atom(global) newpathnow(string mypath)
{
	RunScript ./core/WoWBotPath ${mypath}
}

atom(global) forcedselling()
{
	ForcedSell:Set[TRUE]
}

atom(global) setoptions(string newHP, string newMP, string newRoam, string newTR, string newPR, string newTMinLD, string newTMaxLD, string newRPL, string newCT, string newLPP)
{
	SettingXML[${SettingFile}].Set[General Options]:Set[MaxRoam,${newRoam}]
	SettingXML[${SettingFile}].Set[General Options]:Set[MinHealthPct,${newHP}]
	SettingXML[${SettingFile}].Set[General Options]:Set[MinManaPct,${newMP}]
	SettingXML[${SettingFile}].Set[Combat Options]:Set[TargettingRange,${newTR}]
	SettingXML[${SettingFile}].Set[Combat Options]:Set[PullingRange,${newPR}]
	SettingXML[${SettingFile}].Set[Combat Options]:Set[TargetMinLevelDiff,${newTMinLD}]
	SettingXML[${SettingFile}].Set[Combat Options]:Set[TargetMaxLevelDiff,${newTMaxLD}]
	SettingXML[${SettingFile}].Set[Inventory Options]:Set[RepairPctLevel,${newRPL}]
	SettingXML[${SettingFile}].Set[General Options]:Set[ComplexTargeting,${ComplexTargeting}]
	SettingXML[${SettingFile}].Set[Pathing Options]:Set[LoopPatrolPath,${LoopPatrolPath}]
	SettingXML[${SettingFile}]:Save
}