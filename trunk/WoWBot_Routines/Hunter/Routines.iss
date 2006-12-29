/*
---------------------------------------------------------------------------
          iiDD          ttKK##WWLLLLDDDDtt..    ttWW##DDLL  ::GG####LLLL
          ffWW            LL##DD    iiKKKKff      LL##ii      ..WWKK    
          KK##ii          tt##GG      ..KK##jj    tt##..        KKGG    
        ttttKKDD;;        tt##GG        iiEEWW    tt##..        KKGG    
        DD  jj##GG        tt##GG          LL##;;  tt##..        KKGG    
      ;;LL  ..####..      tt##GG          tt##ii  tt##LLLLLLLLLLWWGG    
      DDGGLLLLWW##tt      tt##GG          LL##;;  tt##..        KKGG    
    ::GG      iiEEKK      tt##GG        iiEEWW    tt##..        KKGG    
    tttt      ..LL##..    tt##GG        ffWWGG    tt##..        KKGG    
    DD..        ;;##jj    tt##GG      tt##WW..    tt##..        KKGG    
ttDD##LL      iiGG####LLttWW##WWLLLLDDDDii..    ttWW##DDLL  ::GG####LLLL
---------------------------------------------------------------------------

; Reworked routine from "Project: Awesome Hunter Routine", which was originally created by Etox

; reworked by kras
*/

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES

;Toggleable defines:			/* Commenting out a "Toggleable" define will disable the feature */

#define REVIVE_PET			/* Revive your pet in downtime?*/
#define FOOD_NAME "Roasted Quail"	/* Name of food to feed pet with */
#define MEND_LIMIT 30			/* % Hp limit for Mend Pet in combat */
#define MAX_STUCK 5			/* How many attempts to free yourself when stuck before using heartstone and logout */
#define USE_MARK 			/* Do you want to cast hunters mark when pulling? */
#define USE_SERPENT			/* Do you want to use Serpent Sting? */
;#define USE_WRATH			/* Do you want to use Bestial Wrath? */
;#define USE_SCORPID			/* Do you want to use Scorpid Sting? */
;#define USE_ARCANE 			/* Do you want to use Arcane hots? */
;#define USE_CONCUSSIVE 20		/* Do you want to use Concussive hots on humanoids? If so at what %? */
;#define USE_AIMED_SHOT			/* Do you want to pull with Aimed shot? */
#define USE_MONGOOSE			/* Do you want to use Mongoose Bite? */
;#define SWITCH_MONKEY 			/* Do you want aspect of the monkey when entering melee?(Pure melee not affected)*/
	
;Pure value defines:			/* Just change the values in the following ones */

#define ARROW_NAME "Jagged Arrow"	/* Name of your arrows */
#define FEIGN_LIMIT 10			/* % Hp limit for when to feign death */
#define REVIVE_COST 1540		/* The mana cost of your "Reive Pet" spell */


;
; The CombatPrep function is called once you have selected a target but before you enter combat.
;
function CombatPrep()
{   
	;Reset flag
	DoCombatPrep:Set[FALSE]
}

function Attack(string AttackGUID)
{
   
declare SavX float ${Me.X}
declare SavY float ${Me.Y}
declare SavZ float ${Me.Z}
declare BailOut int ${Math.Calc[${LavishScript.RunningTime}+(1000*${CombatBailout})]}
declare HavePulled bool FALSE
declare StuckCheck bool FALSE
declare StuckCheckTime int
declare HaveArrows guidlist
declare Aggros guidlist
declare AggroCount int 0
declare AggroMe int 0
declare AggroPet int 0
declare AggroGUID string
declare Index int 0
if !${Script[wowbot].Variable[AttackState](exists)}
	declare AttackState string script RANGED
else
	AttackState:Set[RANGED]

if !${Script[wowbot].Variable[EvadeCount](exists)}
	declare EvadeCount int script 0

; Reset the count for evades
EvadeCount:Set[0]

; triggers
addtrigger evade "[Event:@*@:CHAT_MSG_SPELL_SELF_DAMAGE](\"Your @SPELLNAME@ was evaded by @MOB@.@*@"

if ${AttackGUID.Equal[NULL]}||${AttackGUID.Equal[NOTARGET]}
{
	call UpdateHudStatus "No target to attack"
}
  
call UpdateHudStatus "Attacking ${Object[${AttackGUID}].Name}"
  
Do
{
	SavX:Set[${Me.X}]
	SavY:Set[${Me.Y}]
	SavZ:Set[${Me.Z}]

	; Check we still have a valid target
	if !${Unit[${AttackGUID}](exists)}
	{
		call UpdateHudStatus "Target lost"
		TargetGUID:Set[NOTARGET]
		Return
 	}
       
	; Check if the target is engaged already
	if ${Unit[${AttackGUID}].Tapped}
	{
		call UpdateHudStatus "Target already engaged"
		TargetGUID:Set[NOTARGET]
		Return         
 	}
	
	; If we dont have our chosen unit targeted and were in range target it
	if !${Target.GUID.Equal[${AttackGUID}]}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
	{
 		debug(*Routine* Current Target: ${Target.GUID} Targeting Unit: ${Unit[${AttackGUID}].Name}[${AttackGUID}])
 		Target ${AttackGUID}
 		wait 1
	}

	; Ensure we are still facing our target loc
	call SmartFacePrecision ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y}
	
	; Check if we still have ammo
	HaveArrows:Search[-exact,ARROW_NAME]

	; and go pure melee if we don't
	if !${HaveArrows.Count}&&${AttackState.NotEqual[PURE_MELEE]}
	{
		debug(*Routine* We are now out of ammo and wondering why the heck we choosed to bot a hunter)
		AttackState:Set[PURE_MELEE]
	}

	; check if we have pulled, if so do the attack stuff
	if ${HavePulled}
	{
		if !${Me.Pet.Target.GUID.Equal[${AttackGUID}]}
		{
			debug(*Routine* Asking pet to attack)
			wowscript PetAttack()
		}
		switch ${AttackState}
		{
			case RANGED
				
				call Ranged ${AttackGUID}
				if ${Return.Equal[MELEE]}
				{
					Call UpdateHudStatus "Switching to Melee"
					AttackState:Set[MELEE]
				}
				break

			case MELEE

				call Melee ${AttackGUID}
				if ${Return.Equal[RANGED]}
				{
					Call UpdateHudStatus "Switching to Ranged"
					AttackState:Set[RANGED]
				}
				break

			case PURE_MELEE

				call Melee ${AttackGUID}
				break

			default debug(*Routine* We don't have an AttackState)
 		}
	}
	; Else pull if we still have some ammo.
	else
	{
		; Check if another mob aggroed before we pull
		Aggros:Search[-units,-nopets,-nearest,-aggro,-alive,-range 0-40]

		if !${Unit[${AttackGUID}].Aggro}&&${Aggros.Count}>0
		{
			debug(*Routine* The Unit: ${Unit[${Aggros.GUID[1]}].Name}[${Unit[${Aggros.GUID[1]}]}] has aggroed us. Interupting the pulling.)
			TargetGUID:Set[NOTARGET]
			return
		}
		Aggros:Clear

		if ${HaveArrows.Count}&&!${Unit[${AttackGUID}].Aggro}
		{
			call Pull ${AttackGUID}
			if ${Return}
			{
				HavePulled:Set[TRUE]
				continue
			}
		}
		else
		{
			HavePulled:Set[TRUE]
			continue
		}
	}

	;wait for half a second to give our pc a chance to move
	wait 5

	; Stuck checks
	if ${AttackState.Equal[RANGED]}
	{

		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Unit[${AttackGUID}].Distance}>${RangedMaxDist}
		{
			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				debug(*Routine* I might be stuck)
				StuckCheck:Set[TRUE]
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			} 
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>8000
				{
					debug(*Routine* Yep I am stuck trying to free myself)
					call Obstacle
					StuckCheckCount:Inc
					StuckCheck:Set[FALSE]
				}
			}
		}
	}
	elseif ${AttackState.Equal[MELEE]}||${AttackState.Equal[PURE_MELEE]}
	{
		;wait for half a second to give our pc a chance to move
	 	wait 5
       
      		; Check to make sure we have moved if not then try and avoid the
      		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
      		{
        		; I think i might be stuck so save off the current time
        		if !${StuckCheck}
        		{
        			debug(I might be stuck)
            			StuckCheck:Set[TRUE]
            			StuckCheckTime:Set[${LavishScript.RunningTime}]
         		}
         		else
         		{
            			; If I am still stuck after 8 seconds then try and avoid the obstacle.
            			if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>8000
            			{
               				debug(Yep I am stuck trying to free myself)
               				call Obstacle
					StuckCheckCount:Inc
               				StuckCheck:Set[FALSE]
            			}
         		}
  		}
	}

	; If I have moved away from my saved spot reset my stuck toggle
	if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
	{
		debug(*Routine* I am no longer stuck)
		StuckCheck:Set[FALSE]
		StuckCheckCount:Set[0]
	}

	#ifdef MAX_STUCK
	;If I have been stuck too many times then quit.
	if ${StuckCheckCount}>MAX_STUCK
	{
		debug(*Routine* Got stuck to often. Quitting the game)
		call ExitGame
	}
	#endif
		
	; Check if we have exceeded bail out timer and the mob is still at full health
	if ${LavishScript.RunningTime}>${BailOut}&&${Unit[${TargetGUID}].PctHPs}>99
	{
		GUIDBlacklist:Set[${TargetGUID},AVOID]
		call UpdateHudStatus "Combat timeout reached"
		TargetGUID:Set[NOTARGET]
		return
	}

	; Safety things

	; Feign Death if less than FEIGN_LIMIT % HP
	if ${Me.PctHPs}<FEIGN_LIMIT&&${Spell[Feign Death](exists)}&&!${Spell[Feign Death].Cooldown}
 	{
		move -stop
		waitframe
		call UpdateHudStatus "Feigning Death"
		call CastSpell "Feign Death" ${Me.GUID}
		wait 10
		if ${Me.Buff[Feign Death](exists)}
		{
			while ${Me.InCombat}
			{
				wait 10
			}
			; Jump once to break out of fd
			wowpress jump
			wait 10

			;Reset flags to do combat prep and downtime
			DoDowntime:Set[TRUE]
			DoCombatPrep:Set[TRUE]
			return
		}
		else
		{
			debug(*Routine* Feign Death got resisted. Time to flee!)
			RLG:Set[TRUE]
			return
		}
	}

	; Check if we should flee
	AggroMe:Set[0]
	AggroPet:Set[0]
	Index:Set[0]
	Aggros:Search[-units,-nopets,-nearest,-aggro,-alive,-range 0-40]

	; Count the aggros
	while ${Index:Inc}<=${Aggros.Count}
	{
		if ${Unit[${Aggros.GUID[${Index}]}].Target.GUID.Equal[${Me.Pet.GUID}]}
			AggroPet:Inc
		elseif ${Unit[${Aggros.GUID[${Index}]}].Target.GUID.Equal[${Me.GUID}]}
		{
			if !${AggroMe}
				AggroGUID:Set[${Aggros.GUID[1]}]
			AggroMe:Inc
		}
	}
	AggroCount:Set[${AggroPet} + ${AggroMe}]

	if (${AggroCount}>=${Math.Calc[${PanicThreshold}+2]})||(${AggroCount}>${PanicThreshold}&&${Me.PctHPs}<40||!(${Me.Pet.Health}!=0)&&${Me.PctHPs}<40&&${Unit[${AttackGUID}].PctHPs}>30||${Me.Pet.Health}>0&&${AggroPet}&&${AggroMe}&&${Me.PctHPs}<30&&${Unit[${AttackGUID}].PctHPs}>30
	{ 
		debug(*Routine* I have ${AggroCount} Aggro mobs. Time to flee!)
		RLG:Set[TRUE]
		return
	}

	; If there is mob/mobs on us and pet only has one, order him to help out
	if ${AggroMe}&&${AggroPet}==1
	{
		while ${Unit[${AggroGUID}].Target.GUID.NotEqual[${Me.Pet.GUID}]}&&${Me.Pet.Health}!=0
		{
			if !${Target.GUID.Equal[${AggroGUID}]}
			{
				target ${AggroGUID}
				wait 5
			}
			if !${Me.Pet.Target.GUID.Equal[${AggroGUID}]}&&${Me.Pet.Health}!=0
			{
				wowscript PetAttack()
				wait 5
			}
			waitframe
		}
	}
	Aggros:Clear

	if ${QueuedCommands}
		ExecuteQueued evade
}
while !${Unit[${AttackGUID}].Dead}&&!${Me.Dead}

move -stop

; Update stats
if !${Me.Dead}
{
	call UpdateStats
}

wowpress -release movebackward
wowpress -release moveforward

;Reset flags to do combat prep and downtime
DoDowntime:Set[TRUE]
DoCombatPrep:Set[TRUE]

Return
}


function Ranged(string AttackGUID)
{
	if !${Me.Buff[Aspect of the Hawk](exists)}
	{
		call CastOnRun "Aspect of the Hawk"
	}
          
	if !${Me.Action[Auto Shot].AutoRepeat}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist}&&${Unit[${AttackGUID}].Distance}>${RangedMinDist}
	{
		cast "Auto Shot"
	}

	; Check if we are close enough and have mana
	if ${Unit[${AttackGUID}].Distance}<${RangedMaxDist}&&${Unit[${AttackGUID}].Distance}>${RangedMinDist}&&${Me.PctMana}>10
	{
		#ifdef USE_WRATH
		; Cast Bestial Wrath
		if !${Spell[Bestial Wrath].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>20&&!${Unit[${AttackGUID}].Buff[Bestial Wrath](exists)}
		{
			call CastSpell "Bestial Wrath" ${AttackGUID}
		}
		#endif

		#ifdef USE_SERPENT
		; Cast Serpent Sting
		if !${Spell[Serpent Sting].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>20&&!${Unit[${AttackGUID}].Buff[Serpent Sting](exists)}
		{
			call CastSpell "Serpent Sting" ${AttackGUID}
		}
		#endif

		#ifdef USE_SCORPID
		; Cast Scorpid Sting
		if !${Spell[Scorpid Sting].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>20&&!${Unit[${AttackGUID}].Buff[Scorpid Sting](exists)}
		{
			call CastSpell "Scorpid Sting" ${AttackGUID}
		}
		#endif
		
		#ifdef USE_ARCANE
		; Cast Arcane Shot
		if !${Spell[Arcane Shot].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>20
		{
			call CastSpell "Arcane Shot" ${AttackGUID}
		}
		#endif

		#ifdef USE_CONCUSSIVE
		; If Target is humanoid and has Low HP. Cast Slowing Spell
		if !${Spell[Concussive Shot].Cooldown}&&${Unit[${AttackGUID}].CreatureType.Equal[Humanoid]}&&${Unit[${AttackGUID}].PctHPs}<USE_CONCUSSIVE
		{
			call CastSpell "Concussive Shot" ${AttackGUID}
		}
		#endif
	
		#ifdef MEND_LIMIT
		; Mend Pet
		if ${Me.Pet.PctHPs}<MEND_LIMIT&&${Me.Pet.Health}!=0
		{
			call MendPet
		}
		#endif
      	}

 	; If we are to close and the mob has targeted us go into melee
	if ${Unit[${AttackGUID}].Target.GUID.Equal[${Me.GUID}]}&&${Unit[${AttackGUID}].Distance}<${RangedMinDist}
	{
		debug(*Routine* *Switching to Melee* Mobs target: ${Unit[${AttackGUID}].Target.GUID} Me: ${Me.GUID} Distance: ${Unit[${AttackGUID}].Distance}<${RangedMinDist})
		return MELEE
	}
			
	; Else run backward
	if ${Unit[${AttackGUID}].Distance}<${RangedMinDist}
	{
		debug(*Routine* To close for ranged attacks. Backing)
		;press and hold the backward button
		wowpress -release moveforward
		wowpress -hold movebackward
	}     


	;If too far away run forward
	if ${Unit[${AttackGUID}].Distance}>${RangedMaxDist}
	{
		debug(*Routine* to far away for ranged attacks. Closing.)
		;press and hold the forward button
		wowpress -release movebackward
		wowpress -hold moveforward
	}

	;If we are close enough stop running
	if ${Unit[${AttackGUID}].Distance}>${RangedMinDist}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist}
	{
		wowpress -release moveforward
		wowpress -release movebackward
	}
}

function Melee(string AttackGUID)
{
	;initiate attack
	if !${Me.Attacking}
	{
		Call UpdateHudStatus "Attacking Target in Melee"
		WoWScript AttackTarget()
	}

	#ifdef SWITCH_MONKEY
	if !${Me.Buff[Aspect of the Monkey](exists)}
	#else
	if ${AttackState.Equal[PURE_MELEE]}&&!${Me.Buff[Aspect of the Monkey](exists)}
	#endif
	{
		call CastOnRun "Aspect of the Monkey"
	}

	#ifdef USE_MONGOOSE
	if ${Me.Action[Mongoose Bite].Usable}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}&&${Me.PctMana}>20
	{
		call CastSpell "Mongoose Bite" ${AttackGUID}
	}
	#endif

	;Cast Raptor Strike
	if !${Spell[Raptor Strike].Cooldown}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}&&${Me.PctMana}>20
	{
		call CastSpell "Raptor Strike" ${AttackGUID}
	}
	
	#ifdef MEND_LIMIT
	; Mend Pet
	if ${Me.Pet.PctHPs}<MEND_LIMIT&&!${Me.Pet.Dead}
	{
		call MendPet
	}
	#endif

	; If pet has regained aggro we switch back to ranged state
	if ${Unit[${AttackGUID}].Target.GUID.Equal[${Me.Pet.GUID}]}&&${AttackState.NotEqual[PURE_MELEE]}
	{
		return RANGED
	}

	;If we are close enough stop running
	if ${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}
	{
		wowpress -release moveforward
		wowpress -release movebackward
	}

	;If too far away run forward
	if ${Unit[${AttackGUID}].Distance}>${CombatMaxDist}	
	{
		debug(*Routine* To far away for melee. Closing.)
		;press and hold the forward button
		wowpress -release movebackward
		wowpress -hold moveforward
	}

	;If too close then run backward
	if ${Unit[${AttackGUID}].Distance}<${CombatMinDist}
	{
      		debug(*Routine* To close for melee. Backing.)
       		;press and hold the backward button
       		wowpress -release moveforward
       		wowpress -hold movebackward
	}
}

function Pull(string AttackGUID)
{
	
	; Ensure we are still facing our target loc
	call SmartFacePrecision ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y}
	
	;If too far away run forward
	if ${Unit[${AttackGUID}].Distance}>${RangedMaxDist}
	{
		debug(*Routine* To far away to pull)
		;press and hold the forward button
		wowpress -release movebackward
		wowpress -hold moveforward
	}	

	; If to close run back
	if ${Unit[${AttackGUID}].Distance}<${RangedMinDist}
	{
		debug(*Routine* to close to pull)
		;press and hold the backward button
		wowpress -release moveforward
		wowpress -hold movebackward
	}     

	; Once we get close to our target then pull it
	if ${Unit[${AttackGUID}].Distance}>${RangedMinDist}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist}
	{	
		;First stop
 		move -stop
		
		; If we dont have our chosen unit targeted, target it
		if !${Target.GUID.Equal[${AttackGUID}]}
		{
 			debug(*Routine* *Pulling* Current Target: ${Target.GUID} Targeting Unit ${Unit[${AttackGUID}].Name}[${AttackGUID}])
 			Target ${AttackGUID}
 			wait 1
		}

		; Send in pet
		wowscript PetAttack()
		waitframe

		#ifdef USE_MARK
		call UpdateHudStatus "Casting Hunter's Mark"
		cast "Hunter's Mark"
		wait 20 !${Me.GlobalCooldown}
		#else
		wait 15
		#endif
		
		#ifdef USE_AIMED_SHOT
		waitframe
		CastSpell "Aimed Shot"		
		wait 70 ${Me.Action[Auto Shot].AutoRepeat}&&${Math.Distance[${Me.Pet.X},${Me.Pet.Y},${Unit[${AttackGUID}].X},${Unit[${AttackGUID}].Y}]}<10
		return TRUE
		#else
		waitframe
		wait 30 ${Math.Distance[${Me.Pet.X},${Me.Pet.Y},${Unit[${AttackGUID}].X},${Unit[${AttackGUID}].Y}]}<10
		return TRUE
		#endif
 	}
	return FALSE
}

#ifdef MEND_LIMIT
function MendPet()
{
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	declare StuckCheck bool local FALSE
	declare StuckCheckTime int local

	while ${Me.Pet.Health}!=0
	{
		; Ensure we are still facing our target loc
		call SmartFace ${Me.Pet.X} ${Me.Pet.Y}

		; Else run backward
		if ${Me.Pet.Distance}<${CombatMinDist}
		{
			debug(*Routine* To close for mending. Backing.) 
			;press and hold the backward button
			wowpress -release moveforward
			wowpress -hold movebackward
		}     


		;If too far away run forward
		if ${Me.Pet.Distance}>20
		{
			debug(*Routine* To far away for mending. Closing.)
			;press and hold the forward button
			wowpress -release movebackward
			wowpress -hold moveforward
		}

		;If we are close enough stop running and mend pet
		if ${Me.Pet.Distance}>${CombatMinDist}&&${Me.Pet.Distance}<20
		{
			wowpress -release moveforward
			wowpress -release movebackward
			waitframe
			call CastSpell "Mend Pet" ${Me.Pet.GUID}
			break
		}

		;wait for half a second to give our pc a chance to move
		wait 5

		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Me.Pet.Distance}>${RangedMaxDist}
		{
			; I think i might be stuck so call back pet
			wowscript PetPassiveMode()
			wait 50 ${Me.Pet.Distance}<20
		}
	}
}
#endif

function evade(string Line, string Spellname, string Mob)
{
	call UpdateHudStatus "Your ${Spellname} was evaded by ${Mob}"
	EvadeCount:Inc
	debug(EvadeCount: ${EvadeCount})
}

function Downtime(int repeat=0)
{
	#ifdef REVIVE_PET
	; Revive pet if dead, else call him
	if !(${Me.Pet.Health}!=0)
	{
		move -stop
		call UpdateHudStatus "Trying to call pet"
		call CastSpell "Call Pet" ${Me.GUID}
		wait 20 !${Me.GlobalCooldown}
		if !(${Me.Pet.Health}!=0)
		{
			if ${Me.CurrentMana}>REVIVE_COST
			{
				wait 15
				call UpdateHudStatus "Pet seems to be dead, lets rez him"
				CastSpell "Revive Pet"
				wait 20 ${Me.Casting}
				while ${Me.Casting}
				{
					waitframe
				}
				wait 10
				call UpdateHudStatus "Mending Pet"
				CastSpell "Mend Pet"
				wait 20 ${Me.Casting}
				while ${Me.Casting}
				{
					waitframe
				}
				wait 10
			}
			else
			{
				repeat:Inc
			}
		}
		wait 10
	}
	#endif

	#ifdef FOOD_NAME
	if ${Me.Pet.PctHappiness}<70&&${Me.Pet.Health}!=0&&${Item[FOOD_NAME](exists)}
	{
		cast "feed pet"
		wait 20 ${WoWScript[SpellIsTargeting()]}
		waitframe
		Item[-exact,FOOD_NAME]:PickUp
		wait 1
		wowscript SpellStopTargeting()
		wait 10
	}
	#endif

	if (${Me.PctHPs}<${MinHealthPct}||${Me.PctMana}<${MinManaPct}||${repeat}==1)&&!${Me.Dead}&&!${Me.Ghost}
	{
		if ${SitWhenRest}&&!${Me.Sitting}
		{
			wowpress SITORSTAND
		}

		if ${Me.PctHPs}<${MinHealthPct}&&!${Me.Buff[Food](exists)}
		{
			call Eat
			wait 40 ${Me.Buff[Food](exists)}
		}
		
		if (${Me.PctMana}<${MinManaPct}||${repeat}==1)&&!${Me.Buff[Drink](exists)}
		{
			call Drink
			wait 40 ${Me.Buff[Drink](exists)}
		}

		while (${Me.CurrentHPs}<${Me.MaxHPs}||${Me.CurrentMana}<${Me.MaxMana})&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}
		{
			waitframe
		}
	}

	;Make sure we are stood up.
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}

	; Check if we need to repair
	call CheckDurability

	; Reset downtime flag
	DoDowntime:Set[FALSE]

	; Do we need to repeat downtime?
	if ${repeat}==1
		call Downtime ${repeat:Inc}
}