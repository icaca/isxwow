;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Original Author: steelx01 ;
; Current Author: Tenshi    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rogue Script Configurable Options ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Poison Type: Instant, Wound, Deadly, Mind-numbing, Crippling
#define POISON_TYPE "Instant"

; Number of combo points to use finishing move with
#define FINISH_POINTS 5

; Where or not to use stealth on patrol: TRUE or FALSE
#define PATROL_STEALTH TRUE

; Stealth pull attack: Cheap Shot or Garrote
#define STEALTH_PULL "Cheap Shot"

; Health Percent to cast Adrenaline
#define ADRENALINE_HPPCT 40

function RogueDebug(string Text)
{
	;echo [${Time.Time24}] ROGUEDEBUG: ${Text}
	;redirect -append roguedebug.txt echo [${Time.Time24}] ROGUEDEBUG: ${Text}
}

function SelectPoison()
{

	call UpdateHudStatus "Selecting Poison"
	call RogueDebug "Selecting Poison"

	declare PoisonType string POISON_TYPE

	if ${Item[${PoisonType} Poison VI](exists)}
	{
		return "${PoisonType} Poison VI"
	}

	if ${Item[${PoisonType} Poison V](exists)}
	{
		return "${PoisonType} Poison V"
	}

	if ${Item[${PoisonType} Poison IV](exists)}
	{
		return "${PoisonType} Poison IV"
	}

	if ${Item[${PoisonType} Poison III](exists)}
	{
		return "${PoisonType} Poison III"
	}

	if ${Item[${PoisonType} Poison II](exists)}
	{
		return "${PoisonType} Poison II"
	}

	if ${Item[${PoisonType} Poison](exists)}
	{
		return "${PoisonType} Poison"
	}
}

function CombatPrep()
{

	if PATROL_STEALTH
	{
		call RogueDebug "Going into stealth"
		call CastSpell "Stealth"
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
	declare StuckCheckTime int local
	declare Aggros guidlist local
	declare ObstacleCheckTimer bool local TRUE
	declare PoisonOfChoice string
	
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
			waitframe
		}

		
		if !${Me.Attacking}&&${Target(exists)}&&!${Me.Buff[Stealth](exists)}
		{
			WoWScript AttackTarget()
		}

		; Check we havent picked up aggro
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-20]
		if ${Aggros.Count}>0
		{
			if ${Aggros.Count}>3
			{
				RLG:Set[TRUE]
				call CastSpell "Vanish"
				return
			}
			if ${Aggros.Count}>1&&!${Spell[Evasion].Cooldown}
			{
				Call CastSpell "Evasion"
			}
			if ${Aggros.Count}>1&&!${Spell[Adrenaline Rush].Cooldown}
			{
				call CastSpell "Adrenaline Rush"
			}
		}
		Aggros:Clear
	

		if ${Target.Distance} >= ${CombatMaxDist}
		{
			call SmartFacePrecision ${Target.X} ${Target.Y}
			move forward
			do
			{
        	
				call SmartFacePrecision ${Target.X} ${Target.Y}
				move forward
				WaitFrame
			}
			while ${Target.Distance}>= ${CombatMaxDist}

			move -stop forward

			;wait for half a second to give our pc a chance to move
			wait 5
		}


		if ${Unit[${AttackGUID}].Distance}<${CombatMinDist}
		{
			#ifdef DEBUG
			call Debug "Too close backing up"
			#endif
			;press and hold the backward button 
			wowpress -release moveforward
			wowpress -hold movebackward
			wait 3
		}

		;If we are close enough stop running
		if ${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}
		{
			wowpress -release moveforward
			wowpress -release movebackward
			StuckCheck:Set[FALSE]
		}

		if ${Me.Buff[Stealth](exists)}
		{
			call CastSpell STEALTH_PULL ${Target.GUID}
		}

		if "${Unit[${AttackGUID}].Distance}<5 && ${Me.CurrentEnergy}>10 && ${Spell[Riposte](exists)} && !${Spell[Riposte].Cooldown}"
		{ 
			call CastSpell "Riposte" 
		}

		if ${Unit[${AttackGUID}].Distance}<5&&${Target.Casting.ID(exists)}&&${Me.CurrentEnergy}>25
		{
			call CastSpell "Kick" ${Target.GUID}
		}

		if ${Unit[${AttackGUID}].Distance}<5&&${Target.PctHPs}>75&&!${Spell[Blade Flurry].Cooldown}&&${Me.CurrentEnergy}>25&&${Spell[Blade Flurry](exists)}
		{
			call CastSpell "Blade Flurry"
		}

   		if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&${WoWScript[GetComboPoints()]}>=FINISH_POINTS
	        {
			if !${Spell[Cold Blood].Cooldown}
			{
				call CastSpell "Cold Blood"
				wait 10
			}
			call CastSpell "Eviscerate"  ${Target.GUID}
                }

		elseif ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&${Target.PctHPs}<15&&${WoWScript[GetComboPoints()]}>3
		{
	 	       call CastSpell "Eviscerate"  ${Target.GUID}
                } 

		if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>40
		{
			call CastSpell "Sinister Strike"  ${Target.GUID}
		}

		if ${Unit[${AttackGUID}].Distance}<5&&${Me.CurrentEnergy}>35&&${WoWScript[GetComboPoints()]}>=FINISH_POINTS
		{
			call CastSpell "Eviscerate"  ${Target.GUID}
		}

		if ${Me.PctHPs}<ADRENALINE_HPPCT
		{
			call CastSpell "Adrenaline Rush"
		}

		if ${Unit[${AttackGUID}].Distance}<5&&${Me.PctHPs}<=15&&${Target.PctHPs}>=45
		{
			RLG:Set[TRUE]
			call CastSpell "Vanish"  ${Target.GUID}
			return
		}

		;if ${Me.PctHPs}<25
		;	call DrinkBestHealingPotion
		
		if ${ObstacleCheckTimer}
		{
			; Check to make sure we have moved since the last check and if not then try and avoid the
			; obstacle thats in our path
			;if ${Math.Calc[${Me.X}-${SavX}]}<1&&${Math.Calc[${Me.Y}-${SavY}]}<1&&${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
			if ${Math.Distance[${Me.X},${Me.Y},${SavX},${SavY}]}<1 && ${Unit[${AttackGUID}].Distance}>${CombatMaxDist}
			{
				; I think i might be stuck so save off the current time
				if !${StuckCheck}
				{
					#ifdef DEBUG
						call Debug "I might be stuck"
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
							call Debug "Yep I am stuck trying to free myself"
						#endif
						call Obstacle
						StuckCheck:Set[FALSE]
					}
				}
			}
			
			; If I have moved away from my saved spot reset my stuck toggle
			if ${StuckCheck}&&${Math.Calc[${Me.X}-${SavX}]}>3||${Math.Calc[${Me.Y}-${SavY}]}>3
			{
				#ifdef DEBUG
					call Debug "I am no longer stuck"
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
			
			; Store our current position.
			SavX:Set[${Me.X}]
			SavY:Set[${Me.Y}]
			
			; Set a timer to check our position again in a second or so.
			TimedCommand 5 ObstacleCheckTimer:Set[TRUE]
		}
		
				
	}

	while !${Unit[${AttackGUID}].Dead}&&!${Me.Dead}
	{
		; Update stats
		if !${Me.Dead}
		{
			call UpdateStats
		}
	}

	
	call SelectPoison
	PoisonOfChoice:Set[${Return}]

	; Check for poison on our main hand.
	if !${Me.InCombat} && !${Me.Equip[mainhand].Enchantment[${PoisonOfChoice}](exists)} && ${Item[${PoisonOfChoice}](exists)}
	{
		wait 10
		Item[${PoisonOfChoice}]:Use
		wait 20 ${WoWScript[SpellIsTargeting()]}

		; Check if the spell is awaiting a target and supply one if it is
		if ${WoWScript[SpellIsTargeting()]}
		{
			Object[${Me.Equip[mainhand]}]:PickUp
			wait 20 ${Me.Casting}
		}
		wait 50 !${Me.Casting}
	}
	
   	; Check for poison on our off hand, if duel wielding
	if !${Me.InCombat} && ${Me.Equip[offhand](exists)} && !${Me.Equip[offhand].Enchantment[${PoisonOfChoice}](exists)} && ${Item[${PoisonOfChoice}](exists)}
	{
		wait 10
		Item[${PoisonOfChoice}]:Use
		wait 20 ${WoWScript[SpellIsTargeting()]}

		; Check if the spell is awaiting a target and supply one if it is
		if ${WoWScript[SpellIsTargeting()]}
		{
			Object[${Me.Equip[offhand]}]:PickUp
			wait 20 ${Me.Casting}
		}
		wait 50 !${Me.Casting}
	}

	wowpress -release movebackward
	wowpress -release moveforward

	call RogueDebug "Checking Aggro before Downtime"
	;Reset flags to do combat prep and downtime if we are not still aggroed
	Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-50]
	call RogueDebug "Found ${Aggros.Count} aggros"
	if !${Aggros.Count}
	{
		call Debug "Resetting Downtime and CombatPrep Flags"
		DoDowntime:Set[TRUE]
		DoCombatPrep:Set[TRUE]
	}
	Aggros:Clear
}

;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestHealingPotion
;| Type: atom
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best healing potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

atom DrinkBestHealingPotion()
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

function Downtime()
{
	wait 10
	call RogueDebug "I ENTERED DOWNTIME... ${Me.PctHPs}<${MinHealthPct}"

	if ${Me.PctHPs}<${MinHealthPct}
	{
		call RogueDebug "Check Durability"
		call CheckDurability
		wait 10
		call RogueDebug "Begin While... ${Me.PctHPs}<99&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}"
		while ${Me.PctHPs}<99&&!${Me.InCombat}&&!${Me.Dead}&&!${Me.Ghost}
		{
			call RogueDebug "Eating yadda"
			if ${SitWhenRest} && !${Me.Sitting}
			{
				wowpress SITORSTAND
			}

			if ${Me.PctHPs}<${MinHealthPct} && !${Me.Buff[Food](exists)}
			{
				call Eat
				call CastSpell "Stealth"
				wait 40 ${Me.Buff[Food](exists)}
			}

			waitframe 
  		 }
	}

	; Reset downtime flag
	DoDowntime:Set[FALSE]
}
