; Warrior Routines
; Beaky_Buzzard with code stolen from everyone!

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES
#define USE_REND 1
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
	
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*${CombatBailout})]}
	declare HavePulled bool local FALSE
	declare StuckCheck bool local FALSE
	declare StuckCheckCount int local 0
	declare StuckCheckTime int local
	declare Aggros guidlist local
	declare MovedBackMulti bool local FALSE
	
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
			#ifdef DEBUG
				call Debug "Targeting Unit ${Unit[${AttackGUID}].Distance}[${AttackGUID}]"
			#endif
			Target ${AttackGUID}
			wait 10
		}
		
		; Once our target is in range turn on attack
		if !${Me.Attacking}&&${Target(exists)}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
		{
			WoWScript AttackTarget()
		}

		; Check we havent picked up an aggro other than the mob we have targeted.
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10]
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			debug("Untargeted Unit ${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine")
			return
		}
		Aggros:Clear
		
		; Check if we have pulled yet and if not do so.
		if ${Unit[${AttackGUID}].Distance}<25&&!${HavePulled}
		{
			if ${Spell[Charge](exists)}&&${Unit[${AttackGUID}].Distance}<25&&${Unit[${AttackGUID}].Distance}>10
			{
				call CastSpell "Charge" ${Target.GUID}
			}
			HavePulled:Set[TRUE]
		}


		; Start main attack routine
		if (${PullBeforeContinue}&&${HavePulled})||!${PullBeforeContinue}
		{
			if ${Unit[${AttackGUID}].Distance}<5&& ${Me.CurrentRage}>5 && ${Me.Action[Revenge].Usable}
			{
				call CastSpell "Revenge" ${AttackGUID}
			}
			if ${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentRage}>5 && ${Me.Action[Overpower].Usable}
			{
				call CastSpell "Overpower" ${AttackGUID}
			}
			if ${Unit[${AttackGUID}].Distance}<5 && !${Spell[Execute].Cooldown} && ${Me.CurrentRage}>=15 && ${Unit[${AttackGUID}].PctHPs}<20
			{
				call CastSpell "Execute" ${AttackGUID}
			}

			Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-20]
			if ${Aggros.Count}>1
			{
				; Multi Target Attack

				if !${Spell[Sweeping Strikes].Cooldown} && ${Me.CurrentRage}>30 && ${Spell[Sweeping Strikes].Usable}
				{
					call CastSpell "Sweeping Strikes" ${AttackGUID}
				}
				if !${Unit[${AttackGUID}].Buff[Demoralizing Shout](exists)}&&!${Spell[Demoralizing Shout].Cooldown}&&${Unit[${AttackGUID}].Distance}<13&&${Me.CurrentRage}>=10
				{
					call CastSpell "Demoralizing Shout" ${AttackGUID}
				}
				if !${Unit[${AttackGUID}].Buff[Thunder Clap](exists)}&&!${Spell[Thunder Clap].Cooldown}&&${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentRage}>=20 && ${Spell[Thunder Clap].Usable}
				{
					call CastSpell "Thunder Clap" ${AttackGUID}
				}
				if !${Spell[Whirlwind].Cooldown} && ${Me.CurrentRage}>=25 && ${Spell[Whirlwind].Usable}
				{
					call CastSpell "Whirlwind" ${AttackGUID}
				}
				if !${Spell[Cleave].Cooldown} && ${Me.CurrentRage}>=20
				{
					call CastSpell "Cleave" ${AttackGUID}
						}
					if !${MovedBackMulti}
					{
						call UpdateHudStatus "Moving back to get cleave working."
						wowpress -hold movebackward
						wait 15
						wowpress -release movebackward
						wait 10
						MovedBackMulti:Set[TRUE]
				}
				if ${Spell[Shield Block].Cooldown} && ${Me.CurrentRage}>55 && ${Spell[Shield Block].Usable}
				{
					call CastSpell "Shield Block" ${AttackGUID}
				}
			}
			else
			{
				; Single Target Attack

				if ${Target.Casting.ID(exists)} && ${Spell[Shield Bash].Cooldown} && ${Spell[Shield Bash].Usable} && ${Me.CurrentRage}>=10
				{
					call CastSpell "Shield Bash" ${AttackGUID}
				}
					
				if ${Unit[${AttackGUID}].Distance}<5 && !${Unit[${AttackGUID}].Buff[Hamstring](exists)} && ${Me.Action[Hamstring].Usable} && ${Me.CurrentRage}>=10
				{
					call CastSpell "Hamstring" ${AttackGUID}
				}
				if !${Unit[${AttackGUID}].Buff[Rend](exists)} && ${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentRage}>10 && ${Me.Action[Rend].Usable} && USE_REND && ${Unit[${AttackGUID}].CreatureType.NotEqual[Mechanical]} && ${Unit[${AttackGUID}].CreatureType.NotEqual[Elemental]}
				{
					call CastSpell "Rend" ${AttackGUID}
				}
				if !${Spell[Shield Slam].Cooldown}&&${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentRage}>=30 && ${Me.Action[Shield Slam].Usable}
				{
					call CastSpell "Shield Slam" ${AttackGUID}
				}
				if !${Spell[Bloodthirst].Cooldown}&&${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentRage}>=30 && ${Me.Action[Bloodthirst].Usable}
				{
					call CastSpell "Bloodthirst" ${AttackGUID}
				}
				if !${Spell[Mortal Strike].Cooldown}&&${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentRage}>=30 && ${Me.Action[Mortal Strike].Usable}
				{
					call CastSpell "Mortal Strike" ${AttackGUID}
				}
				if !${Spell[Shield Block].Cooldown} && ${Me.CurrentRage}>55 && ${Spell[Shield Block].Usable}
				{
					call CastSpell "Shield Block" ${AttackGUID}
				}
				if !${Spell[Heroic Strike].Cooldown} && ${Unit[${AttackGUID}].PctHPs}>90 && ${Me.CurrentRage}>55
				{
					call CastSpell "Heroic Strike" ${AttackGUID}
				}
			}

			if ${Me.PctHPs}<40 && !${Spell[Concussion Blow].Cooldown} && ${Spell[Concussion Blow].Usable} && ${Me.CurrentRage}>=15
			{
				call CastSpell "Concussion Blow" ${AttackGUID}
			}

			if ${Me.PctHPs}<30 && !${Spell[Disarm].Cooldown} && ${Me.CurrentRage}>=20 && ${Spell[Disarm].Usable}
			{
				call CastSpell "Disarm" ${AttackGUID}
			}

			if ${Me.PctHPs}<10 && !${Spell[Last Stand].Cooldown} && ${Spell[Last Stand](exists)}
			{
				call CastSpell "Last Stand" ${AttackGUID}
			}

			; buffs
			if ${Unit[${AttackGUID}].PctHPs}>80&&!${Spell[Bloodrage].Cooldown}
			{
				call CastSpell "Bloodrage" ${AttackGUID}
			}
			if !${Me.Buff[Battle Shout](exists)}&&${Me.CurrentRage}>=10
			{
				call CastSpell "Battle Shout" ${AttackGUID}
			}
		}		 
		
		; Check if we wish to flee combat or not
		Aggros:Search[-units,-nearest,-aggro,-alive, -range 0-${Math.Calc[${MaxRoam}/2]}]
		if (${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]})||(${Aggros.Count}>${PanicThreshold}&&(${Me.PctHPs}<40||((${Me.PctHPs}<30&&${Me.PctMana}<10)&&${Unit[AttackGUID].PctHPs}>30))
		{
			call Debug "I have ${Aggros.Count} Aggro mobs. Muuuummmyy"
			if ${Me.CurrentRage}>25&&!${Spell[Bloodrage].Cooldown}
			{
				call CastSpell "Intimidating Shout" ${AttackGUID}
			}
			if !${Spell[Bloodrage].Cooldown}&&${Me.CurrentRage}>15 && !${Spell[Intimidating Shout].Cooldown}
			{
				call CastSpell "Bloodrage" ${AttackGUID}
				call CastSpell "Intimidating Shout" ${AttackGUID}
			}
			RLG:Set[TRUE]
			return
		}
		Aggros:Clear
		
		;If too far away run forward
		if ${Unit[${AttackGUID}].Distance}>${CombatMaxDist}&&!${Me.Casting}
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
		
		;wait for half a second to give our pc a chance to move
		wait 5
		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
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
		if ${StuckCheckCount}>10
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
	if ${Me.PctHPs}<${MinHealthPct}
	{
		call CheckDurability
		while ${Me.PctHPs}<99&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}
		{
			if ${SitWhenRest} && !${Me.Sitting}
			{
				wowpress SITORSTAND
			}

			if ${Me.PctHPs}<45 && !${Me.Buff[Food](exists)}
			{
				call Eat
				wait 40 ${Me.Buff[Food](exists)}
			}

			waitframe 
		}
	}
 
	;Make sure we are stood up.
	if ${Me.Sitting}
	{
		wowpress SITORSTAND
	}
 
	; Reset downtime flag
	DoDowntime:Set[FALSE]
}