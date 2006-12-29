; Warrior Routines
; Originally Tenshi, Beaky_Buzzard, various others.
; Almost Entirely rewritten for xp and PVP warrior play, there's very little defensive stance use.
; The bot will charge, switch stances, intercept, use berserker rage if available when feared.
; It keeps hamstring up and maximizes dps by using overpower, mortal strike or bloodthirst when available.
; There are a number of fixes to check for targets getting out of range and whatnot missing in the originals

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
	;debug("In Attack function")
	wait 10
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
		
    if !${Me.Buff[Battle Stance](exists)} && !${Me.InCombat} && ${Me.Action[Battle Stance].Usable}
    {
      ;debug("Switching to Battle Stance at start of Attack()")
      Cast "Battle Stance"
      debug("Battle Stance: ${Me.Buff[Battle Stance](exists)}")
      waitframe
    }

		; Ensure we are still facing our target loc
		call SmartFacePrecision ${Object[${AttackGUID}].X} ${Object[${AttackGUID}].Y}
		
		; Check we still have a valid target
		if !${Object[${AttackGUID}](exists)}
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
		if !${Target.GUID.Equal[${AttackGUID}]}&&${Object[${AttackGUID}].Distance}<${TargetingRange}
		{
			;debug("Targeting ${Object[${AttackGUID}].Name} at distance ${Object[${AttackGUID}].Distance}")
			Target ${AttackGUID}
		}
		
		; Once our target is in range turn on attack
		if !${Me.Attacking}&&${Target(exists)}&&${Object[${AttackGUID}].Distance}<${TargetingRange}
		{
			WoWScript AttackTarget()
		}

		; Check we havent picked up an aggro other than the mob we have targeted.
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10]
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			;debug("Untargeted Unit ${Object[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine")
			return
		}
		Aggros:Clear
		if ${Object[${AttackGUID}].Distance} < 25 && !${HavePulled}
		{
		  ;debug("Checking for pulling ability.")
			if ${Spell[Charge](exists)} && ${Target.Distance} < 25 && ${Target.Distance} > 8 && !${Me.InCombat}
			{
				if !${Me.Buff[Battle Stance](exists)}
				{
				  debug("Switching to Battle Stance to charge...")
				  Cast "Battle Stance"
				  waitframe
				}
				;debug("Charging ${Target} at range ${Target.Distance} -  Combat State: ${Me.InCombat}")
				Cast "Charge"
			}
			HavePulled:Set[TRUE]
		}

		; Start main attack routine
		if (${PullBeforeContinue}&&${HavePulled})||!${PullBeforeContinue}
		{
			Aggros:Search[-players,-units,-hostile,-nearest,-aggro,-alive,-range 0-8]
			if (${Target.Class.Equal[Priest]} || ${Target.Class.Equal[Warlock]}) && !${Me.Buff[Berserker Stance](exists)}
			{
			  Cast "Berserker Stance"
			}
			if (${Me.Buff[Psychic Scream](exists)} || ${Me.Buff[Intimidating Shout](exists)} || ${Me.Buff[Fear](exists)} || ${Me.Buff[Howl of Terror](exists)}) && ${Me.Buff[Berserker Stance](exists)} && ${Me.Action[Berserker Rage].Usable} && !${Spell[Berserker Rage].Cooldown}
			{
			  cast "Berserker Rage"
			}
			;debug("Aggro Count: ${Aggros.Count}")
		  if (${Me.Buff[Battle Stance](exists)} || ${Me.Buff[Berserker Stance](exists)}) && ${Target.Distance} < 5
		  {
		    ;debug("Checking for execute or hamstring... line 117")
			  if ${Target.PctHPs} < 20 && ${Me.CurrentRage} > 15 && ${Me.Action[Execute].Usable} && !${Spell[Execute].Cooldown}
			  {
			    ;debug("Executing")
			    Cast "Execute"
			  }
			  ;debug("Decided not to execute, checking Hamstring... line 123")
			  if ${Me.CurrentRage} > 7 && ${Me.Action[Hamstring].Usable} && !${Spell[Hamstring].Cooldown} && !${Object[${AttackGUID}].Buff[Hamstring](exists)}
			  { 
			    ;debug("Hamstringing")
			    Cast "Hamstring"
			  }
			}
			if ${Me.Action[Bloodrage].Usable} && !${Spell[Bloodrage].Cooldown} && ${Me.InCombat}
			{
				;debug("Casting Bloodrage")
				Cast "Bloodrage"
		  }

			if ${Me.Buff[Battle Stance](exists)}
			{
			  ;debug("Checking for Overpower... line 138")
			  if ${Me.Action[Overpower].Usable} && !${Spell[Overpower].Cooldown} && ${Target.Distance} < 5 && ${Me.CurrentRage} > 5
			  {
			    ;debug("Overpowering")
			    Cast "Overpower"
			  }
			  ;debug("Overpower Not ready")
      }
      ;debug("Deciding to intercept or not...")
      if ${Me.InCombat} && ${Target.Distance} < 25 && ${Target.Distance} > 7 && ${Me.CurrentRage} > 9 && !${Spell[Intercept].Cooldown}
      {
        ;debug("Checking for Intercept... line 149")
        if !${Me.Buff[Berserker Stance](exists)}
        {
          ;debug("Switching to Berserker Stance... line 134")
          call CastSpell "Berserker Stance"
          waitframe
        }
        ;debug("Intercepting ${Target} at Distance ${Target.Distance}")
        call CastSpell "Intercept"
      }
      ;debug("Deciding to cleave or not")
      if ${Aggros.Count} == 2 && !${Spell[Cleave].Cooldown} && ${Me.CurrentRage} > 19 && ${Target.Distance} < 5
      {
        ;debug("Cleaving...")
        call CastSpell "Cleave"
      }
      ;debug("Deciding to whirlwind or not...")
      if ${Aggros.Count} > 2 && !${Spell[Whirlwind].Cooldown} && ${Me.CurrentRage} > 24 && ${Target.Distance} < 5 && ${Me.Action[Whirlwind].Usable}
      {
        ;debug("Aggros.Count > 2, going to whirlwind...")
        if !${Me.Buff[Berserker Stance](exists)}
        {
          ;debug("Casting Berserker Stance... line 153")
          Cast "Berserker Stance"
        }
        ;debug("Whirlwinding...")
        Cast "Whirlwind"
      }
      ;debug("Deciding to Mortal Strike or not... line 177")
		  if ${Me.Action[Mortal Strike].Usable} && !${Spell[Mortal Strike].Cooldown} && ${Target.Distance} < 5 && ${Me.CurrentRage} > 30
		  {
	      Cast "Mortal Strike"
	    }
	    ;debug("Deciding to Bloodthirst or not")
		  if ${Me.Action[Bloodthirst].Usable} && !${Spell[Bloodthirst].Cooldown} && ${Target.Distance} < 5 && ${Me.CurrentRage} > 30
		  { 
	      Casts "Bloodthirst"
	    }
	    ;debug("Deciding to Rend or not")
			if !${Object[${AttackGUID}].Buff[Rend](exists)} && ${Object[${AttackGUID}].Distance} < 5 && ${Me.CurrentRage} > 10 && !${Me.Action[Rend].Cooldown} && USE_REND && ${Object[${AttackGUID}].CreatureType.NotEqual[Mechanical]} && ${Object[${AttackGUID}].CreatureType.NotEqual[Elemental]}
			{
				call CastSpell "Rend"
		  }

			;debug("Thinking about defensive stance stuff...")
		  if ${Me.Buff[Defensive Stance](exists)}
		  {
			  if ${Me.PctHPs} < 40 && !${Spell[Concussion Blow].Cooldown} && ${Me.CurrentRage} >= 15 
			  {
  				call CastSpell "Concussion Blow"
  		  }
  			if ${Me.PctHPs} < 50 && !${Spell[Disarm].Cooldown} && ${Me.CurrentRage} >= 20
  			{
	  			call CastSpell "Disarm"
	  	  }
  			if ${Me.PctHPs} < 20 && !${Spell[Shield Wall].Cooldown}
  			{
	  			call CastSpell "Shield Wall"
	  		}
			}
			;debug("Deciding to last stand or not...")
			if ${Me.PctHPs} < 15 && !${Spell[Last Stand].Cooldown} && ${Me.Action[Last Stand].Usable}
			{
				Cast "Last Stand"
		  }

			; buffs
			;debug("Deciding to battle shout or not")
			if !${Me.Buff[Battle Shout](exists)} && ${Me.CurrentRage}>=10 && !${Spell[Battle Shout].Cooldown} && ${Me.Action[Battle Shout].Usable}
			{
				call CastSpell "Battle Shout"
		  }
		}		 
		
		; Check if we wish to flee combat or not
		;debug("Deciding to flee or not...")
		Aggros:Search[-units,-nearest,-aggro,-alive, -range 0-${Math.Calc[${MaxRoam}/2]}]
		;debug("Aggros.Count: ${Aggros.Count}")
		if (${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]})||(${Aggros.Count}>${PanicThreshold}&&(${Me.PctHPs}<40||((${Me.PctHPs}<30&&${Me.PctMana}<10)&&${Object[AttackGUID].PctHPs}>30))&&!${Target.Type.Equals[Player]}
		{
			call Debug "I have ${Aggros.Count} Aggro mobs. Muuuummmyy"
			if ${Me.CurrentRage}>25&&!${Spell[Bloodrage].Cooldown}
			{
				call CastSpell "Intimidating Shout"
			}
			if !${Spell[Bloodrage].Cooldown}&&${Me.CurrentRage}>15 && !${Spell[Intimidating Shout].Cooldown}
			{
				call CastSpell "Bloodrage"
				call CastSpell "Intimidating Shout" 
			}
			RLG:Set[TRUE]
			return
		}
		Aggros:Clear
		
		;If too far away run forward
		if ${Target.Distance} > ${CombatMaxDist} && !${Me.Casting}
		{
			;debug("Too far closing")
			;press and hold the forward button
			wowpress -release movebackward
			wowpress -hold moveforward
		}

		;If too close then run backward
		if ${Object[${AttackGUID}].Distance}<${CombatMinDist}&&!${Me.Casting}
		{
			;debug("Too close backing up")
			;press and hold the backward button
			wowpress -release moveforward
			wowpress -hold movebackward
		}
		
		;If we are close enough stop running
		if (${Object[${AttackGUID}].Distance}>${CombatMinDist}&&${Object[${AttackGUID}].Distance}<${CombatMaxDist})||${Me.Casting}
		{
			wowpress -release moveforward
			wowpress -release movebackward
			StuckCheck:Set[FALSE]
		}
		
		;wait for half a second to give our pc a chance to move
		wait 2
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Object[${AttackGUID}].Distance}>${CombatMaxDist}
		{
			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				;debug("I might be stuck")
				StuckCheck:Set[TRUE]
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			}
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>8000
				{
					;debug("Yep I am stuck trying to free myself")
					call Obstacle
					StuckCheckCount:Inc
					StuckCheck:Set[FALSE]
				}
			}
		}
		; If I have moved away from my saved spot reset my stuck toggle
		if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
		{
			;debug("I am no longer stuck")
			StuckCheck:Set[FALSE]
			StuckCheckCount:Set[0]
		}
		;If I am stuck too many times then quit.
		if ${StuckCheckCount}>10
		{
			;debug("Got stuck to often")
			call ExitGame
		}
		; Check if we have exceeded bail out timer and the mob is still at full health
		if ${LavishScript.RunningTime}>${BailOut}&&${Object[${TargetGUID}].PctHPs}>99
		{
			GUIDBlacklist:Set[${TargetGUID},AVOID]
			call UpdateHudStatus "Combat timeout reached"
			TargetGUID:Set[NOTARGET]
			return
		}
	  if ${Object[${AttackGUID}](exists)} && !${Me.Dead} && ${Object[${AttackGUID}].Distance} > 100
	  {
	    if ${Target(exists)} 
	    {
	      Press Esc
	    }
	    TargetGUID:Set[NOTARGET]
	    AttackGUID:Set[NOTARGET]
	    call SetAdvancePath
	    return
	  }
	}
	while !${Me.Dead} && ${Object[${AttackGUID}].Distance} < 100 && !${Object[${AttackGUID}].Dead}
	if !${Me.Dead}
	{
		call UpdateStats
	}
	wowpress -release movebackward
	wowpress -release moveforward
	;Reset flags to do combat prep and downtime if we are not still aggroed
	Aggros:Search[-players,-units,-hostile,-nearest,-aggro,-alive,-range 0-50]
	if !${Aggros.Count}
	{
		;debug("Resetting Downtime and CombatPrep Flags")
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