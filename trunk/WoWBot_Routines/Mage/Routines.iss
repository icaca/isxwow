; Mage Routines  ver 1.3 
; Routines tailored for a Mage 
; compatible with WoWBot version 12a 
; Change declare ColdPull to FALSE to pull with Fireball. 

;Leave this define Intact. Its testing if this file is loaded or not. 

;Further modifications by firoso, adding cone of cold, pyroblast pulls, optional AoE disabling, etc. 
;to use Pyroblast set coldpull to false and pyropull to true
;to use Dragon's breath set UseDragon to TRUE, else you'll use cone of cold.


#define ROUTINES 
#define DEBUG 



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
   declare InnerIndex int local 1 
   declare RangedMode bool local TRUE 
   declare ColdPull bool local FALSE 
   declare PyroPull bool local FALSE 
   declare AllowAoe bool local TRUE 
   declare UseDragon bool local TRUE 
   declare UseFrostWard bool local FALSE 
   declare UseFireWard bool local TRUE 
   
   SavedWaypointX:Set[${Me.X}]
   SavedWaypointY:Set[${Me.Y}]
   
   if ${Me.Sitting} 
         { 
            wowpress SITORSTAND 
         }  
         
         
   if ${AttackGUID.Equal[NULL]}||${AttackGUID.Equal[NOTARGET]} 
   { 
      call UpdateHudStatus "No target to attack" 
      Return
   } 

   ; add combustion check and activation here
   if ${Spell[Combustion](exists)} && !${Spell[Combustion].Cooldown}
   {
   	call UpdateHudStatus "Casting Combustion!"
   	call CastSpell "Combustion"
   	
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
         call UpdateHudStatus "Aggrod an elite RUN after we sheep!!" 
         if !${Spell[Polymorph].Cooldown}&&${Spell[Polymorph](exists)} 
         { 
            call CastSpell Polymorph ${AttackGUID} 
         }    
         RLG:Set[TRUE] 
         GUIDBlacklist:Set[${AttackGUID},AVOID] 
         TargetGUID:Set[NOTARGET] 
         return 
      } 
   } 
    
   call UpdateHudStatus "Attacking ${Object[${AttackGUID}].Name}" 
   ; if we are close enough stop running 
   if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled} 
         { 
            move -stop 
            wait 3
            Target ${AttackGUID} 
            
         } 
    
   Do 
   { 
      
      if ${Me.Sitting} 
               { 
                  wowpress SITORSTAND 
         } 
      SavX:Set[${Me.X}] 
      SavY:Set[${Me.Y}] 
      SavZ:Set[${Me.Z}] 
      
      ; Ensure we are still facing our target loc 
      call UpdateHudStatus "Facing Target - Have Target [${AttackGUID}]"
      Target ${AttackGUID}
      Face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
      call CheckFacing
      call snarfpotion 
      call usestone
      
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
         call UpdateHudStatus "Target already engaged" `
         TargetGUID:Set[NOTARGET] 
         Return          
      } 
      
      ; If we dont have our chosen unit targeted and were in range target it 
      if (!${Target.GUID.Equal[${AttackGUID}]})&&(${Unit[${AttackGUID}].Distance}<${TargetingRange})
      { 
        
           call UpdateHudStatus "Targeting Unit ${Unit[${AttackGUID}].Distance} - [${AttackGUID}]" 
        
         Target ${AttackGUID} 
         wait 10 
      } 
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
      if !${Me.Attacking}&&${Target(exists)}&&!${RangedMode} 
      { 
         WoWScript AttackTarget() 
      } 
      /*
      ; Check we havent picked up aggro 
      Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10] 
      if !${HavePulled}&&${Aggros.Count}>0&&${Aggros[1].GUID.NotEqual[${AttackGUID}]} 
      { 
          
            call UpdateHudStatus "${Unit[${Aggros[1].GUID}].Name} has aggroed exiting Attack routine" 
       
         return 
      } 
      Aggros:Clear 
      */       
      ; Once we get close to our target then pull it 
      if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&${Me.PctMana}>20&&!${HavePulled} 
      { 
         
         call UpdateHudStatus "Facing Target - Have Pulled" 
         Face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
         call CheckFacing
         move -stop 
         wait 5 
          
          
         if ${Spell[Frostbolt](exists)}&&${RangedMode}&&${ColdPull} 
         { 
            call UpdateHudStatus "Pulling with Frostbolt" 
            call CastSpell "Frostbolt" ${AttackGUID} 
         } 
        ;Firoso: Check to see if we should use Pyroblast to pull. 
	if ${RangedMode}&&!${ColdPull}&&${Spell[Pyroblast](exists)}&&${PyroPull} 
            {    
            call UpdateHudStatus "Pulling with Pyroblast" 
            call CastSpell "Pyroblast" ${AttackGUID} 
            } 
	 else
         if ${RangedMode}&&!${ColdPull} 
            {    
            call UpdateHudStatus "Pulling with Fireball" 
            call CastSpell "Fireball" ${AttackGUID} 
            } 
         HavePulled:Set[TRUE] 
      } 
      if ${Unit[${AttackGUID}].Tapped} 
            { 
               call UpdateHudStatus "Target already engaged" `
               TargetGUID:Set[NOTARGET] 
               Return          
            } 
      
      call snarfpotion 
      call usestone
         if (${PullBeforeContinue}&&${HavePulled})||!${PullBeforeContinue} 
         { 
            ; Check i have enough mana to cast 
            if ${Me.PctMana}>10 
            { 
               ; NUKES BEGIN 
               ;ok, our base attack is fireball, but if we're in clearcast mode, use arcane missiles cause it's instant and it's free 
	       if ${Me.Buff[Clearcast](exists)} 
               { 
                  call UpdateHudStatus "Clearcast mode detected" 
                  if ${Unit[${AttackGUID}].Distance}<30&&${Spell[Arcane Missiles](exists)} 
                  { 
                     call UpdateHudStatus "Clearcasting Arcane Missiles" 
                     call CastSpell "Arcane Missiles" ${AttackGUID} 
                  } 
               }
	       ;Firoso: Try cone of cold. 
               if ${Unit[${AttackGUID}].Distance}<10&&${Spell[Cone of Cold](exists)}&&!${UseDragon}
               {  
                  if !${Spell[Cone of Cold].Cooldown} 
                  { 
                     call UpdateHudStatus "Casting Cone of Cold" 
                     call CastSpell "Cone of Cold" ${AttackGUID} 
                  } 
               }  
	       ;Firoso: Dragon's Breath. 
               if ${Spell[Dragon's Breath](exists)}&&${Unit[${AttackGUID}].Distance}<15&&!${Spell[Dragon's Breath]Cooldown}&&${AllowAoe}&&${UseDragon}
	       {  
                  if !${Spell[Dragon's Breath].Cooldown} 
                  { 
                     call UpdateHudStatus "Casting Dragon's Breath" 
                     call CastSpell "Dragon's Breath" ${AttackGUID} 
                  } 
               }  
               ;use frost nova if it's ready, and it's close enough, then drop back/blink a few paces 
               if ${Spell[Blast Wave](exists)}&&${Unit[${AttackGUID}].Distance}<15&&!${Spell[Blast Wave]Cooldown}&&${AllowAoe}
               {
               		call CastSpell "Blast Wave" ${AttackGUID}
               }
               if ${Spell[Frost Nova](exists)}&&${AllowAoe}
               { 
                     call FrostNovaAttackSet ${AttackGUID} 
               }       
               
	       if ${Unit[${AttackGUID}].Distance}<26&&${Spell[Fire Blast](exists)} 
               { 
                  ;call GetSpellCooldown "Fire Blast" 
                  if !${Spell[Fire Blast].Cooldown} 
                  { 
                     ;call UpdateHudStatus "Casting Fireblast" 
                     call CastSpell "Fire Blast" ${AttackGUID} 
                  } 
               } 
               call snarfpotion 
	         ;Firoso: No spells for you! 
		 if ${Unit[${AttackGUID}].Casting.ID(exists)}&&${Unit[${AttackGUID}].CurrentMana}>0
	       {
	       	call UpdateHudStatus "Trying Counterspell"   
		call CastSpell "Counterspell" ${AttackGUID} 
	       }
               if !${Me.Buff[Fire Ward](exists)}&&${Spell[Fire Ward](exists)}&&!${Spell[Fire Ward].Cooldown}&&${UseFireWard}&&!${UseFrostWard}
                  { 
                     if ${Me.Sitting} 
                     { 
                        wowpress SITORSTAND 
                     } 
                        call CastSpell "Fire Ward" ${Me.GUID} 
                  } 
               if !${Me.Buff[Frost Ward](exists)}&&${Spell[Frost Ward](exists)}&&!${Spell[Frost Ward].Cooldown}&&!${UseFireWard}&&${UseFrostWard}
                  { 
                     if ${Me.Sitting} 
                     { 
                        wowpress SITORSTAND 
                     } 
                        call CastSpell "Frost Ward" ${Me.GUID} 
                  } 
		if (${Unit[${AttackGUID}].Distance}<41&&!${Spell[Fireball]Cooldown})
                     { 
                        Face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y}
                        call CheckFacing
                        ;call UpdateHudStatus "Casting Fireball" 
                        call CastSpell "Fireball" ${AttackGUID} 
               } 
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
               call snarfpotion
               call usestone
               if ${Unit[${AttackGUID}].Distance}<41&&${Unit[${AttackGUID}].PctHPs}<16&&!${Unit[${AttackGUID}].Dead}  
                     { 
                     if !${Me.Equip[18](exists)} 
                        {  
                         call UpdateHudStatus "No Wand - Casting Fireball" 
                           call CastSpell "Fireball" ${AttackGUID} 
                        } 
                     if ${Me.Equip[18](exists)}&&${Me.PctMana}<31 
                         { 
                         call UpdateHudStatus "Using Wand!" 
                         call CastSpell "Shoot" ${AttackGUID} 
                         } 
                     if ${Unit[${AttackGUID}].Distance}<29&&${Unit[${AttackGUID}].PctHPs}<16&&!${Unit[${AttackGUID}].Dead}&&${Me.PctMana}>30&&!${Spell[Scorch].Cooldown}        
                         { 
                         call CastSpell "Scorch" ${AttackGUID} 
                                } 
                       } 
                
               

                     ; NUKES END 

            }           
            
          
      }    
      
      ; Check if we wish to flee combat or not 
      Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-10] 
      if (${Aggros.Count}>${PanicThreshold}&&${Me.PctHPs}<50)||(${Me.PctHPs}<20&&${Unit[${AttackGUID}].PctHPs}>50) 
      { 
          call snarfpotion 
         #ifdef DEBUG 
            call Debug "I have ${Aggros.Count} Aggro mobs." 
         #endif 
         RLG:Set[TRUE] 
         TargetGUID:Set[NOTARGET] 
         DoDowntime:Set[TRUE] 
         #ifdef DEBUG 
       call Debug "Too many Aggros Count... setting RLG and return" 
         #endif 
         return 
      } 
      ;if aggros has an elite in it, RUN! 
      if (${Aggros.Count}>0) 
      { 
         InnerIndex:Set[1] 
         call UpdateHudStatus "Aggro Check" 
         do 
         { 
            if ${Unit[${Aggros.GUID[${InnerIndex1}]}].Classification.Equal[Elite]} 
            { 
               if !${Spell[Polymorph].Cooldown}&&${Spell[Polymorph](exists)} 
               { 
                  call UpdateHudStatus "Aggrod an elite RUN after we sheep!!" 
                  call CastSpell Polymorph ${Aggros.GUID[${InnerIndex1}]} 
               }    
               RLG:Set[TRUE] 
               TargetGUID:Set[NOTARGET] 
               DoDowntime:Set[TRUE] 
               #ifdef DEBUG 
                     call Debug "Elite Aggro... setting RLG and return" 
               #endif       
               return 
            } 
         } 
         while ${InnerIndex:Inc}<=${Aggros.Count} 
      } 
      
      call usestone
      if ${Me.PctMana}<10 
      { 
         #ifdef DEBUG      
            call Debug "I have no mana to fight with. Muuuummmyy" 
         #endif 
         RLG:Set[TRUE]
         TargetGUID:Set[NOTARGET]
      }    

      ;pre-flee section - set up spells that will aid in running away 
      if ${RLG} 
      { 
         call UpdateHudStatus "Running!  Casting flee spells" 
          if !${Spell[Frost Nova].Cooldown}&&${Spell[Frost Nova](exists)} 
           { 
             ;call UpdateHudStatus "Casting Frost Nova" 
         call CastSpell "Frost Nova" ${AttackGUID} 
                }  
         #ifdef DEBUG 
            call Debug "RLG - Cast Frost Nova" 
         #endif    
         return 
      } 

      ;you're a mage...why would you melee something.  Worst case we'd use a wand..or just set your combatmax dist to your fireball range.... 
      ;If too far away run forward 
      
      if ${Unit[${AttackGUID}].Distance}>${RangedMaxDist} 
      { 
         #ifdef DEBUG 
            call Debug "Too far closing" 
         #endif 
         ;press and hold the forward button 
         move -stop 
         move forward 
      } 

      ;If too close then run backward 
      if ${Unit[${AttackGUID}].Distance}<${CombatMinDist} 
      { 
         #ifdef DEBUG 
            call Debug "Too close backing up" 
         #endif 
         ;press and hold the backward button 
         move -stop 
         move backward 
      } 
      
      ;If we are close enough stop running 
      if ${Unit[${AttackGUID}].Distance}>${CombatMinDist}&&${Unit[${AttackGUID}].Distance}<${RangedMaxDist} 
      { 
         move -stop 
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
      if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3 
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
         #ifdef DEBUG 
            call Debug "Combat Timeout Reached" 
         #endif    
         TargetGUID:Set[NOTARGET] 
         return 
      } 


   } 
   while !${Unit[${AttackGUID}].Dead}&&!${Me.Dead} 
    
   ; Update stats 
   if !${Me.Dead} 
   { 
      #ifdef DEBUG 
            call Debug "Updating Stats" 
         #endif    
      call UpdateStats 
   } 

   move -stop 
   wait 5 
   ;Reset flags to do combat prep and downtime 
   #ifdef DEBUG 
           call Debug "Resetting Combat Prep and Downtime" 
        #endif    
   DoDowntime:Set[TRUE] 
   DoCombatPrep:Set[TRUE]    
    
    
   Return 
} 

function FrostNovaAttackSet(string AttackGUID) 
{ 
   declare moverand int 
   if ${Unit[${AttackGUID}].Distance}<10 
         { 
      if !${Spell[Frost Nova].Cooldown} 
       { 
         ;call UpdateHudStatus "Casting Frost Nova" 
         call CastSpell "Frost Nova" ${AttackGUID} 

         ;blink away from the target if we can 
         call snarfpotion 
          
          
         ;this blink section isn't working 100% yet, change the -1 to a 0 in the next line to try it out 
         if (${Spell[Blink](exists)}&&${Spell[Blink].Cooldown}==-1) 
         { 
            ;turn around 180 degrees 
            call UpdateHudStatus "Turning around 180 degrees and blinking" 
            ;Face -heading ${Me.Heading.DegreesCCW} 
            call UpdateHudStatus "Facing Heading" 
            Face -heading ${Math.Calc[${Me.Heading}-180]} 
            call CheckFacing
               
            call CastSpell "Blink" ${Me.GUID} 
            ;wait 5 
            
         } 
         else 
         {    
            ;make sure the target wasn't killed by the frost nova 
            if !${Unit[${AttackGUID}].Dead} 
            { 
               call UpdateHudStatus "Turn sideways and sidestep for a few paces..."; 
    
               ;face the target so when we turn we can still fire blast him while we strafe 
               call UpdateHudStatus "Facing Target - Strafing Target" 
               call SmartFace ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
               call CheckFacing
               call snarfpotion 
               ;only turn 85 degrees so the target is still 'in front' of us while we strafe 
                                
               ;strafing time 
               ;stop when ${Unit[${AttackGUID}]} doesnt have the frost nova buff on it 
               moverand:Set[${Math.Rand[2]}] 
               ;echo ${moverand} 
               if (${moverand}==0) 
               { 
               move left 
               } 
               if (${moverand}==1) 
               { 
               move right 
               }  
               wait 8 
               call UpdateHudStatus "Facing Target - End Strafe" 
               Face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
               call CheckFacing
               move -stop 
               call snarfpotion 
               if !${Spell[Fire Blast].Cooldown}&&${Spell[Fire Blast](exists)} 
               { 
                  call CastSpell "Fire Blast" ${AttackGUID} 
               } else { 
                  call CastSpell "Fireball" ${AttackGUID} 
                        } 
                
            } 
         } 
          
         if !${Unit[${AttackGUID}].Dead} 
         { 
            ;face the target after our little maneuver if the target is alive 
            ;face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
           Face ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y} 
           call CheckFacing         
         } 
      } 
   } 
} 

function Downtime() 
{ 
   if ${Me.Dead}||${Me.Ghost}||${Me.InCombat} 
   { 
      call snarfpotion 
      call UpdateHudStatus "Not a good time to Rest, quick exit from Downtime!" 
      DoDowntime:Set[FALSE]    
      return 
      
   } 
   if (${Me.PctMana}>${MinManaPct}) && (${Me.PctHPs}>${MinHealthPct}) 
   { 
    ; Reset downtime flag 
    
    DoDowntime:Set[FALSE] 
    return 
   } 
   
   if ${Me.Swimming}
   {
         call UpdateHudStatus "Moving to last Waypoint because we are in the water"
         call moveto SavedWaypointX SavedWaypointY 5
   } 
   
   if !${Variable[MAGICWATER_NAME](exists)}&&${Spell[Conjure Water](exists)} 
   { 
   call SetMageSummons 
   } 
    
   call check_for_lootable_containers 
    
   ;ok, you're a mage, so you can summon food/water/mana stones, let's do that now. 
   ;first, if we don't have a mana stone, then create one if we have the mana 
   ;Make sure you have at least one slot available in a bag! 
    
   if !${Item[${MANASTONE}](exists)}&&!${Spell[${MANASTONE_SPELLNAME}].Cooldown}    
   { 
      if ${Me.CurrentMana}>${Spell[${MANASTONE_SPELLNAME}].Mana} 
      ;echo "CurrentMana ${Me.CurrentMana} and ManaStone Cost is ${Spell[${MANASTONE_SPELLNAME}].Mana}" 
      { 
        
       call CastSpell "${MANASTONE_SPELLNAME}" 
      } 
    }    
    
   do 
   { 
      ; BUFFS BEGIN 
      if (!${Me.Buff[Arcane Intellect](exists)}&&${Spell[Arcane Intelect](exists)})&&(${Me.CurrentMana}>${Spell[Arcane Intelect].Mana}) 
      { 
         if ${Me.Sitting} 
         { 
            wowpress SITORSTAND 
         } 
         ;call UpdateHudStatus "Casting Arcane Intellect" 
         call CastSpell "Arcane Intellect" ${Me.GUID} 
      } 

        if !${Me.Buff[Ice Armor](exists)}&&${Spell[Ice Armor](exists)} 
                  { 
                     if ${Me.Sitting} 
                     { 
                        wowpress SITORSTAND 
                     } 
                        call CastSpell "Ice Armor" ${Me.GUID} 
                  } 
             if !${Me.Buff[Frost Armor](exists)}&&!${Spell[Ice Armor](exists)} 
                  { 
                     if ${Me.Sitting} 
         {  
          wowpress SITORSTAND 
                        } 
                      call CastSpell "Frost Armor" ${Me.GUID} 
                  
                  } 


  
      
      call MakeDrink
      call MakeFood
      call MageDrink
      Call MageEat
      
      
      ;we are noob and cant cast conjure food or water... lets just sit down
      if (!${Spell[Conjure Food](exists)}&&!${Spell[Conjure Water](exists)}&&!${Me.Sitting})
      {
      		wowpress SITORSTAND 
      } 
      
      waitframe 
   } 
   while (${Me.CurrentHPs}<${Me.MaxHPs}||${Me.PctMana}<100)&&!${Me.InCombat} 
    
   call UpdateHudStatus "Exit Downtime Routine" 
   ;Make sure we are stood up. 
   
      if ${Me.Sitting} 
      { 
         wowpress SITORSTAND 
         move -stop
         wait 5
      } 
    
      ; Reset downtime flag 
   DoDowntime:Set[FALSE] 
   waitframe
    
} 
function MakeFood()
{
if !${Item[${MAGICFOOD_NAME}](exists)}&&${Spell[Conjure Food](exists)}&&!${Me.Buff[Food](exists)}&&!${Me.Buff[Drink](exists)}
	{
	if ${Me.CurrentMana}>${Spell[Conjure Food].Mana} 
	      { 
	         if ${Me.Sitting} 
	         { 
	            wowpress SITORSTAND 
	         }          
	         call UpdateHudStatus "Making ${MAGICFOOD_NAME}" 
	         call CastSpell "Conjure Food" ${Me.GUID} 
	         wait 5 
	       }  
	       if (${Item[${MAGICFOOD_NAME}].StackCount}<3)
	       	          	{
	       	          		call UpdateHudStatus "Making More ${MAGICFOOD_NAME}" 
	       	 			call CastSpell "Conjure Food" ${Me.GUID} 
	       	 			if !${Me.InCombat}
	       	 			{
	       	 			       	wait 5 
	       	         		  } else {
	       	         			return
	       	         			 }
               				}
	       
				} 



return
}
function MageEat() 
{ 
   
      if ${Me.CurrentHPs}<${Me.MaxHPs}&&${Item[${MAGICFOOD_NAME}](exists)}&&!${Me.Buff[Food](exists)}
      { 
         call UpdateHudStatus "Eating Food Now" 
         Item[${MAGICFOOD_NAME}]:Use 
         wait 15 
      } 
      
         
} 
function MakeDrink()
{
if !${Item[${MAGICWATER_NAME}](exists)}&&${Spell[Conjure Water](exists)}&&!${Me.Buff[Drink](exists)}  
    { 
      if ${Me.CurrentMana}>${Spell[Conjure Water].Mana} 
      { 
         if ${Me.Sitting} 
         { 
            wowpress SITORSTAND 
         } 
          
         call UpdateHudStatus "Making ${MAGICWATER_NAME}" 
         call CastSpell "Conjure Water" ${Me.GUID} 
         if !${Me.InCombat}
         {
         	wait 5
         } 
         	
         if (${Item[${MAGICWATER_NAME}].StackCount}<3)
         	{
         		call UpdateHudStatus "Making More ${MAGICWATER_NAME}" 
			call CastSpell "Conjure Water" ${Me.GUID} 
			if !${Me.InCombat}
			{
			       	wait 5 
        		} else {
        			return
        			}
                }
      } 

    }

return
}
function MageDrink() 
{ 
   
      if ${Me.CurrentMana}<${Me.MaxMana}&&${Item[${MAGICWATER_NAME}](exists)}&&!${Me.Buff[Drink](exists)} 
      { 
         call UpdateHudStatus "Drinking water now " 
         Item[${MAGICWATER_NAME}]:Use 
         wait 25 
      } 
    
} 
function snarfpotion() 
{ 
if ${Item["Defiler's Talisman"](exists)}&&${Me.PctHPs}<25&&${Target.PctHPs}>45
;&&!${Item["Defiler's Talisman"].Cooldown}
{
	call UpdateHudStatus "Using Defiler's Talisman"
	Item["Defiler's Talisman"]:Use
	
}

;call UpdateHudStatus "Checking to see if I need to use a potion"
if (${Me.PctHPs}<35)&&(${Target.PctHPs}>45)&&(${Spell[Mana Shield](exists)}&&!${Spell[Mana Shield].Cooldown})&&!${Me.Buff[Mana Shield](exists)}
	{
	 call UpdateHudStatus "Casting Mana Shield"
	 call CastSpell "Mana Shield" ${Me.GUID}
	}
call usestone	

if ${Item[Greater Healing Potion](exists)} 
    { 
    if (${Me.PctHPs}<25)&&(${Target.PctHPs}>35) 
       { 
       call UpdateHudStatus "Snarfing Greater Healing Potion" 
       Item[Greater Healing Potion]:Use 
       return 
       } 
    } 
if ${Item[Healing Potion](exists)} 
    { 
    if (${Me.PctHPs}<25)&&(${Target.PctHPs}>35) 
       { 
       call UpdateHudStatus "Snarfing Healing Potion" 
       Item[Healing Potion]:Use 
       return 
       } 
    } 
if ${Item[Lesser Healing Potion](exists)} 
    { 
    if (${Me.PctHPs}<25)&&(${Target.PctHPs}>35) 
       { 
       call UpdateHudStatus "Snarfing Lesser Healing Potion" 
       Item[Lesser Healing Potion]:Use 
       return 
       } 
    } 
if ${Item[Minor Healing Potion](exists)} 
    { 
    if ${Me.PctHPs}<25 && ${Target.PctHPs}>35 
       { 
       call UpdateHudStatus "Snarfing Minor Healing Potion" 
       Item[Minor Healing Potion]:Use 
       return 
       } 
    } 
} 


function CombatPrep() 

;this needs work.... we need to check aggros and buffup if we can 
{ 
   if ${Me.Dead}||${Me.Ghost}||${Me.InCombat} 
   { 
         call snarfpotion 
         call UpdateHudStatus "Not a good time to Prep, quick exit from CombatPrep" 
         DoCombatPrep:Set[FALSE]    
         return 
         
   } 
   if !${Me.Buff[Fire Ward](exists)}&&${Spell[Fire Ward](exists)}&&!${Spell[Fire Ward].Cooldown}&&${UseFireWard}&&!${UseFrostWard}
      { 
      if ${Me.Sitting} 
         { 
         wowpress SITORSTAND 
         } 
      call CastSpell "Fire Ward" ${Me.GUID} 
      } 
   if !${Me.Buff[Frost Ward](exists)}&&${Spell[Frost Ward](exists)}&&!${Spell[Frost Ward].Cooldown}&&!${UseFireWard}&&${UseFrostWard}
      { 
      if ${Me.Sitting} 
         { 
         wowpress SITORSTAND 
         } 
      call CastSpell "Frost Ward" ${Me.GUID} 
      } 
if !${Me.Buff[Arcane Intellect](exists)} 
      { 
          
         call UpdateHudStatus "Casting Arcane Intellect" 
         call CastSpell "Arcane Intellect" ${Me.GUID} 
      } 
; Need to put in a Mage Armor option here 

 if !${Me.Buff[Ice Armor](exists)}&&${Spell[Ice Armor](exists)} 
  { 
      call CastSpell "Ice Armor" ${Me.GUID} 
      DoDowntime:Set[TRUE]
      return
  } 
 if !${Me.Buff[Frost Armor](exists)}&&!${Spell[Ice Armor](exists)} 
  { 
      call CastSpell "Frost Armor" ${Me.GUID} 
      DoDowntime:Set[TRUE]
      return
            
  } 
 
   ;Reset flag 
   DoCombatPrep:Set[FALSE] 


} 

function SetMageSummons() 
{ 
declare MageFoodSummon int 
declare MageDrinkSummon int 
declare MAGICFOOD_NAME string script 
declare MAGICWATER_NAME string script 
declare MANASTONE string script 
declare MANASTONE_SPELLNAME string script 

   MageFoodSummon:Set[${Spell[Conjure Food].Level}] 
        ;echo ${Spell[Conjure Food].Level} 
        ;echo ${MageFoodSummon} 
   Switch ${MageFoodSummon} 
   { 
      case 6 
         MAGICFOOD_NAME:Set[Conjured Muffin] 
         break 
      case 12 
              
               MAGICFOOD_NAME:Set[Conjured Bread] 
              break 
      case 22 
          
               MAGICFOOD_NAME:Set[Conjured Rye] 
              break 
      case 32 
          
         MAGICFOOD_NAME:Set[Conjured Pumpernickel] 
         break 
      case 42 
          
         MAGICFOOD_NAME:Set[Conjured Sourdough] 
         break 
      case 52    
          
         MAGICFOOD_NAME:Set[Conjured Sweet Roll] 
         break 
     case 60    
          
         MAGICFOOD_NAME:Set[Conjured Cinnamon Roll] 
         break     
   }    
    
   MageDrinkSummon:Set[${Spell[Conjure Water].Level}] 

   Switch ${MageDrinkSummon} 
   { 
      case 4 
         MAGICWATER_NAME:Set[Conjured Water] 
         break 
      case 10 
          
         MAGICWATER_NAME:Set[Conjured Fresh Water] 
         break 
      case 20 
          
         MAGICWATER_NAME:Set[Conjured Purified Water] 
         break 
      case 30    
          
         MAGICWATER_NAME:Set[Conjured Spring Water] 
         break 
      case 40    
          
         MAGICWATER_NAME:Set[Conjured Mineral Water] 
         break 
      case 50 
          
         MAGICWATER_NAME:Set[Conjured Sparkling Water] 
         break 
      case 60 
          
         MAGICWATER_NAME:Set[Conjured Crystal Water] 
         break 
   } 
    
    
    
    
    
   if ${Spell[Conjure Mana Agate](exists)}&&!${Spell[Conjure Mana Jade](exists)} 
   {    
      MANASTONE:Set[Mana Agate] 
           MANASTONE_SPELLNAME:Set[Conjure Mana Agate] 
        } 
        if ${Spell[Conjure Mana Jade](exists)}&&!${Spell[Conjure Mana Citrine](exists)} 
      { 
       
       
      MANASTONE:Set[Mana Jade] 
           MANASTONE_SPELLNAME:Set[Conjure Mana Jade] 
        } 
        if ${Spell[Conjure Mana Citrine](exists)}&&!${Spell[Conjure Mana Ruby](exists)} 
      { 
       
       
      MANASTONE:Set[Mana Citrine] 
           MANASTONE_SPELLNAME:Set[Conjure Mana Citrine] 
        } 
        if ${Spell[Conjure Mana Ruby](exists)} 
      { 
       
       
      MANASTONE:Set[Mana Ruby] 
           MANASTONE_SPELLNAME:Set[Conjure Mana Ruby] 
        } 
        
        call UpdateHudStatus "Setting Drink to ${MAGICWATER_NAME}" 
        call UpdateHudStatus "Setting Food to ${MAGICFOOD_NAME}" 
        call UpdateHudStatus "Setting Mana Stone to ${MANASTONE}" 
        
        
}    
    
function lootContainer(string itemName) 
{ 
   if !${Me.Casting} 
   { 
      Item["${itemName}"]:Use 
      wait 10 ${LootWindow(exists)} 

      lootall 
      wait 15 !${LootWindow(exists)} 
   } 
   else 
   { 
      wait 10 
   } 
} 

function check_for_lootable_containers() 
{ 
   while ${Item["Big-mouth Clam"].Slot(exists)} && ${Item["Big-mouth Clam"].Bag.Number(exists)} 
   { 
      call lootContainer "Big-mouth Clam" 
   } 
   while ${Item["Thick-shelled Clam"].Slot(exists)} && ${Item["Thick-shelled Clam"].Bag.Number(exists)} 
      { 
         call lootContainer "Thick-shelled Clam" 
   } 
   while ${Item["Bloated Catfish"].Slot(exists)} && ${Item["Bloated Catfish"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Catfish" 
   } 
   while ${Item["Bloated Mud Snapper"].Slot(exists)} && ${Item["Bloated Mud Snapper"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Mud Snapper" 
   } 
   while ${Item["Bloated Redgill"].Slot(exists)} && ${Item["Bloated Redgill"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Redgill" 
   } 
   while ${Item["Bloated Salmon"].Slot(exists)} && ${Item["Bloated Salmon"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Salmon" 
   } 
   while ${Item["Bloated Smallfish"].Slot(exists)} && ${Item["Bloated Smallfish"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Smallfish" 
   } 
   while ${Item["Bloated Trout"].Slot(exists)} && ${Item["Bloated Trout"].Bag.Number(exists)} 
   { 
      call lootContainer "Bloated Trout" 
   } 
   while ${Item["Dented Crate"].Slot(exists)} && ${Item["Dented Crate"].Bag.Number(exists)} 
   { 
      call lootContainer "Dented Crate" 
   } 
   while ${Item["Heavy Crate"].Slot(exists)} && ${Item["Heavy Crate"].Bag.Number(exists)} 
   { 
      call lootContainer "Heavy Crate" 
   } 
   while ${Item["Message in a Bottle"].Slot(exists)} && ${Item["Message in a Bottle"].Bag.Number(exists)} 
   { 
      call lootContainer "Message in a Bottle" 
   } 
   while ${Item["Sealed Crate"].Slot(exists)} && ${Item["Sealed Crate"].Bag.Number(exists)} 
   { 
      call lootContainer "Sealed Crate" 
   } 
   while ${Item["Small Chest"].Slot(exists)} && ${Item["Small Chest"].Bag.Number(exists)} 
   { 
      call lootContainer "Heavy Crate" 
   } 
   while ${Item["Waterlogged Crate"].Slot(exists)} && ${Item["Waterlogged Crate"].Bag.Number(exists)} 
   { 
      call lootContainer "Waterlogged Crate" 
   } 
   while ${Item["Battered Chest"].Slot(exists)} && ${Item["Battered Chest"].Bag.Number(exists)} 
   { 
      call lootContainer "Battered Chest" 
   } 
   while ${Item["Large Battered Chest"].Slot(exists)} && ${Item["Large Battered Chest"].Bag.Number(exists)} 
   { 
      call lootContainer "Large Battered Chest" 
   } 
} 

function usestone()
{
               if (${Item[${MANASTONE}](exists)}&&${Me.PctMana}<25)
               { 
                  call GetSpellCooldown ${MANASTONE_SPELLNAME} 
                  if ${Return(exists)}&&${Return}==0 
                  { 
                  	call UpdateHudStatus "Mana is ${Me.PctMana}, using ${MANASTONE}"
                              Item[${MANASTONE}]:Use 
                     wait 5 
                  } 
               } 
		if (${Spell[Evocation](exists)}&&${Me.PctMana}<15&&!${Spell[Evocation].Cooldown})
                  { 
                     call UpdateHudStatus "Emergency Evocation" 
                     call CastSpell "Evocation" ${Me} 
                  } 
               ;else 
               ;{ 
               ; ;use mana potions? 
               ;} 
}