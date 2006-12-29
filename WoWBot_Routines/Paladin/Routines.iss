;Updated Paladin Bot by Tenshi
;Modified Version of Zodium's Paladin Bot (ISMods forum name - priest)
;Original Author's E-mail: zonte1337@gmail.com
;Emergency Section courtesy of Kras
;-----
;Edit anything below this point to fit your needs unless otherwise specified.

#define ROUTINES
#define POTION1 "Lesser Healing Potion"
#define POTION2 "Healing Potion"
#define Potion3 "Minor Healing Potion"

; Emergency Situations. Potion Percent should be equal to
; or higher than Lay on Hands so that spell based (free)
; emergency gets fired first.
#define STUNHPPCT 45
#define EMERGENCYHPPCT 35
#define LAYONHANDSHPPCT 10
#define POTIONHPPCT 10

function DrinkPotion()
{
	if ${Item[POTION1].StackCount} && !${Item[POTION1].Cooldown}
	{
		use ${Item[POTION1].GUID}
	}
	else 
	if ${Item[POTION2].StackCount} && !${Item[POTION2].Cooldown}
	{
		use ${Item[POTION2].GUID}
	}
	else 
	if ${Item[POTION3].StackCount} && !${Item[POTION3].Cooldown}
	{
		use ${Item[POTION3].GUID}
	}
}

function CombatPrep()
{

	;Reset flag
	DoCombatPrep:Set[FALSE]
}

function Attack(string AttackGUID)
{

	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*${CombatBailout})]}
	declare HavePulled bool local FALSE
	declare StuckCheck bool local FALSE
	declare StuckCheckTime int local
	declare Aggros guidlist local
	
	if ${AttackGUID.Equal[NULL]}||${AttackGUID.Equal[NOTARGET]}
	{
		call UpdateHudStatus "No target has been found."
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
			call UpdateHudStatus "Target has been lost."
			TargetGUID:Set[NOTARGET]
			Return
		}
	
		; Check if the target is engaged already
		if ${Unit[${AttackGUID}].Tapped}
		{
			call UpdateHudStatus "Target has already been found."
			TargetGUID:Set[`NOTARGET]
			Return		
		} 
	
		; If we dont have our chosen unit targeted and were in range target it
		if !${Target.GUID.Equal[${AttackGUID}]}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
		{
			#ifdef DEBUG
			call Debug "Targeting Unit ${Unit[${AttackGUID}].Distance}[${AttackGUID}]"
			#endif
			Target ${AttackGUID}
			wait 10
		}
	
		if !${Me.Attacking}&&${Target(exists)}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
		{
			WoWScript AttackTarget()
		}

		; Check we havent picked up aggro
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10]
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			#ifdef DEBUG
			call Debug "${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine"
			#endif
			return
		}
		Aggros:Clear
	
		; Check if we are a caster and act appropriately
		if ${IsCaster}
		{
			; Once we get close to our target then pull it
			if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&${Me.PctMana}>20&&!${HavePulled}
			{
				HavePulled:Set[TRUE]
			}
		}
		else
		{
			; Once we get close to our target then pull it
			if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled}
			{
				call UpdateHudStatus "Casting Pulling"
				;Put your pull routine here
				HavePulled:Set[TRUE]
			}
		}

		if (${PullBeforeContinue}&&${HavePulled})||!${PullBeforeContinue}
		{
			; Check if we have enough mana to cast
			if ${Me.PctMana}>30
			{

				; Blessing Buff
				if !${Me.Buff[Blessing of Might].Number}
				{
					call CastSpell "Blessing of Might" ${Me.GUID}
				}

				; Battle Seal
				if !${Me.Buff[Seal of Righteousness].Number}
				{
					call CastSpell "Seal of Righteousness" ${Attack.GUID}
				}
	
				; Aura
				if !${Me.Buff[Devotion Aura].Number}
				{
					call CastSpell "Devotion Aura" ${Me.GUID}
				}
	
				;Judgement
				if !${Spell[Judgement].Cooldown} && ${Me.Buff[Seal of Righteousness].Number}
				{
			  		call CastSpell "Judgement" ${AttackGUID}
				}

				;Exorcism 
				if !${Spell[Exorcism].Cooldown} && ${Target.CreatureType.Equal[Undead]}
				{
					call CastSpell "Exorcism"
				}

				; Multiple Enemies, if we have consecration, use it.
            			Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-8]
            			if ${Aggros.Count}>1 && !${Spell[Consecration].Cooldown}
				{
					call CastSpell "Consecration"
				}
				Aggros:Clear

				;Stun if health getting low
				if ${Me.PctHPs}<STUNHPPCT && !${Spell[Hammer of Justice].Cooldown}
				{
					call CastSpell "Hammer of Justice" ${AttackGUID}
				}
	
				; Safety actions
				if ${Me.PctHPs}<EMERGENCYHPPCT
				{
					; Emergency - Shield
					if !${Spell[Divine Protection].Cooldown} && !${Me.Buff[Forbearance](exists)}
					{
						call CastSpell "Divine Protection" ${Me.GUID}
						call CastSpell "Holy Light" ${Me.GUID}
						call CastSpell "Holy Light" ${Me.GUID}
					}
					else
	
					;Emergency 2 - Shield Blessing
					if !${Spell[Blessing of Protection].Cooldown} && !${Me.Buff[Forbearance](exists)}
					{
						call CastSpell "Blessing of Protection" ${Me.GUID}
						call CastSpell "Holy Light" ${Me.GUID}
						call CastSpell "Holy Light" ${Me.GUID}
					}
					else
	
					; Final Spell Based Emergency - Lay on Hands
					if !${Spell[Lay on Hands].Cooldown}&&${Me.PctHPs}<LAYONHANDSHPPCT
					{
						call CastSpell "Lay on Hands" ${Me.GUID}
					}

					; Final Emergency - Pray you have a Potion
					else
					if ${Me.PctHPs}<POTIONHPPCT
					{
						call DrinkPotion
					}
				}
			}
			else
			{
				; Out of Mana but need to Heal
				if ${Me.PctHPs}<POTIONHPPCT 
				{
					call DrinkPotion
				}
			}
		}	
		
		; Check if we wish to flee combat or not
		Aggros:Search[-units,-nearest,-aggro,-alive, -range 0-${Math.Calc[${MaxRoam}/2]}]
		if (${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]})||(${Aggros.Count}>${PanicThreshold}&&(${Me.PctHPs}<40||((${Me.PctHPs}<30&&${Me.PctMana}<10)&&${Unit[AttackGUID].PctHPs}>30))
		{
			call Debug "I have ${Aggros.Count} mobs on me.  Run."
			RLG:Set[TRUE]
			return
		}
		
		;If too far away run forward
		if ${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
		{
			#ifdef DEBUG
			call Debug "We are too far away from the target."
			#endif
			;press and hold the forward button
			wowpress -release movebackward
			wowpress -hold moveforward
		}	

		;If too close then run backward
		if ${Unit[${AttackGUID}].Distance}<${CombatMinDist}
		{
			#ifdef DEBUG
			call Debug "We are too close to the target."
			#endif
			;press and hold the backward button
			wowpress -release moveforward
			wowpress -hold movebackward
		}
		
		;If we are close enough stop running
		if ${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}
		{
			wowpress -release moveforward
			wowpress -release movebackward
			StuckCheck:Set[FALSE]
		}
		
		; Wait for half a second to give our pc a chance to move
		wait 5
		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
		{
			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				#ifdef DEBUG
				call Debug "We might be stuck..."
				#endif
				StuckCheck:Set[TRUE]
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			}
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>8000
				{
					#ifdef DEBUG
					call Debug "Let's try to get unstuck..."
					#endif
					call Obstacle
					StuckCheck:Set[FALSE]
				}
			}
		
			; If I have moved away from my saved spot reset my stuck toggle
			if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
			{
				#ifdef DEBUG
				call Debug "We are no longer stuck."
				#endif
				StuckCheck:Set[FALSE]
			}	

			; Check if we have exceeded bail out timer
			if ${LavishScript.RunningTime}>${BailOut}
			{
				GUIDBlacklist:Set[${TargetGUID},AVOID]
				call UpdateHudStatus "Combat timeout reached"
				TargetGUID:Set[NOTARGET]
				return
			}
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


function Downtime()
{
	if ${Me.PctMana}<${MinManaPct}
	{
		;Make sure we are sitting down.
		if !${Me.Sitting}
		{
			wowpress SITORSTAND
		}

		while ${Me.PctMana}<99&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}
		{
			if ${Me.PctMana}<${MinManaPct} && !${Me.Buff[Drink](exists)}
			{
				call Drink
				wait 40 ${Me.Buff[Drink](exists)}
			}
		}
	}

	;Make sure we are stood up.
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}

	if ${Me.PctHPs}<${MinHealthPct}
	{
		call CheckDurability
		while ${Me.PctHPs}<90&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}
		{
			call CastSpell "Holy Light" ${Me.GUID}
			wait 25

			waitframe 
		}
	}
 
	; Reset downtime flag
	DoDowntime:Set[FALSE]
}