; Warrior Routines
; Beaky_Buzzard with code stolen from everyone!

;Leave this define Intact. Its testing if this file is loaded or not.
#define ROUTINES

; Desired pet.
#define PREFERREDPET Succubus

; Use Wand? 0 = NO 1 = YES NOTE: If you are drain tanking you do not want to use your wand
#define USEWAND 0

; How much soulshards you want minimum
#define SOULSHARDS 20

; Percentage of health you want to keep your pet above
#define PETHP 50

; Percentage of health you want to drain life at SET to around 90 for drain tanking 60 for pet tanking
#define DRAIN 90

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
  declare SoulShards int local
  declare ShardList guidlist local
  declare Wanding bool local FALSE
  declare Petsent bool local FALSE


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
    if !${Me.Attacking}&&${Target(exists)}&&!${Me.Equip[18](exists)}
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

    ; If we are not close enough for spell then move closer
    if ${Unit[${AttackGUID}].Distance}>${PullingRange}
    {
      call UpdateHudStatus "Moving closer to target"
      call SmartFacePrecision ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y}
      wowpress -hold moveforward
      wait 15
      wowpress -release moveforward
    }

    ; Check if we have pulled yet and if not do so.
    if ${Unit[${AttackGUID}].Distance}<${PullingRange}&&!${HavePulled}
    {
      if ${Spell[Curse of Agony](exists)}&&!${Spell[Curse of Agony].Cooldown}
      {
        if ${Wanding}
        {
          Wanding:Set[FALSE]
          wowscript SpellStopCasting()
          wait 10
        }
        call CastSpell "Curse of Agony" ${AttackGUID}
        wait 5
      }
      else
      {
        ; Were not high enough pull with Shadow Bolt
        if ${Wanding}
        {
          Wanding:Set[FALSE]
          wowscript SpellStopCasting()
          wait 10
        }
        call CastSpell "Shadowbolt" ${AttackGUID}
      }
      if ${Me.Pet(exists)}
      {
        call UpdateHudStatus "Sending in Pet"
        wowscript PetAttack()
        Petsent:Set[TRUE]
      }
      HavePulled:Set[TRUE]
    }


    ; This should be called if we tried to pull but the mob was too far away
    if !${Me.Pet.Target(exists)}&&!${Petsent}
    {
      call UpdateHudStatus "Pet wasnt sent"
      wowscript PetAttack()
      Petsent:Set[TRUE]
    }

    ; Start main attack routine

    Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-20]
    if ${Aggros.Count}>1
    {
      ; Multi Target Attack
    }

    ; Normal Attacks on Main Target
    ; If all curses are on and we have a wand and not wanding lets wand
    if !${Wanding}&&!${Me.Casting}&&${Me.Equip[18](exists)}
    {
      ; Assume it is TRUE now and will turn off if not eligible
      Wanding:Set[TRUE]
      if ${Spell[Curse of Agony](exists)}
      {
        if !${Unit[${AttackGUID}].Buff[Curse of Agony](exists)}
        {
          ; They dont have it why are we wanding?
          Wanding:Set[FALSE]
        }
      }
      if ${Spell[Immolate](exists)}
      {
        if !${Unit[${AttackGUID}].Buff[Immolate](exists)}
        {
          ; They dont have it why are we wanding?
          Wanding:Set[FALSE]
        }
      }
      if ${Spell[Corruption](exists)}
      {
        if !${Unit[${AttackGUID}].Buff[Corruption](exists)}
        {
          ; They dont have it why are we wanding?
          Wanding:Set[FALSE]
        }
      }
      if ${Spell[Siphon Life](exists)}
      {
        if !${Unit[${AttackGUID}].Buff[Siphon Life](exists)}
        {
          ; They dont have it why are we wanding?
          Wanding:Set[FALSE]
        }
      }
      if USEWAND==0
      {
        Wanding:Set[FALSE]
      }
      ; Now that we have checked all Dots lets ethier wand or turn it off
      if ${Wanding}
      {
        call CastSpell "Shoot" ${AttackGUID}
      }
      else
      {
        wowscript SpellStopCasting()
        wait 10
      }
    }

    ; We shouldnt be wanding now if we need to apply a any spell listed above
    if !${Unit[${AttackGUID}].Buff[Corruption](exists)}&&${Spell[Corruption](exists)}&&!${Spell[Corruption].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>25
    {
      call CastSpell "Corruption" ${AttackGUID}
      wait 5
    }
    if !${Unit[${AttackGUID}].Buff[Curse of Agony](exists)}&&${Spell[Curse of Agony](exists)}&&!${Spell[Curse of Agony].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>25
    {
      call CastSpell "Curse of Agony" ${AttackGUID}
      wait 5
    }
    if !${Unit[${AttackGUID}].Buff[Immolate](exists)}&&${Spell[Immolate](exists)}&&!${Spell[Immolate].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>25
    {
      call CastSpell "Immolate" ${AttackGUID}
      wait 5
    }
    if !${Unit[${AttackGUID}].Buff[Siphon Life](exists)}&&${Spell[Siphon Life](exists)}&&!${Spell[Siphon Life].Cooldown}&&${Unit[${AttackGUID}].PctHPs}>25
    {
      call CastSpell "Siphon Life" ${AttackGUID}
      wait 5
    }

    ; Will add in Pet Abilities here soon

    ; If I have Dark Pact and a pet I need its mana
    if ${Me.Pet(exists)} && ${Spell[Dark Pact](exists)} && ${Me.PctMana}<50 && ${Me.Pet.PctMana}>10
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 12
      }
      if ${Me.Pet.PctMana}>10 && ${Me.PctMana}<90
      {
        call CastSpell "Dark Pact"
      }
    }


    ; If we are getting low on health lets suck it from the target
    if ${Me.PctHPs}<DRAIN&&${Spell[Drain Life](exists)}&&!${Spell[Drain Life].Cooldown}
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 10
      }
      call CastSpell "Drain Life" ${AttackGUID}
      wait 5
    }

    ; If we are in a Shadow Trance toss that Shadow Bolt
    if ${Me.Buff[Shadow Trance](exists)}&&!${Spell[Shadow Bolt].Cooldown}
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 15
      }
      call CastSpell "Shadow Bolt" ${AttackGUID}
    }

    ; If we have Shadowburn and mob is < 30% and we have more then 3 Soul Shards toss it
    ShardList:Search[-items,-inventory,Soul Shard]
    if ${Spell[Shadowburn](exists)}&&!${Spell[Shadowburn].Cooldown}&&${Unit[${AttackGUID}].PctHPs}<30&&${ShardList.Count}>3
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 15
      }
      call CastSpell "Shadowburn" ${AttackGUID}
    }

    ; If mob is low on health and we need to drain its soul do it
    ShardList:Search[-items,-inventory,Soul Shard]
    if ${ShardList.Count}< SOULSHARDS && ${Unit[${AttackGUID}].PctHPs}<40
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 10
      }
      call CastSpell "Drain Soul" ${AttackGUID}
    }

    ; If all is good and mana is low lets TAP some mana
    if ${Me.PctHPs}>50&&${Me.PctMana}<30&&${Spell[Life Tap](exists)}&&!${Spell[Life Tap].Cooldown}
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 10
      }
      call CastSpell "Life Tap" ${Me.GUID}
      wait 5
    }

    ; Lets Check our pet
    if ${Me.Pet.PctHPs}<PETHP&&${Spell[Health Funnel](exists)}&&${Me.PctHPs}>20&&!${Spell[Health Funnel].Cooldown}
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 10
      }
      call CastSpell "Health Funnel"
    }

    ; Check if we wish to flee combat or not
    Aggros:Search[-units,-nearest,-aggro,-alive, -range 0-${Math.Calc[${MaxRoam}/2]}]

    ; If I am low Use a Healthstone first
    if ${Me.PctHPs}<30
    {
      if ${Wanding}
      {
        Wanding:Set[FALSE]
        wowscript SpellStopCasting()
        wait 10
      }
      call Use_HealthStone
    }
    ; If we are still low quaff a Health Potion if we are low
    if ${Me.PctHPs}<30
    {
      call UpdateHudStatus "Quaffing potion LOW HEALTH"
      ;call DrinkBestHealingPotion
    }

    ; Bail out of we are low
    if ${Me.PctHPs}<20
    {
      call UpdateHudStatus "LOW HEALTH BAILING OUT!"
      RLG:Set[TRUE]
      return
    }
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
    call SmartFacePrecision ${Unit[${AttackGUID}].X} ${Unit[${AttackGUID}].Y}

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

  ; If we are dead or a ghost why are we here?
  if ${Me.Dead} || ${Me.Ghost}
  {
    ; Reset downtime flag
    DoDowntime:Set[FALSE]
    return
  }

  Do
  {
    ; If I have Dark Pact and a pet I need its mana
    if ${Me.Pet(exists)} && ${Spell[Dark Pact](exists)} && !${Me.Sitting}
    {
      if ${Me.Pet.PctMana}>10 && ${Me.PctMana}<90
      {
        Cast "Dark Pact"
      }
    }
    ; If I am full and still eatting or drinking lets stand back up
    if ${Me.Buff[Drink](exists)} || ${Me.Buff[Food](exists)}
    {
      if ${Me.PctMana}>99 && ${Me.PctHPs}>99
      {
        if ${Me.Sitting}
        {
          wowpress SITORSTAND
        }
      }
    }

    if ${Me.PctMana}<${MinManaPct} && !${Me.Buff[Drink](exists)}
    {
      call Drink
      wait 15 ${Me.Buff[Drink](exists)}
    }
    if ${Me.PctHPs}<${MinHealthPct} && !${Me.Buff[Food](exists)}
    {
      call Eat
      wait 15 ${Me.Buff[Food](exists)}
    }

    ; If we are not sitting then lets do our downtime
    if !${Me.Sitting}
    {
      ; Create a health stone if we dont have one
      call Create_HealthStone

      ;If we dont have a PET make one NOW!
      if !${Me.Pet(exists)}
      {
        call UpdateHudStatus "Summoning a new pet"
        if (${Item[Soul Shard](exists)}&&${Spell[Summon PREFERREDPET](exists)}) || ${Spell[Summon PREFERREDPET](exists)}
        {
          call CastSpell "Summon PREFERREDPET"  ${Me.GUID}
          wait 10
        }
      }

      ; Check Demon Armor Buff
      if (!${Me.Buff[Demon Armor](exists)}&&${Spell[Demon Armor](exists)})
      {
        call UpdateHudStatus "Casting Demon Armor"
        call CastSpell "Demon Armor" ${Me.GUID}
      }

      ; Check Demon Armor Buff
      if (!${Me.Buff[Demon Skin](exists)}&&!${Spell[Demon Armor](exists)})
      {
        call UpdateHudStatus "Casting Demon Skin"
        call CastSpell "Demon Skin" ${Me.GUID}
      }

      ; Check Detect Invisibility Buff
      if (!${Me.Buff[Detect Invisibility](exists)}&&${Spell[Detect Invisibility](exists)})
      {
        call UpdateHudStatus "Casting Detect Invisibility"
        call CastSpell "Detect Invisibility" ${Me.GUID}
      }

      ; Check Detect Lesser Invisibility
      if (!${Me.Buff[Detect Lesser Invisibility](exists)}&&${Spell[Detect Lesser Invisibility](exists)})&&!${Spell[Detect Invisibility](exists)}
      {
        call UpdateHudStatus "Casting Detect Lesser Invisibility"
        call CastSpell "Detect Lesser Invisibility" ${Me.GUID}
      }

    }

    ; If we are dead or a ghost why are we here?
    if ${Me.Dead} || ${Me.Ghost}
    {
      ; Reset downtime flag
      DoDowntime:Set[FALSE]
      return
    }

    ; If we are in combat stop reseting
    if ${Me.InCombat}
    {
      call UpdateHudStatus "Agroed getting out of Downtime"
      DoDowntime:Set[FALSE]
      return
    }

    ; If the pet is low on health and we arnt give him some love
    if ${Me.Pet(exists)}&&${Me.Pet.PctHPs}<75 && ${Me.PctHPs}>75
    {
      if ${Spell[Health Funnel](exists)} && !${Spell[Health Funnel].Cooldown}
      {
        call CastSpell "Health Funnel"
        wait 10
      }
    }
  }
  while ${Me.PctHPs}<${MinHealthPct} || ${Me.Pet.PctHPs}<70 || ${Me.PctMana}<${MinManaPct}

  if ${Me.Sitting}
  {
    wowpress SITORSTAND
  }


  ; Reset downtime flag
  DoDowntime:Set[FALSE]
}

function Create_HealthStone()
{
  declare ShardList guidlist local

  ; If we are already casting.. Return from here
  if ${Me.Casting}
  {
    return;
  }
  ; If we already have a healthstone just return back
  if ${Item[Healthstone](exists)}
  {
    return
  }

  ShardList:Search[-items,-inventory,Soul Shard]

  ; If we dont have enough shards then dont make
  if ${ShardList.Count}<= 2
  {
    call UpdateHudStatus "Not enough shards to make a health stone"
    return
  }

  if ${Spell[Create Healthstone (Major)](exists)}
  {
    cast "Create Healthstone (Major)"
    wait 40
    return
  }
  if ${Spell[Create Healthstone (Greater)](exists)}
  {
    cast "Create Healthstone (Greater)"
    wait 40
    return
  }
  if ${Spell[Create Healthstone](exists)}
  {
    cast "Create Healthstone"
    wait 40
    return
  }
  if ${Spell[Create Healthstone (Lesser)](exists)}
  {
    cast "Create Healthstone (Lesser)"
    wait 40
    return
  }
  if ${Spell[Create Healthstone (Minor)](exists)}
  {
    cast "Create Healthstone (Minor)"
    wait 40
    return
  }
}

function Use_HealthStone()
{

  if ${Item[Major Healthstone](exists)}
  {
    Item[Major Healthstone]:Use
    return
  }
  if ${Item[Greater Healthstone](exists)}
  {
    Item[Greater Healthstone]:Use
    return
  }
  if ${Item[Healthstone](exists)}
  {
    Item[Healthstone]:Use
    return
  }
  if ${Item[Lesser Healthstone](exists)}
  {
    Item[Lesser Healthstone]
    return
  }
  if ${Item[Minor Healthstone](exists)}
  {
    Item[Minor Healthstone]:Use
    return
  }

}
