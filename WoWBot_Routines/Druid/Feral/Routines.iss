; Warrior Routines
; Beaky_Buzzard with code stolen from everyone!

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES
#define DRUID_NORMAL 0
#define DRUID_CATFORM 1
#define DRUID_BEARFORM 2
#define PATROL_STEALTH 1
#define STEALTH_PULL Ravage
#define COMBAT_SHAPE DRUID_BEARFORM
#define FINISH_POINTS 5
;
; The CombatPrep function is called once you have selected a target but before you enter combat.
;
function CombatPrep()
{
	if PATROL_STEALTH && COMBAT_SHAPE==DRUID_CATFORM
	{
		call CastSpell "Prowl"
	}
	
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
		if !${Me.Attacking}&&${Target(exists)}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}&&!${Me.Buff[Prowl](exists)}
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

		if COMBAT_SHAPE==DRUID_CATFORM
		{
			if ${Me.Buff[Prowl](exists)}
			{
				call MoveBehind 2
				call CastSpell "STEALTH_PULL" ${Target.GUID}
			}
		
			if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&${WoWScript[GetComboPoints()]}>=FINISH_POINTS
			{
				call CastSpell "Ferocious Bite"  ${Target.GUID}
			}

			elseif ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&${Target.PctHPs}<15&&${WoWScript[GetComboPoints()]}>3
			{
 			       call CastSpell "Ferocious Bite"  ${Target.GUID}
			} 

			if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&!${Unit[${Target.GUID}].Buff[Rake](exists)}
			{
				call CastSpell "Rake" ${Target.GUID}
			}

			if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>40
			{
				call CastSpell "Claw"  ${Target.GUID}
			}

			; buffs
			if !${Unit[${AttackGUID}].Buff[Faerie Fire (Feral)](exists)} && !${Spell[Faerie Fire (Feral)].Cooldown} && ${Spell[Faerie Fire (Feral)](exists)}
			{
				call CastSpell "Faerie Fire (Feral)" ${AttackGUID}
			}
		}
			
		elseif COMBAT_SHAPE==DRUID_BEARFORM
		{
			HavePulled:Set[TRUE]

			; Starting Attack Routine...
			Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-20]
			if ${Aggros.Count}>1
			{
				if !${Spell[Swipe].Cooldown} && ${Me.CurrentRage}>15
				{
					call CastSpell "Swipe" ${AttackGUID}
				}
				if !${MovedBackMulti}
				{
					call UpdateHudStatus "Moving back to get swipe working."
					wowpress -hold movebackward
					wait 15
					wowpress -release movebackward
					wait 10
					MovedBackMulti:Set[TRUE]
				}
			}
			else
			{
				if !${Spell[Maul].Cooldown} && ${Me.CurrentRage}>10
				{
					call CastSpell "Maul" ${AttackGUID}
				}
			}

			; buffs
			if !${Unit[${AttackGUID}].Buff[Faerie Fire (Feral)](exists)} && !${Spell[Faerie Fire (Feral)].Cooldown} && ${Spell[Faerie Fire (Feral)](exists)}
			{
				call CastSpell "Faerie Fire (Feral)" ${AttackGUID}
			}
			if ${Me.PctHPs}>80&&!${Spell[Enrage].Cooldown}
			{
				call CastSpell "Enrage" ${AttackGUID}
			}
			if !${Unit[${AttackGUID}].Buff[Demoralizing Roar](exists)}&&${Me.CurrentRage}>10
			{
				call CastSpell "Demoralizing Roar" ${AttackGUID}
			}
			if ${Me.PctHPs}<30 && !${Spell[Frenzied Regeneration].Cooldown}
			{
				call CastSpell "Frenzied Regeneration" ${AttackGUID}
			}

			if ${Me.PctHPs}<20 && !${Spell[Bash].Cooldown}
			{
				call CastSpell "Bash" ${AttackGUID}
			}
		}
	 
		
		; Check if we wish to flee combat or not
		Aggros:Search[-units,-nearest,-aggro,-alive, -range 0-${Math.Calc[${MaxRoam}/2]}]
		if (${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]})||(${Aggros.Count}>${PanicThreshold}&&(${Me.PctHPs}<40||((${Me.PctHPs}<30&&${Me.PctMana}<10)&&${Unit[AttackGUID].PctHPs}>30))
		{
			call Debug "I have ${Aggros.Count} Aggro mobs. Muuuummmyy"
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
	if ${Me.PctHPs}<${MinHealthPct} || !${Me.Buff[Thorns](exists)} || (!${Me.Buff[Mark of the Wild](exists)} && !${Me.Buff[Gift of the Wild](exists)}) || (!${Me.Buff[Cat Form](exists)} && !${Me.Buff[Bear Form](exists)} && !${Me.Buff[Dire Bear Form](exists)})
	{
		Me.Buff[Cat Form]:Remove
		Me.Buff[Bear Form]:Remove
		Me.Buff[Dire Bear Form]:Remove
		wait 10
	}
	else
	{
		; Reset downtime flag
		DoDowntime:Set[FALSE]
		return
	}

	if ${Me.PctHPs}<${MinHealthPct}
	{
		call CheckDurability
		wait 10
		call CastSpell "Healing Touch" ${Me.GUID}
		wait 10
	}
 
	if !${Me.Buff[Thorns](exists)}
	{
		call CastSpell "Thorns" ${Me.GUID}
		wait 10
 	}
	if !${Me.Buff[Mark of the Wild](exists)} && !${Me.Buff[Gift of the Wild](exists)}
	{
		call CastSpell "Mark of the Wild" ${Me.GUID}
		wait 10
	}

	if COMBAT_SHAPE==DRUID_CATFORM
	{
		call CastSpell "Cat Form" ${Me.GUID}
		wait 10
	}

	if COMBAT_SHAPE==DRUID_BEARFORM
	{
		if ${Spell[Dire Bear Form](exists)}
			call CastSpell "Dire Bear Form" ${Me.GUID}
		else
			call CastSpell "Bear Form" ${Me.GUID}
		wait 10
	}

	; Reset downtime flag
	DoDowntime:Set[FALSE]
}

function MoveBehind(float Precision)
{
   declare PointX float local
   declare PointY float local
   declare degrees float local
   declare SavX float local ${X}
   declare SavY float local ${Y}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
   
   call UpdateHudStatus "Attempting to move behind target."
   ;Check that we are not already there!
   if "${Math.Distance[${Me.X},${Me.Y},${PointX},${PointY}]}>${Precision}"
   {
      Do
      {   
         degrees:Set[${Target.Heading.DegreesCCW}+180]
         ;The number below, the Precision, and the movement of the mob will determine the distance
         PointX:Set[${Math.Calc[1.5*${Math.Cos[${degrees}].Milli}+${Target.X}]}]
         PointY:Set[${Math.Calc[1.5*${Math.Sin[${degrees}].Milli}+${Target.Y}]}]
         
         ;press and hold the forward button
         ;wowpress -hold moveforward
         move forward
         
         ;ensure we are still facing our target loc
         Face -fast  ${PointX} ${PointY}
         ;wait for half a second to give our pc a chance to move
         wait 5
         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Me.X}==${SavX}&&${Me.Y}==${SavY}
         {
            call Obstacle
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
      }
      while "(${Math.Distance[${Me.X},${Me.Y},${PointX},${PointY}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})"
      
      ;Made it to our target loc
      move -stop
      waitframe
      face -fast ${Target.X} ${Target.Y}
   }
}