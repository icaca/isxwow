/*

Shaman Routine 1-60 coded by reddogg
I basically used the lazer1's Priest routine at a foundation for this script.
Tested with Wowbot 13, 14, 15

Azeroth
Added Dual Weapon Support

#####################################################################
# FEATURES	 					   	    #
#####################################################################
# 								    #
# SPELL SETTINGS:						    #
# ---------------						    #
# Pull, Nuke and Spam spell definitions can be setup		    #
# Pull, Nuke, Spam, and Healing MANA/HEALTH thresholds can be set   #
# Weapon Buff definitions can be setup				    #
# Choose whether or not you want to use Lightning Shield	    #
# 								    #
# TOTEMS:							    #
# ------							    #
# Define Earth, Fire, Air and Water totems to use		    #
# Define Multi-Aggro Fire and Earth totems to use		    #
# Define which totems the bot should (all, none, some)		    #
# Define which Earth Totem to drop when fleeing			    #
# 								    #
# SPEC FEATURES:						    #
# -------------							    #
# For Elemental Spec'd - If you have Eye of the Storm, a quick heal #
# 			 or Lightning Bolt is cast (depending 	    #
# 			 on situation).				    #
# 								    #
# For Enchance Spec'd - If you have Stormstrike, it will be cast    #
# 			regularly.				    #
# 								    #
# OTHER:							    #
# -------------							    #
# Enamored Water Spirit - If you have done your quest for the	    #
# 			  "Enamored Water Spirit" trinket, then it  #
# 			  will be used when available.		    #
# 								    #
# Spell Interrupts - Earth Shock will be cast when the enemy is     #
# 		     casting and you have sufficient mana.  If	    #
# 		     in cooldown, you canspecifiy the use of a	    #
# 		     grounding totem as well.			    #
# 								    #
# Pure Melee Threshold - In order to conserve mana, you can set	    #
# 		         the threshold at which you stop casting    #
# 			 offensive spells and go pure melee.	    #
# 								    #
# Ghost Wolf - When fleeing from battle, Ghost Wolf is cast first   #
# 	       for quicker escape.				    #
# 								    #
# Fixed ClearDebuff Function - The Clear Debuff had issues dealing  #
# 	       		       with stackable poisons.  It now 	    #
# 	       		       cures them until all are gone. 	    #
# 								    #
# 								    #
#####################################################################

*/



#define ROUTINES
/*
############################################################################
#This part is the DPS configuration. Please change to suit your play style #
############################################################################
*/

#define PULL_SPELL Lightning Bolt					/* if you are low level put in smite */
#define NUKE_SPELL Frost Shock						/* Main DPS Spell */
#define SPAM_SPELL Frost Shock						/* We will try to cast this one as often as possible */
					/* The name of the buff as it appears on the weapon: "i.e. Rockbiter 7","Frostbrand 5","Flametongue 6","Windfury 4" */

#define USE_LIGHTNING_SHIELD						/* Define if you want the character to use Lightning Sheild */
#define USE_GROUNDING							/* Spell Disrupt - Define if you want the character to use a Grounding Totem when Earth Shock is in Cooldown */

#define DUEL_WIELD

#define WEAPON_BUFF Windfury Weapon					/* This will be the buff type you choose to put on your weapon: "Rockbiter Weapon","Frostbrand Weapon","Flametongue Weapon","Windfury Weapon" */
#define WEAPON_BUFF_TITLE Windfury 3
#define WEAPON_BUFF2 Windfury Weapon					/* This will be the buff type you choose to put on your weapon: "Rockbiter Weapon","Frostbrand Weapon","Flametongue Weapon","Windfury Weapon" */
#define WEAPON_BUFF2_TITLE Windfury 3					/* The name of the buff as it appears on the weapon: "i.e. Rockbiter 7","Frostbrand 5","Flametongue 6","Windfury 4" */


/*
##################################################################################
#With this section you can control your Mana conservation and general play style.#
##################################################################################
*/

#define NUKE_MANA 30							/* Stop casting Nuke at configured % Mana */
#define SPAM_MANA 40							/* Stop Casting Spam at configured % Mana */
#define MANA_PURE_MELEE 80						/* go pure melee when your mana is at %  */
;#define ENEMY_PURE_MELEE 30						/* (not functioning) go pure melee when your enemy's health is at %  */
#define USE_MANA_TRINKET 						/* If you have done your quest have the your mana trinket and have it equipped, use it in battle  */


/*
####################
#Totem definitions.#
####################
*/
#define FIRE_TOTEM Searing Totem	 				/* Fire Totem to use on a regular basis: "Searing Totem","Fire Nova Totem","Magma Totem"  */
#define EARTH_TOTEM Stoneskin Totem				/* Earth Totem to use on a regular basis: "Stoneskin Totem","Stoneclaw Totem", "Earthbind Totem"  */
#define WATER_TOTEM Mana Spring	Totem					/* Water Totem to use: "Mana Spring","Healing Spring"  */
#define AIR_TOTEM Grace of Air					/* Air Totem to use: "Grace of Air","Windwall"  */
#define MULTIPLE_ENEMIES_FIRE_TOTEM Fire Nova Totem			/* Fire Totem to use if you encounter multiple enemies  */
#define MULTIPLE_ENEMIES_EARTH_TOTEM Stoneskin Totem			/* Damage Totem to use if you encounter multiple enemies: "Stoneskin Totem","Stoneclaw Totem"  */

;These variables determine whether or not you want to use a totem of that type.  Use of all four totmes can be very mana intensive, so you may want to limit them
#define USE_FIRE_TOTEM
#define USE_EARTH_TOTEM
#define USE_WATER_TOTEM
#define USE_AIR_TOTEM

#define FLEEING_EARTH_TOTEM Earthbind Totem	 			/* when fleeing, define which totem to drop. Usually "Earthbind Totem","Stoneclaw Totem"  */

/*
#################
#Healing Section#
#################
*/
#define HEAL_HPS 40							/* Specify % HP to cast your configured Heal spell */
#define HEAL_SPELL Healing Wave						/* Specify Healing Spell here: "Healing Wave","Lesser Healing Wave" */


/*
#################
#Spec Section   #
#################
*/
;#define HAVE_EYE_OF_THE_STORM						/* If you spec'd in Elemental and have Eye of the Storm, leave this defined to utilize it */
#define HAVE_STORMSTRIKE						/* If you spec'd in Enhancement and have Stormstrike, leave this defined to utilize it */

;end of configuration



function CombatPrep()
{

	;Make sure your weapon has it's buff
#ifdef DUEL_WIELD
	if ${Spell[WEAPON_BUFF](exists)} && !${Me.Equip[mainhand].Enchantment[WEAPON_BUFF_TITLE](exists)}
	{
		call UpdateHudStatus "Casting Weapon Buff"
		call CastSpell "WEAPON_BUFF" ${Me.GUID}
	}
	wait 1
	if ${Spell[WEAPON_BUFF2](exists)} && !${Me.Equip[offhand].Enchantment[WEAPON_BUFF2_TITLE](exists)}
	{
		call UpdateHudStatus "Casting Weapon Buff2"
		call CastSpell "WEAPON_BUFF2" ${Me.GUID}
	}
#else
	if ${Spell[WEAPON_BUFF](exists)} && !${Me.Equip[mainhand].Enchantment[WEAPON_BUFF_TITLE](exists)}
	{
		call UpdateHudStatus "Casting Weapon Buff"
		call CastSpell "WEAPON_BUFF" ${Me.GUID}
	}
#endif

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
	declare Action string local melee
	
	
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
		

		if ${Unit[${AttackGUID}].FactionGroup.Equal[Alliance]} 
		{ 
		      ;add them to a blacklist or whatever here... 
		      call UpdateHudStatus "Target is an alliance member, don't bother attacking them" 
		      GUIDBlacklist:Set[${AttackGUID},AVOID] 
		      TargetGUID:Set[NOTARGET] 
		      Return 
		} 

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
			 call UpdateHudStatus "Aggrod an elite, drop stoneclaw, go ghost wolf and run!!" 
			 
			 if ${Spell[Stoneclaw Totem](exists)}
			 {
			 	call CastSpell "FLEEING_EARTH_TOTEM"
			 }
			 if ${Spell[Ghost Wolf](exists)}
			 {
			 	call CastSpell "Ghost Wolf"
			 }

			 RLG:Set[TRUE] 
			 GUIDBlacklist:Set[${AttackGUID},AVOID] 
			 TargetGUID:Set[NOTARGET] 
			 return 
		      } 
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
			wait 5
		}
		
		; Once our target is in range turn on attack
		if !${Me.Attacking}&&${Target(exists)}&&${Unit[${AttackGUID}].Distance}<${TargetingRange}
		{
			WoWScript AttackTarget()
		}

		; Check we havent picked up an aggro other than the mob we have targeted.
		Aggros:Search[-units,-nearest,-targetingme,-notowner,-alive,-range 0-10]
		if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]}
		{
			debug("Untargeted Unit ${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine")
			return
		}
		Aggros:Clear
		
		
		/*
		################################################################
		# Status routine - Should we Melee, Cast Offensive or Heal?    #
		################################################################
		*/
		
		Action:Set[Melee]

		if ${Me.PctHPs}<HEAL_HPS
		{
			Action:Set[Heal]
		}
		else
		{
			; we have enough HP, now check mana
			if ${Me.PctMana} > ${MinManaPct} || ${Me.Buff["Clearcasting"](exists)}
			{
				Action:Set[SpellAttack]
		
			}
			else
			{
				; ok we have low mana, check to see if we should run, or if we can stick it out
				
				; ## We have enough health to stick it out so Drop Mana Totem ##
				if ${Me.PctHPs} > ${MinHealthPct}
				{
					Action:Set[DropManaTotem]
				}
			}
		}
		
		; IF we are in trouble, forget the above, RUN!!!
		Aggros:Search[-units,-nearest,-targetingme,-alive,-notowner,-range 0-${Math.Calc[${MaxRoam}/2]}] 
		if ${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]} || (${Aggros.Count}>${PanicThreshold} && ${Me.PctHPs}<30 && ${Me.PctMana}<15 && ${Unit[AttackGUID].PctHPs}>30)
		{ 
			 Action:Set[Run]
		}
		Aggros:Clear


		if ${Me.PctMana}<10 && ${Me.PctHPs}<30
		{
			 Action:Set[Run]
		}



		/*
		###############
		# Pull Target #
		###############
		*/

		; Check if we have pulled yet and if not do so.
		if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled}
		{	
			
			#ifdef PULL_SPELL
			if ${Spell[PULL_SPELL](exists)} && ${Unit[${AttackGUID}].Distance}>5
			{
				call UpdateHudStatus "Pulling Target" 
				call CastSpell "PULL_SPELL" ${Target.GUID}
				wait 10
			}
			else
			{
				call UpdateHudStatus "New Target too close for Pull, use SPAM_SPELL" 
				call CastSpell "SPAM_SPELL" ${Target.GUID}
			}			
			#endif

			HavePulled:Set[TRUE]
		}


		/*
		##########################
		# Clear Poison & Disease #
		##########################
		*/
		if ${Me.PctMana}>10
		{
			call ClearDebuff	
		}		

		/*
		###################################################################
		# Spell attacks and Totems 					  #
		###################################################################
		# Cast a spell if we have enough mana, or if we have clearcasting #
		# Buff self and drop totems if we ave enough mana 		  #
		###################################################################
		*/
		
		if ${Action.Equal["SpellAttack"]}
		{


			if  ${Me.PctMana}>MANA_PURE_MELEE || ${Me.Buff["Clearcasting"](exists)}
			{

				/*
				#################
				# Cast Spells   #
				#################
				*/

				; if the unit is casting, try to interrupt it
				if ${Unit[${AttackGUID}].Casting(exists)}
				{
					if !${Spell["Earth Shock"].Cooldown}
					{ 
						if ${Me.PctMana}>NUKE_MANA
						{ 
							call CastSpell "Earth Shock" ${AttackGUID}
							wait 5
						}
					}
					else
					{
						#ifdef USE_GROUNDING
						if ${Spell["Grounding Totem"](exists)}
						{
							call CastSpell "Grounding Totem" ${AttackGUID}
						}						
						#endif
					}
				}
				else
				{
					; just use a normal attack
					#ifdef NUKE_SPELL
					if !${Spell["NUKE_SPELL"].Cooldown} && ${Unit[${AttackGUID}].PctHPs}>15 && ${Me.PctMana}>NUKE_MANA
					{ 
						call CastSpell "NUKE_SPELL" ${AttackGUID} 
					}
					#endif


					#ifdef SPAM_SPELL
					if ${Spell["SPAM_SPELL"](exists)} && !${Unit[${AttackGUID}].Buff["SPAM_SPELL"](exists)} && ${Unit[${AttackGUID}].PctHPs}>15 && ${Me.PctMana}>SPAM_MANA
					{
						call CastSpell "SPAM_SPELL" ${AttackGUID}
					}
					#endif
				}
			}


			; Start main attack routine
			if (${HavePulled} && ${Me.PctMana}>MANA_PURE_MELEE)
			{

				; Put up a Lightning Shield if there isn't one
				#ifdef USE_LIGHTNING_SHIELD
				if ${Spell[Lightning Shield](exists)}&&!${Me.Buff["Lightning Shield"](exists)}
				{
					call CastSpell "Lightning Shield" ${Me.GUID}
				}
				#endif

				#ifdef WEAPON_BUFF
				if ${Spell[WEAPON_BUFF](exists)} && !${Me.Equip[mainhand].Enchantment[WEAPON_BUFF_TITLE](exists)}
				{
					call UpdateHudStatus "Casting Weapon Buff"
					call CastSpell "WEAPON_BUFF" ${Me.GUID}
				}
				#endif




				; Only cast attack spells if our mana is higher than the MANA_PURE_MELEE threshold, or we have clearcasting
				if  ${Me.PctMana}>MANA_PURE_MELEE
				{


					/*
					##############################
					# Drop Multiple Aggro Totems #
					##############################
					*/
					
					; use AE attacks and protective totems if multiple mobs
					Aggros:Search[-units,-nearest,-notowner,-targetingme,-alive,-range 0-20]
					if ${Aggros.Count}>1
					{
					    call UpdateHudStatus "Multiple Enemies Aggroed!"
					    call CastSpell "MULTIPLE_ENEMIES_EARTH_TOTEM" 
					    ; wait 0.5 sec for global cooldown
					    wait 5

					    call CastSpell "MULTIPLE_ENEMIES_FIRE_TOTEM" 			    
					}
					Aggros:Clear



					/*
					##################################
					# Special Spec Casting setion    #
					##################################
					*/

					#ifdef HAVE_STORMSTRIKE
					if !${Spell[Stormstrike].Cooldown}
					{
						call CastSpell "Stormstrike"
					}
					#endif

					; if you have Eye of the Storm and it procs and your health is between 50-70%, 
					; sneak in a quick heal
					#ifdef HAVE_EYE_OF_THE_STORM
					if ${Me.Buff["Focused Casting"](exists)}
					{
						if ${Me.PctHPs}<70 && ${Me.PctHPs}>50
						{
							call CastSpell "QUICK_HEAL"
						}
						else
						{
							; if we don't need to heal, then sneak in a bolt.  They are cheap mana-wise and do good damage
							call CastSpell "Lightning Bolt" ${AttackGUID} 											
						}

					}

					#endif


					/*
					#################
					# Drop Totems   #
					#################
					*/

					; if I have manuevered myself into position, drop my totems

					if ${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${CombatMaxDist}
					{

						#ifdef USE_EARTH_TOTEM
						; Drop your Earth Totem if one doesn't already exist, or if it's too far away
						 if !${Unit[EARTH_TOTEM].GUID.NotEqual[NULL]} || ${Unit[EARTH_TOTEM].Distance}>50
						 { 
							if ${Item[Earth Totem](exists)} && !${Spell[EARTH_TOTEM].Cooldown} && !${MultipleEnemiesAggroed}
							{
								call CastSpell "EARTH_TOTEM"
								wait 5
							}
						 }
						#endif


						#ifdef USE_FIRE_TOTEM
						; Drop your Fire Totem if one doesn't already exist
						 if !${Unit[FIRE_TOTEM].GUID.NotEqual[NULL]} || ${Unit[FIRE_TOTEM].Distance}>40
						 { 
							if ${Item[Fire Totem](exists)} && !${Spell[FIRE_TOTEM].Cooldown} && !${MultipleEnemiesAggroed}
							{
								call CastSpell "FIRE_TOTEM"
								wait 5
							}
						 } 
						#endif

						#ifdef USE_AIR_TOTEM
						; Drop your Wind Totem if one doesn't already exist
						 if !${Unit[AIR_TOTEM].GUID.NotEqual[NULL]} || ${Unit[AIR_TOTEM].Distance}>50
						 { 
							if ${Item[Air Totem](exists)} && !${Spell[AIR_TOTEM].Cooldown}
							{
								call CastSpell "AIR_TOTEM"
								wait 5
							}
						 } 
						#endif


						; If we have a MANA TRINKET, use it
						#ifdef USE_MANA_TRINKET
						if ${Item[Enamored Water Spirit](exists)}&&!${Me.Action[Enamored Water Spirit].Cooldown} 
						{
							call UpdateHudStatus "Using Enamored Water Spirit" 
							Item[Enamored Water Spirit]:Use 
						}
						#endif

						#ifdef USE_WATER_TOTEM
						; Drop your Water Totem if one doesn't already exist
						 if !${Unit[WATER_TOTEM].GUID.NotEqual[NULL]} || ${Unit[WATER_TOTEM].Distance}>50
						 { 
							if ${Item[Water Totem](exists)} && !${Spell[WATER_TOTEM].Cooldown}
							{
								call CastSpell "WATER_TOTEM"
								wait 5
							}
						 } 
						#endif
					}


				}


			}	
		}	
		
		
		if ${Action.Equal["DropManaTotem"]}
		{
			; If we have a MANA TRINKET, use it
			if ${Item[Enamored Water Spirit](exists)}&&!${Me.Action[Enamored Water Spirit].Cooldown} 
			{
				call UpdateHudStatus "Using Enamored Water Spirit" 
				Item[Enamored Water Spirit]:Use 
			}

			; Drop your Water Totem if one doesn't already exist
			 if !${Unit[WATER_TOTEM].GUID.NotEqual[NULL]} || ${Unit[WATER_TOTEM].Distance}>50
			 { 
				if ${Item[Water Totem](exists)} && !${Spell[WATER_TOTEM].Cooldown}
				{
					call CastSpell "WATER_TOTEM"
					wait 5
				}
			 } 
		}
		
		if ${Action.Equal["Heal"]}
		{
			if ${Me.PctHPs}<${MinHealthPct}
			{
				call CastSpell "HEAL_SPELL" ${Me.GUID}
			}

			if ${Me.PctHPs}<10
			{
				;Drink a healing pot as we are in big trouble
				call snarfpotion
			}
		}


		/*
		; Check if we wish to flee combat or not
		Aggros:Search[-units,-nearest,-targetingme,-alive,-notowner,-range 0-${Math.Calc[${MaxRoam}/2]}] 
		if (${Aggros.Count}>=${Math.Calc[${PanicThreshold}*2]} || (${Aggros.Count}>${PanicThreshold} && (${Me.PctHPs}<40||((${Me.PctHPs}<30&&${Me.PctMana}<10)&&${Unit[AttackGUID].PctHPs}>30)) 
		{ 
			 Action:Set[Run]
		}
		Aggros:Clear
		*/


		if ${Action.Equal["Run"]}
		{
			if ${Me.PctHPs}<10
			{
				;Drink a healing pot as we are in big trouble
				call snarfpotion
			}

			 call Debug "Fleeing." 
			 call snarfpotion
			
			 if ${Spell[Stoneclaw Totem](exists)}
			 {
			 	call CastSpell "FLEEING_EARTH_TOTEM"
			 }
			 if ${Spell[Ghost Wolf](exists)}
			 {
			 	call CastSpell "Ghost Wolf"
			 }

			 RLG:Set[TRUE] 
			 return 
		}
		
		
		; If they run, hit 'em with FS and Lightning Bolt
		if ${Me.PctMana}>MANA_PURE_MELEE && ${Unit[${AttackGUID}].Distance}>${CombatMaxDist} && ${Unit[${AttackGUID}].CreatureType.Equal["Humanoid"]} && ${Unit[${AttackGUID}].Health} <= 15 && !${WoWScript[CastingBarFrame.channeling]}
		{
			call UpdateHudStatus "Target Fleeing, cast Lightning Bolt" 
			call CastSpell "Frost Shock" ${AttackGUID} 
			call CastSpell "Lightning Bolt" ${AttackGUID} 
		}		

		
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
	Aggros:Search[-units,-nearest,-targetingme,-notowner,-alive,-range 0-50] 
	if !${Aggros.Count}
	{ 
		call Debug "Resetting Downtime and CombatPrep Flags" 
		DoDowntime:Set[TRUE]
		DoCombatPrep:Set[TRUE]
	}
	Aggros:Clear
}

function snarfpotion() 
{ 

  ;call UpdateHudStatus "Checking to see if I need to use a potion" 

    if ${Item[Major Healing Potion](exists)}&&!${Me.Action[Major Healing Potion].Cooldown} 
    { 
    	 if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Major Healing Potion" 
		       Item[Major Healing Potion]:Use 
		       return 
       } 
    } 
		
    if ${Item[Superior Healing Potion](exists)}&&!${Me.Action[Superior Healing Potion].Cooldown} 
    { 
    	 if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Superior Healing Potion" 
		       Item[Superior Healing Potion]:Use 
		       return 
       } 
    } 
		
    if ${Item[Major Healing Potion](exists)}&&!${Me.Action[Major Healing Potion].Cooldown} 
    { 
    	 if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Major Healing Potion" 
		       Item[Major Healing Potion]:Use 
		       return 
       } 
    } 
    
    if ${Item[Greater Healing Potion](exists)}&&!${Me.Action[Greater Healing Potion].Cooldown} 
    { 
    	 if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Greater Healing Potion" 
		       Item[Greater Healing Potion]:Use 
		       return 
       } 
    } 
    
    if ${Item[Healing Potion](exists)}&&!${Me.Action[Healing Potion].Cooldown} 
    { 
       if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Healing Potion" 
		       Item[Healing Potion]:Use 
		       return 
       } 
    } 
    
    if ${Item[Lesser Healing Potion](exists)}&&!${Me.Action[Lesser Healing Potion].Cooldown} 
    { 
       if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Lesser Healing Potion" 
		       Item[Lesser Healing Potion]:Use 
		       return 
       } 
    } 
    
    if ${Item[Minor Healing Potion](exists)}&&!${Me.Action[Lesser Healing Potion].Cooldown} 
    { 
       if ${Me.PctHPs}<25
       { 
		       call UpdateHudStatus "Snarfing Minor Healing Potion" 
		       Item[Minor Healing Potion]:Use 
		       return 
       } 
    } 
} 


function Downtime()
{

	wait 5
	call ClearDebuff 

	; Drop your Water Totem for faster mana regen
	if ${Me.PctMana}<${MinManaPct}
	{
		 if !${Unit[WATER_TOTEM].GUID.NotEqual[NULL]} || ${Unit[WATER_TOTEM].Distance}>40
		 { 
			if ${Item[Water Totem](exists)} && !${Spell[WATER_TOTEM].Cooldown}
			{
				call CastSpell "WATER_TOTEM"
				wait 5
			}
		 } 
	 } 

	call CheckDurability
	while ${Me.PctHPs}<HEAL_HPS && !${Me.InCombat} && !${Me.Dead} && !${Me.Ghost}
	{
		call CastSpell "HEAL_SPELL" ${Me.GUID}
		wait 5
	}
	
	
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
				wait 35 ${Me.Buff[Drink](exists)}
			}
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


function ClearDebuff() 
{
	declare DebuffCounter int local 1 
	CurrentAction:Set[Debuff] 
	do 
	{    
		;; If we've come to the end of the buff list then break. 
		if !${Me.Buff[${DebuffCounter}](exists)} 
		{ 
			 break 
		} 

		; If this debuff is harmful, then see if it can be cured. 
		if ${Me.Buff[${DebuffCounter}].Harmful} 
		{ 
			 if ${Me.Buff[${DebuffCounter}].DispelType.Equal[Poison]} 
			 { 
				 CurrentAction:Set[Cure Poison] 
				 call CastSpell "Cure Poison" ${Me.GUID} 
			 } 

			 if ${Me.Buff[${DebuffCounter}].DispelType.Equal[Disease]} 
			 { 
				 CurrentAction:Set[Cure Disease] 
				 call CastSpell "Cure Disease" ${Me.GUID} 
			 } 
		}
		
		; check to see if it's been stacked, if so, then don't go on to the next buff, make sure they are all cleaned
		if !(${Me.Buff[${DebuffCounter}].Harmful} && ${Me.Buff[${DebuffCounter}](exists)} && (${Me.Buff[${DebuffCounter}].DispelType.Equal[Poison]} || ${Me.Buff[${DebuffCounter}].DispelType.Equal[Disease]}))
		{ 
			DebuffCounter:Inc 		
		} 
		else
		{
		        call UpdateHudStatus "Debuff stacked, removing again." 
		}
	} 
  while ${DebuffCounter} <= 12 

} 
 	
