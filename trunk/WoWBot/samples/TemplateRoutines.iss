; TemplateRoutines.iss
; Basis for writing your own Routines file

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES


;
; The CombatPrep function is called once you have selected a target but before you enter combat.
;
function CombatPrep()
{
	; This is to stop you moving if you want to buff up etc before starting combat.
	; If you dant need to stop then you can remove this. 
	move -stop
	
	; If your a Warlock you might want to check your pet and summon it here.
	;
/*
	if !${Me.Pet(exists)} 
	{
		call UpdateHudStatus "Summoning a new pet" 
		call CastSpell "<Pet Spell>"  ${Me.GUID} 
	}
*/
	; You might want to check long duration buffs too.
		
/*
	if !${Me.Buff[buff name](exists)}&&${Me.Buff[buff name].Duration} < 60 
	{
		call CastSpell "buff spell name" ${Me.GUID}
	}
*/

	
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
	declare StuckCheckCount int local 0
	declare StuckCheckTime int local
	declare Aggros guidlist local
	declare RangedMode bool local TRUE
	
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
		if !${Target.GUID.Equal[${AttackGUID}]}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
		{
			debug("Targeting Unit ${Unit[${AttackGUID}].Distance}[${AttackGUID}]")
			Target ${AttackGUID}
			wait 10
		}
		;Check if we want to switch to ranged mode
		if !${RangedMode} && ${Unit[${AttackGUID}].Distance} > ${RangedMinDist}
		{
			RangedMode:Set[TRUE]
			call UpdateHudStatus "Entered Ranged Mode"
		}
		
		;Check if we need to switch out of Ranged Mode
		if ${RangedMode} && ${Unit[${AttackGUID}].Distance} < ${RangedMinDist}
		{
			RangedMode:Set[FALSE]
			call UpdateHudStatus "Left Ranged Mode"
		}
		
		; Get a list of nearby aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-45]

		; Check we havent picked up an aggro other than the mob we have targeted.
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			debug("Untargeted Unit ${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine")
			return
		}

		;Check that we dont have too many aggro mobs on us
		if (${Aggros.Count}>=${PanicThreshold} && ${Me.PctHPs}<40) || (${Me.PctHPs}<20 && ${Unit[AttackGUID].PctHPs}>50) || (${Me.PctHPs}<20 && ${Aggros.Count}>4)
		{ 
			call Debug "I have ${Aggros.Count} Aggro mobs. Muuuummmyy" 
			RLG:Set[TRUE] 
			return 
		}
		Aggros:Clear
	
		; Check if we have pulled yet and if not do so.
		if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled}
		{
			if ${RangedMode}
				if !${Spell[Pull Spell].Cooldown}&&!${Unit[${AttackGUID}].Buff[Pull Spell](exists)}
					call CastSpell "Pull Spell"
			
			HavePulled:Set[TRUE]
		}

		if ${RangedMode}
		{
			; If our target is in ranged attack range turn on Ranged Spell
			if ${Target(exists)}&&!${Me.Action[Ranged Spell].Cooldown}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist}&&${Unit[${AttackGUID}].Distance}>${RangedMinDist}
			{
				call CastSpell "Ranged Spell"
			}
		
		}
		else
		{
			; Once our target is in range and were not in ranged mode turn on attack
			if !${Me.Attacking}&&${Target(exists)}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
			{
				WoWScript AttackTarget()
			}
		
		}


		; Start main attack routine
		if (${PullBeforeContinue}&&${HavePulled})||!${PullBeforeContinue}
		{
			if ${RangedMode}
			{
				if !${Spell[Ranged Spell].Cooldown}
					call CastSpell "Ranged Spell"
			}
			else
			{
				if !${Spell[Melee Spell].Cooldown}
					call CastSpell "Melee Spell"
			}
		}	
				
		;If too far away run forward
		if ((${RangedMode} && ${Unit[${AttackGUID}].Distance}>${RangedMaxDist}) || !${RangedMode} && ${Unit[${AttackGUID}].Distance}>${CombatMaxDist})&&!${Me.Casting}
		{
			debug("Too far closing")
			;press and hold the forward button 
			wowpress -release movebackward
			wowpress -hold moveforward
		}

		;If too close then run backward
		if !${RangedMode}&&${Unit[${AttackGUID}].Distance}<${CombatMinDist}&&!${Me.Casting}
		{
			debug("Too close backing up")
			;press and hold the backward button 
			wowpress -release moveforward
			wowpress -hold movebackward
		}
		
		;If we are close enough stop running
		if (${RangedMode}&&${Unit[${AttackGUID}].Distance}>${RangedMinDist}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist})||(!${RangedMode}&&${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}) ||${Me.Casting}
		{
			wowpress -release moveforward
			wowpress -release movebackward
			StuckCheck:Set[FALSE]
		}
		
		;wait for half a second to give our pc a chance to move
		wait 5
		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&((!${RangedMode}&&${Unit[${AttackGUID}].Distance}>${CombatMaxDist}) || (${RangedMode}&&${Unit[${AttackGUID}].Distance}>${RangedMaxDist})) 
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


function Downtime()
{

; If your a Mage you might want to summon food here.
;
/*
	if ${Me.CurrentMana}>${Spell[Conjure Water].Mana} 
	{
		call CastSpell "Conjure Water" ${Me.GUID} 
	}

	if ${Me.CurrentMana}>${Spell[Conjure Food].Mana} 
	{
		call CastSpell "Conjure Food" ${Me.GUID} 
	}
*/



; Do I need to rest?
;
; Heres an example for a caster
/*
	while (${Me.PctHPs} < ${MinHealthPct} || ${Me.PctMana} < ${MinManaPct}) && !${Me.InCombat} && !${Me.Dead} && !${Me.Ghost}
	{
		if ${SitWhenRest} && !${Me.Sitting}
		{
			wowpress SITORSTAND
		}
		
		if !${Me.Buff[Drink](exists)} && (${Me.CurrentMana} < ${Me.MaxMana}-150)
		{
			call Drink
			wait 40 ${Me.Buff[Drink](exists)}
		}

		if !${Me.Buff[Food](exists)} && (${Me.CurrentHPs} < ${Me.MaxHPs}-100)
		{
			call Eat
			wait 40 ${Me.Buff[Food](exists)}
		}
	
		waitframe

	}
*/
;
;
; And for a non caster
/*
	while ${Me.PctHPs} < ${MinHealthPct} && !${Me.InCombat} && !${Me.Dead} && !${Me.Ghost}
	{
		if ${SitWhenRest} && !${Me.Sitting}
		{
			wowpress SITORSTAND
		}

		if !${Me.Buff[Food](exists)} && (${Me.CurrentHPs} < ${Me.MaxHPs}-100)
		{
			call Eat
			wait 40 ${Me.Buff[Food](exists)}
		}

		waitframe
	}

*/

	;Make sure we are stood up.
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}

	; Check durability
	call CheckDurability

	; Reset downtime flag
	DoDowntime:Set[FALSE]
}
