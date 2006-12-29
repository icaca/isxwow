#define ROUTINES

/*
Priest Routine 1-60 recoded by droppen from lazer1's script
This is written for any spec, any level
My goal is to code all spells availible for priest class and automate everything


####################################################################
# NO CONFIGURATION REQIRED, WORKS FROM LEV 1 to 60, with all specs #
####################################################################

version 1.1
*/

;#define NO_EMOTES		   /* no annoying emotes and jumping around */
#define WANDANDSTAFF 100    /* use wand or staff insted of mind blast and mind flay at % mana */
;#define STAFF              /* use main hand weapon as primary weapon (wand default) */
#define PWS_ALLWAYS        /* if you want to keep pws allways on on combat */
;#define SHADOW_PROT         /* use shadow protection buff */
#define DRINK_PROS 60       /* this % makes you thirsty */
#define MANA_PROS 90        /* % mana before going to war */
#define RENEW_PROS 0        /* % to cast renew */
#define HEAL_PROS 50        /* healing % */
#define USE_HEALING_POTIONS /* use healing potions (duh) */
#define USE_MANA_POTIONS    /* use mana potions.. */
#define SCREAM              /* scream on adds */
;#define SHADOWFORM          /* use shadowform */
;#define RUN_FROM_ELITES     /* if your zone has elites to run from */   


/******** disable spells at random (DO NOT TOUCH UNLESS YOU KNOW WHAT YOUR DOING) ********/
#define PWS
#define VAMPIRIC
#define PAIN
#define FLASH_HEAL
#define RENEW
#define LESSER_HEAL
#define HEAL
#define MIND_BLAST
#define MIND_FLAY
#define PWF
#define DISPEL
#define CURE
#define ABOLISH
#define INNER_FIRE
#define SILENCE
#define PLAGUE
#define WEAKNESS
#define HOLY_FIRE
#define HOLY_NOVA
#define SPIRIT
#define FOCUS
#define INFUSION
#define SMITE



function:bool ACastSpell(string ASpell, string GUID)
{
	declare CastingShoot bool global FALSE
	declare ATarget string local ${Target.GUID}

	debug(${ASpell})
      debug(${GUID})
	if ${Spell[${ASpell}](exists)}
	{
		if !${Unit["${GUID}"].Buff["${ASpell}"](exists)}
		{
			if ${GUID.Equal[${Me.GUID}]} && ${Me.Buff["${ASpell}"](exists)}
			{
				return FALSE
			}
			while ${Spell["Smite"].Cooldown}
			{
				if ${WoWScript[SpellStopCasting()]}
				{
				}
				wait 1 ${Spell["Smite"].Cooldown}
			}
			if !${Spell["${ASpell}"].Cooldown} 
			{
				if ${Spell[${ASpell}].Mana} < ${Me.CurrentMana}
				{
					if ${ASpell.Equal["Shoot"]} && ${CastingShoot}
						CastingShoot:Set[TRUE]
					else
						CastingShoot:Set[FALSE]

					if !${CastingShoot}
					{
						call CastSpell "${ASpell}" ${GUID}
					}

					while ${Me.Casting}
					{
						wait 1
					}
					return TRUE
				}
			}
		}
	}
	return FALSE
}

function CombatPrep()
{
	wowpress -release moveforward
   	if !${Me.InCombat}
	   {
		#ifdef SPIRIT
		call ACastSpell "Divine Spirit" ${Me.GUID}
		#endif
	
		#ifdef PWF
		call ACastSpell "Power Word: Fortitude" ${Me.GUID}
		#endif
		
		#ifdef INNER_FIRE
		call ACastSpell "Inner Fire" ${Me.GUID}
		#endif

		#ifdef SHADOWFORM
		call ACastSpell "Shadowform" ${Me.GUID}
		#endif
	
		#ifdef WEAKNESS
		call ACastSpell "Touch of Weakness" ${Me.GUID}
		#endif
	
		#ifdef SHADOW_PROT
		call ACastSpell "Sadow Protection" ${Me.GUID}
		#endif

   		;wait until we get our mana back
		if ${Me.PctMana}<DRINK_PROS
		{
			debug("drinking")
			call Drink
		}

		if ${Me.PctHPs}<HEAL_PROS
		{
			debug("eating")
			call Eat
		}

		#ifndef NO_EMOTES
		declare emote int local 0
		if ${Me.PctMana}<MANA_PROS && !${Me.InCombat} && !${Me.Dead} && !${Me.Sitting}
		{
			call DoEmotes
		}
		#endif

		while (${Me.PctMana}<MANA_PROS || ${Me.PctHPs}<HEAL_PROS) && !${Me.InCombat} && !${Me.Dead}
		{
			wait 1
		}

		;Make sure we are stood up.
		if ${Me.Sitting}
		{
			wowpress SITORSTAND
		}
   	}

	if ${Me.PctHPs} < 30
	{
		Me.Buff["Shadowform"]:Remove
		while ${Spell["Smite"].Cooldown}
		{
			if ${WoWScript[SpellStopCasting()]}
			{
			}
			wait 1 ${Spell["Smite"].Cooldown}
		}

		debug("casting heal")
		
		#ifdef FLASH_HEAL
		call ACastSpell "Flash Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif
	
		#ifdef HEAL
		call ACastSpell "Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif

		#ifdef LESSER_HEAL
		call ACastSpell "Lesser Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif
	}
		


   	;Reset flag
   	DoCombatPrep:Set[FALSE]
   	DoDowntime:Set[TRUE]
}

function Attack(string AttackGUID)
{
	
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}

	declare SavMobDist float local ${Unit[AttackGUID].Distance}

	declare SavZ float local ${Me.Z}
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*10)]}
	declare HavePulled bool local FALSE
	declare StuckCheck bool local FALSE
	declare StuckCheckCount int local 0
	declare StuckCheckTime int local
	declare Aggros guidlist local


	if !${Unit[${AttackGUID}].Tapped} && ${Me.InCombat}
		wowscript TargetNearestEnemy()
		

    if ${Unit[${AttackGUID}].FactionGroup.Equal[Alliance]}
   {
      ;add them to a blacklist or whatever here...
      call UpdateHudStatus "Target is an alliance member, don't bother attacking them"
      GUIDBlacklist:Set[${AttackGUID},AVOID]
         RLG:Set[TRUE]
      TargetGUID:Set[NOTARGET]
      Return
   }

   if ${Unit[${AttackGUID}].Level} > ${Me.Level}+5
   {
      if !${Me.InCombat}
      {
         echo "over 5!"
         ;add them to a blacklist or whatever here...
         call UpdateHudStatus "Target is an elite, don't bother attacking them"
         GUIDBlacklist:Set[${AttackGUID},AVOID]
         TargetGUID:Set[NOTARGET]
            Return
      }
      else
      {
         ;we need to RLG
         call UpdateHudStatus "nooo!!"
         RLG:Set[TRUE]
         GUIDBlacklist:Set[${AttackGUID},AVOID]
         TargetGUID:Set[NOTARGET]
         return
      }
   } 

   #ifdef RUN_FROM_ELITES   
   if ${Unit[${AttackGUID}].Classification.Equal[Elite]}
   {
      if !${Me.InCombat}
      {
         echo ELITE!
         ;add them to a blacklist or whatever here...
         call UpdateHudStatus "Target is an elite, don't bother attacking them"
         GUIDBlacklist:Set[${AttackGUID},AVOID]
         TargetGUID:Set[NOTARGET]
            Return
      }
      else
      {
         ;we need to RLG
         call UpdateHudStatus "Aggrod an elite RUN!!"
         RLG:Set[TRUE]
         GUIDBlacklist:Set[${AttackGUID},AVOID]
         TargetGUID:Set[NOTARGET]
         return
      }
   } 
   #endif
	
	if ${AttackGUID.Equal[NULL]}||${AttackGUID.Equal[NOTARGET]}
	{
		call UpdateHudStatus "No target to attack"
	}
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
		
	     ; Ensure we are still facing our target loc

   	        call SmartFacePrecision ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
    
		
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
		if !${Target.GUID.Equal[${AttackGUID}]}
		{
			#ifdef DEBUG
				call Debug "Targeting Unit ${Unit[${AttackGUID}].Distance}[${AttackGUID}]"
			#endif
			Target ${AttackGUID}
			wait 10
		}
		


		; Check we havent picked up an aggro other than the mob we have targeted.
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10]
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			debug("Untargeted Unit ${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine")
			return
		}
		Aggros:Clear
		
		if ${Me.InCombat}
		{
			HavePulled:Set[TRUE]
		}
		
		; Check if we have pulled yet and if not do so.
		if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled}
		{

			if ${Unit[${AttackGUID}].Distance}<30&&${Unit[${AttackGUID}].Distance}>0
			{
				#ifdef MIND_BLAST
				call ACastSpell "Mind Blast" ${Target.GUID}
				if !${Return}
				{
				#endif
					#ifdef HOLY_FIRE
					call ACastSpell "Holy Fire" ${Target.GUID}
					if !${Return}
					{
					#endif
						#ifdef SMITE
						call ACastSpell "Smite" ${Target.GUID}
						#endif
					#ifdef HOLY_FIRE
					}
					#endif
				#ifdef MIND_BLAST
				}
				#endif

				HavePulled:Set[TRUE]
			}			
		}

		if ${SavMobDist} != ${Unit[${AttackGUID}].Distance} && ${SavMobDist} != 0.00
		{
			#ifdef MIND_FLAY
			call ACastSpell "Mind Flay" ${AttackGUID}
			#endif
		}
		SavMobDist:Set[${Unit[${AttackGUID}].Distance}]


		AttackTime:Set[${LavishScript.RunningTime}]
		; Start main attack routine
		call attack_spells ${AttackGUID}
		
		if !${Me.InCombat}
		{
		;If too far away run forward
		if ${Unit[${AttackGUID}].Distance}>${CombatMaxDist}&&!${Me.Casting}&&${Unit[${AttackGUID}].PctHPs}>90
		{
			debug("Too far closing")
			;press and hold the forward button 
			wowpress -release movebackward
			wowpress -hold moveforward
		}

		;If too close then run backward
		if ${Unit[${AttackGUID}].Distance}<${CombatMinDist}&&!${Me.Casting}
		{
			debug("Too close backing up")
			;press and hold the backward button 
			wowpress -release moveforward
			wowpress -hold movebackward
		}
		
		;If we are close enough stop running
		if (${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist})||${Me.Casting}
		{
			wowpress -release moveforward
			wowpress -release movebackward
			StuckCheck:Set[FALSE]
		}
		}
		
		;wait for half a second to give our pc a chance to move
		wait 5
		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${TargetGUID.Equal[NOTARGET]}
		{
			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				debug("I might be stuck")
				StuckCheck:Set[TRUE]
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			} 
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>8000
				{
					debug("Yep I am stuck trying to free myself")
					call Obstacle
					StuckCheckCount:Inc
					StuckCheck:Set[FALSE]
				}
			}
		}
		
		; If I have moved away from my saved spot reset my stuck toggle
		if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
		{
			debug("I am no longer stuck")
			StuckCheck:Set[FALSE]
			StuckCheckCount:Set[0]
		}
		
		;If I am stuck too many times then quit.
		if ${StuckCheckCount}>5
		{
			debug("Got stuck to often")
			call ExitGame
		}
		
		; Check if we have exceeded bail out timer and the mob is still at full health
		if ${LavishScript.RunningTime}>${BailOut}&&${Unit[${TargetGUID}].PctHPs}>99
		{
			GUIDBlacklist:Set[${TargetGUID},AVOID]
			call UpdateHudStatus "Combat timeout reached"
			TargetGUID:Set[NOTARGET]
			return
		}

	}
	while !${Unit[${AttackGUID}].Dead}&&!${Me.Dead}
	
	; Update stats
	if !${Me.Dead}
	{
		call UpdateStats
	}

	wowpress -release movebackward
	wowpress -release moveforward

	;Reset flags to do combat prep and downtime if we are not still aggroed
	Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-50] 
	if !${Aggros.Count}
	{ 
		call Debug "Resetting Downtime and CombatPrep Flags" 
		DoDowntime:Set[TRUE]
		DoCombatPrep:Set[TRUE]

	}
	Aggros:Clear
}


;©2006 Droppen "thisa isa nica funktióne!"
function attack_spells(string AttackGUID)
{
	debug("pick spell")
	if ${Me.Dead}
	{
		return
	}
	
	#ifdef INFUSION
	if ${Me.PctHPs} > 90
	{
		debug("casting power infusion")
		call ACastSpell "Power Infusion" ${Me.GUID}
		if ${Return}
		{
			return
		}
	}
	#endif

	#ifdef PWS_ALLWAYS
	if !${Me.Buff["Weakened Soul"](exists)}
	{
		debug("casting shield")
		call ACastSpell "Power Word: Shield" ${Me.GUID}
		if ${Return}
		{
			return
		}
	}
	#endif


	if ${Me.PctHPs} < 30
	{
		Me.Buff["Shadowform"]:Remove
	}

	if ${Me.PctHPs} < 10 && ${Me.PctMana} < 10
	{
		#ifdef USE_MANA_POTIONS
			call DrinkBestManaPotion
		#endif
	}

	if ${Me.PctHPs} < HEAL_PROS && ${Me.PctMana} > 10 && !${Me.Buff["Shadowform"](exists)}
	{
		while ${Spell["Smite"].Cooldown}
		{
			if ${WoWScript[SpellStopCasting()]}
			{
			}
			wait 1 ${Spell["Smite"].Cooldown}
		}

		#ifdef PWS
		if !${Me.Buff["Weakened Soul"](exists)}
		{
			debug("casting shield")
			call ACastSpell "Power Word: Shield" ${Me.GUID}
			if ${Return}
			{
				return
			}
		}
		#endif

		debug("casting heal")
		
		#ifdef FLASH_HEAL
		call ACastSpell "Flash Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif
	
		#ifdef HEAL
		call ACastSpell "Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif

		#ifdef LESSER_HEAL
		call ACastSpell "Lesser Heal" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif

		#ifdef PRAYER
		call ACastSpell "Desprate Prayer" ${Me.GUID}
		if ${Return}
		{
			return
		}
		#endif

		#ifdef USE_HEALING_POTIONS
			call DrinkBestHealingPotion
		#endif

	}

	#ifdef RENEW
	if ${Me.PctHPs} < RENEW_PROS
	{
		debug("casting renew")
		call ACastSpell "Renew" ${Me.GUID}
		if ${Return}
		{
			return
		}
	}
	#endif



	#ifdef SCREAM
	declare Aggros guidlist local
	Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-20]

    	if ${Aggros.Count}>1 || ${Me.PctHPs} < 20
    	{
          	call ACastSpell "Psychic Scream" ${AttackGUID}
		if ${Return}
		{
			return
		}	 
     	}
	#endif

      if ${Target.Casting.ID(exists)}
	{
      	call ACastSpell "Silence" ${Target.GUID}
		{
			return
		}
      } 

	#ifdef PARTY
	call PartySpells
	#endif

      #ifdef VAMPIRIC
	if !${Unit[${AttackGUID}].PctHPs} < 80 && ${Me.PctMana} > 80
	{
		#ifdef STAFFANDWAND
			if !STAFFANDWAND > 70
			{
		#endif
		call ACastSpell "Vampiric Embrace" ${AttackGUID}
		if ${Return}
		{
			return
		}
		#ifdef STAFFANDWAND
			}
		#endif
	}
	#endif

	#ifdef PAIN
	if !${Unit[${AttackGUID}].PctHPs} < 30
	{
		debug("casting pain")
		call ACastSpell "Shadow Word: Pain" ${AttackGUID}
		if ${Return}
		{
			return
		}
	}
	#endif

	#ifdef PLAGUE
	if ${Unit[${AttackGUID}].PctHPs} > ${Me.PctHPs}
	{
		debug("casting plague")
		call ACastSpell "Devouring Plague" ${AttackGUID}
		if ${Return}
		{
			return
		}
	}
      #endif

	#ifdef WANDANDSTAFF
		if ${Me.PctMana} < WANDANDSTAFF
		{

			#ifdef STAFF
			if !${Me.Equip[mainhand].Durability} == NULL || !${Me.Equip[mainhand].Durability} == 0 
			{
				call CastSpell "Attack" ${AttackGUID}
				return
			}
			#endif
	
			if !${Me.Equip[ranged].Durability} == NULL || !${Me.Equip[ranged].Durability} == 0
			{
				call CastSpell "Shoot" ${AttackGUID}
				return
			}

			if !${Me.Equip[mainhand].Durability} == NULL || !${Me.Equip[mainhand].Durability} == 0
			{
				call CastSpell "Attack" ${AttackGUID}
				return
			}
		}
      #endif
	
	#ifdef MIND_BLAST
	call ACastSpell "Mind Blast" ${AttackGUID}
	if ${Return}
	{
		return
	}
	#endif	

	#ifdef MIND_FLAY
	call ACastSpell "Mind Flay" ${AttackGUID}
	if ${Return}
	{
		return
	}
	#endif

	#ifdef SMITE
	call ACastSpell "Smite" ${AttackGUID}
	if ${Return}
	{
		return
	}
	#endif
}

function Downtime()
{
	call CheckDebuff ${Me.GUID}

	#ifdef RENEW
	if ${Me.PctHPs}<60 && !${Me.Buff[Renew](exists)}
	{
		while ${Spell["Renew"].Cooldown}
		{
			if ${WoWScript[SpellStopCasting()]}
			{
			}
			wait 1 ${Spell["Renew"].Cooldown}
		}
		call ACastSpell "Renew" ${Me.GUID}
	}
	#endif

	if ${Me.PctMana}<DRINK_PROS || ${Me.PctHPs}<RENEW_PROS && !${Me.InCombat} && !${Me.Dead}
	{


		if ${Me.PctHPs}<HEAL_PROS && !${Me.Buff[Renew](exists)}
		{
			debug("casting heal")
			call ACastSpell "Flash Heal" ${Me.GUID}
			if !${Return}
			{
				call ACastSpell "Heal" ${Me.GUID}
				if !${Return}
				{
					call ACastSpell "Lesser Heal" ${Me.GUID}
				}
			}
		}

	}
	

	;Make sure we are stood up.
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}

	call CheckDurability

	DoDowntime:Set[FALSE]
}


;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestManaPotion
;| In:
;| Returns:
;| Description: Finds the best mana potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function DrinkBestManaPotion()
{
	declare MajorCooldown int 0
	declare CombatCooldown int 0
	declare SuperiorCooldown int 0
	declare GreaterCooldown int 0
	declare NormalCooldown int 0
	declare LesserCooldown int 0
	declare MinorCooldown int 0

	call GetItemCooldown "Major Mana Potion"
	MajorCooldown:Set[${Return}]
	call GetItemCooldown "Combat Mana Potion"
	CombatCooldown:Set[${Return}]
	call GetItemCooldown "Superior Mana Potion"
	SuperiorCooldown:Set[${Return}]
	call GetItemCooldown "Greater Mana Potion"
	GreaterCooldown:Set[${Return}]
	call GetItemCooldown "Mana Potion"
	NormalCooldown:Set[${Return}]
	call GetItemCooldown "Lesser Mana Potion"
	LesserCooldown:Set[${Return}]
	call GetItemCooldown "Minor Mana Potion"
	MinorCooldown:Set[${Return}]

	if ${Item[-inventory,Major Mana Potion](exists)} && ${Item[-inventory,Major Mana Potion].Usable} && !${MajorCooldown}
	{
		Item[Major Mana Potion]:Use
	}
	else
	if ${Item[-inventory,Combat Mana Potion](exists)} && ${Item[-inventory,Combat Mana Potion].Usable} && !${CombatCooldown}
	{
		Item[Combat Mana Potion]:Use
	}
	else
	if ${Item[-inventory,Superior Mana Potion](exists)} && ${Item[-inventory,Superior Mana Potion].Usable} && !${SuperiorCooldown}
	{
		Item[Superior Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Greater Mana Potion](exists)} && ${Item[-inventory,Superior Mana Potion].Usable} && !${GreaterCooldown}
	{
		Item[Greater Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Mana Potion](exists)} && ${Item[-inventory,Mana Potion].Usable} && !${NormalCooldown}
	{
		Item[Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Lesser Mana Potion](exists)} && ${Item[-inventory,Lesser Mana Potion].Usable} && !${LesserCooldown}
	{
		Item[Lesser Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Minor Mana Potion](exists)} && ${Item[-inventory,Minor Mana Potion].Usable} && !${MinorCooldown}
	{
		Item[Minor Healing Potion]:Use
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestHealingPotion
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best healing potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function DrinkBestHealingPotion()
{
	declare MajorCooldown int 0
	declare CombatCooldown int 0
	declare SuperiorCooldown int 0
	declare GreaterCooldown int 0
	declare NormalCooldown int 0
	declare DiscoloredCooldown int 0
	declare LesserCooldown int 0
	declare MinorCooldown int 0

	call GetItemCooldown "Major Healing Potion"
	MajorCooldown:Set[${Return}]
	call GetItemCooldown "Combat Healing Potion"
	CombatCooldown:Set[${Return}]
	call GetItemCooldown "Superior Healing Potion"
	SuperiorCooldown:Set[${Return}]
	call GetItemCooldown "Greater Healing Potion"
	GreaterCooldown:Set[${Return}]
	call GetItemCooldown "Healing Potion"
	NormalCooldown:Set[${Return}]
	call GetItemCooldown "Discolored Healing Potion"
	DiscoloredCooldown:Set[${Return}]
	call GetItemCooldown "Lesser Healing Potion"
	LesserCooldown:Set[${Return}]
	call GetItemCooldown "Minor Healing Potion"
	MinorCooldown:Set[${Return}]

	if ${Item[-inventory,Major Healing Potion](exists)} && ${Item[-inventory,Major Healing Potion].Usable} && !${MajorCooldown}
	{
		Item[-inventory,Major Healing Potion]:Use
	}
	else
	if ${Item[-inventory,Combat Healing Potion](exists)} && ${Item[-inventory,Combat Healing Potion].Usable} && !${CombatCooldown}
	{
		Item[-inventory,Combat Healing Potion]:Use
	}
	else
	if ${Item[-inventory,Superior Healing Potion](exists)} && ${Item[-inventory,Superior Healing Potion].Usable} && !${SuperiorCooldown}
	{
		Item[Superior Healing Potion]:Use
	}
	else 
	if ${Item[-inventory,Greater Healing Potion](exists)} && ${Item[-inventory,Superior Healing Potion].Usable} && !${GreaterCooldown}
	{
		Item[Greater Healing Potion]:Use
	}
	else 
	if ${Item[-inventory,Healing Potion](exists)} && ${Item[-inventory,Healing Potion].Usable} && !${NormalCooldown}
	{
		Item[Healing Potion]:Use
	}
	else 
	if ${Item[-inventory,Discolored Healing Potion](exists)} && ${Item[-inventory,Discolored Healing Potion].Usable} && !${DiscoloredCooldown}
	{
		Item[Discolored Healing Potion]:Use
	}
	else 
	if ${Item[-inventory,Lesser Healing Potion](exists)} && ${Item[-inventory,Lesser Healing Potion].Usable} && !${LesserCooldown}
	{
		Item[Lesser Healing Potion]:Use
	}
	else 
	if ${Item[-inventory,Minor Healing Potion](exists)} && ${Item[-inventory,Minor Healing Potion].Usable} && !${MinorCooldown}
	{
		Item[Minor Healing Potion]:Use
	}
}


;+-----------------------------------------------------------------------------------------------------
;| Name: GetItemCooldown
;| In: ItemName
;| Returns: Item's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown of given item.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function GetItemCooldown(string ItemName)
{
	return ${WoWScript["if ${Item[${ItemName}].Bag.Number} then GetContainerItemCooldown(${Item[${ItemName}].Bag.Number}\, ${Item[${ItemName}].Slot}), 2]} end"]}
}



;if this script is yours, thank you pickled
;about: http://www.ismods.com/forums/viewtopic.php?t=2242
function CheckDebuff( string RecipientGUID )
{
   declare DebuffType string local
   declare DebuffName string local
   declare Cure string local

   ; If I'm already casting something then don't do anything.
   if ${Me.Casting}
   {
      return
   }

   declare DebuffCounter int local 1
   Cure:Set[""]
   do
   {   
      ; If we've come to the end of the buff list then break.
      if !${Player[${RecipientGUID}].Buff[${DebuffCounter}](exists)}
      {
         break
      }

      ; If this debuff is harmful, then see if it can be cured.
      if ${Player[${RecipientGUID}].Buff[${DebuffCounter}].Harmful} \
         && ( !${ImInCombat} \
            || ${Player[${RecipientGUID}].Buff[${DebuffCounter}].Name.Equal[Hex]} \
            || ${Player[${RecipientGUID}].Buff[${DebuffCounter}].Name.Equal[Petrify]} )
      {

         if ${Player[${RecipientGUID}].Buff[${DebuffCounter}].DispelType.Equal[Magic]}
         {	
		#ifdef DISPEL
            	Cure:Set[Dispel Magic]
		#endif
            break
         }

         if ${Player[${RecipientGUID}].Buff[${DebuffCounter}].DispelType.Equal[Disease]}
         {
            if ${Spell[Cure Disease](exists)}
            {
	         #ifdef CURE
               	Cure:Set[Cure Disease]
		   #endif
            }

            if ${Spell[Abolish Disease](exists)}
            {
		   #ifdef ABOLISH
               	Cure:Set[Abolish Disease]
		   #endif
            }
            break
         }
      }
   
      DebuffCounter:Inc
   }
   while ${DebuffCounter} <= 56
   
   ; Looks like the player needs to be cleansed, so cleanse them
   if !${Cure.Equal[""]}
   {
      call ACastSpell "${Cure}" ${RecipientGUID}
	return 1
   }
   return 0
} 

;Thanks donald rumsfeld for this function
function DoEmotes()
{
	declare have_emoted int local 0
	declare emote int local 0
	declare moverand int

	emote:Set[""]
     if ${have_emoted} == 0
           {
     
                      emote:Set[${Math.Rand[100]}]
                      call UpdateHudStatus "Emote value: ${emote}"
                    if ${emote} < 21
                    {
                    call UpdateHudStatus "No Emote"
                    }
                    if ${emote} > 21 && ${emote} < 41
            {
                   call UpdateHudStatus "(jumping around)"
                   moverand:Set[${Math.Rand[3]}]
                   ;echo ${moverand}
                   if (${moverand}==0)
                   {
                   move left
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==1)
                   {
                   move right
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==2)
                   {
                   move forward
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==3)
                   {
                   move backward
                   wowpress JUMP
                   move -stop
                   } 
                   wait 5
                   moverand:Set[${Math.Rand[3]}]
                   ;echo ${moverand}
                   if (${moverand}==0)
                   {
                   move left
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==1)
                   {
                   move right
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==2)
                   {
                   move forward
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==3)
                   {
                   move backward
                   wowpress JUMP
                   move -stop
                   } 
                   wait 5
                   moverand:Set[${Math.Rand[3]}]
                   ;echo ${moverand}
                   if (${moverand}==0)
                   {
                   move left
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==1)
                   {
                   move right
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==2)
                   {
                   move forward
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==3)
                   {
                   move backward
                   wowpress JUMP
                   move -stop
                   } 
                   wait 5
                   call UpdateHudStatus "(jumping around)"
                   moverand:Set[${Math.Rand[3]}]
                   ;echo ${moverand}
                   if (${moverand}==0)
                   {
                   move left
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==1)
                   {
                   move right
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==2)
                   {
                   move forward
                   wowpress JUMP
                   move -stop
                   }
                   if (${moverand}==3)
                   {
                   move backward
                   wowpress JUMP
                   move -stop
                   } 
                   wait 5

            
               }
                    if ${emote} > 41 && ${emote} < 51
            {
		;disabled cuz sleeping triggers Me.Stitting
            ;WoWScript DoEmote("sleep")
            call UpdateHudStatus "(sleep)"
            }
            if ${emote} > 50 && ${emote} < 70
            {
            WoWScript DoEmote("dance")
            call UpdateHudStatus "(dance)"
            }
            if ${emote} > 70 && ${emote} < 92
            {
            call UpdateHudStatus "(jumping in place)"
            wowpress JUMP
            wait 5
            wowpress JUMP
            wait 6
            wowpress JUMP
            wait 5
            wowpress JUMP
            
            }
            if ${emote} == 92
            {
            WoWScript DoEmote("fart")
            call UpdateHudStatus "(fart)"
            }
            if ${emote} == 93
            {
            WoWScript DoEmote("burp")
            call UpdateHudStatus "(burp)"
            }
            if ${emote} == 94
            {
            WoWScript DoEmote("silly")
            call UpdateHudStatus "(silly)"
            }
            if ${emote} == 95
            {
            WoWScript DoEmote("train")
            call UpdateHudStatus "(train)"
            }
            if ${emote} == 96
            {
            WoWScript DoEmote("sigh")
            call UpdateHudStatus "(sigh)"
            }
            if ${emote} == 97
            {
            WoWScript DoEmote("ponder")
            call UpdateHudStatus "(ponder)"
            }
            if ${emote} == 98
            {
            WoWScript DoEmote("love")
            call UpdateHudStatus "(love)"
            }
            if ${emote} == 99
            {
            WoWScript DoEmote("thirsty")
            call UpdateHudStatus "(thirsty)"
            }
            if ${emote} == 100
            {
            WoWScript DoEmote("hungry")
            call UpdateHudStatus "(hungry)"
            }
            have_emoted:Set[1]                 
                 
      }
}