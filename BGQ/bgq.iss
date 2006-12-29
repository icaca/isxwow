;A small script to queue up to all Battlegrounds
;proceed to wowbot within the BG 
;repeat the process when the bg is over 

function main() 
{ 
  declare bgwinner string   script   ""
  declare AVStatus string script ""
  declare ABStatus string script ""
  declare WSGStatus string script ""
  declare QueueWSG bool script FALSE
  declare QueueAB bool script TRUE
  declare QueueAV bool script FALSE
  
  while TRUE 
  { 
    echo "Running auto BG queue..."
    if ${Me.Buff[Deserter](exists)} 
    {
      do
      {
        wait 10
        ISXWoW:ResetIdle
      }
      while ${Me.Buff[Deserter](exists)} 
    }
    call queue
    echo "Waiting for the first BG to open up." 
    do 
    { 
      if ${Math.Rand[100]} > 95
      { 
        ISXWoW:ResetIdle
      }
      wait 50
      AVStatus:Set[${WoWScript[GetBattlefieldStatus(1)]}]
      ABStatus:Set[${WoWScript[GetBattlefieldStatus(2)]}]
      WSGStatus:Set[${WoWScript[GetBattlefieldStatus(3)]}]
    } 
    while ${AVStatus.NotEqual[confirm]} && ${ABStatus.NotEqual[confirm]} && ${WSGStatus.NotEqual[confirm]}
    do
    {
      call EnterAV
      call EnterAB
      call EnterWSG
    }
    while !${WoWScript[GetBattlefieldInstanceRunTime()]} && ${bgwinner.Equal[NULL]}
  }
}
    
function EnterAV()
{
  echo Checking for AV Confirmation!
  if ${WoWScript[GetBattlefieldStatus(1)].Equal["confirm"]} 
  {
    WoWScript StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY") 
    echo "Entering Alterac Valley." 
    wait 2 
    Press Esc 
    wait 2 
    WoWScript AcceptBattlefieldPort(1,true) 
    do
    {
      ;echo Waiting for Battlefield Runtime.
      waitframe
      wait 100
      echo Waiting for Battlefield Runtime 120000:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    }
    while ${WoWScript[GetBattlefieldInstanceRunTime()]} < 120000
    ;run wowbot 
    if ${WoWScript[GetBattlefieldInstanceRunTime()]} > 130000
    {
       echo Running Wowbot in 5 seconds...
       wait 50
    }
    echo We're past 120000, what time is it?:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    run wowbot/wowbot 
    ;check to see if there is a winner 
    bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    ;sit tight until someone wins or i'm removed from the BG.
    while ${bgwinner.Equal[NULL]} && ${WoWScript[GetBattlefieldInstanceRunTime()]}
    { 
      wait 100
      waitframe 
      bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    } 
    wait 10 
    ;end the bot 
    echo Ending Wowbot...
    endscript wowbot 
    wait 200
    ;leave the BG 
    WoWScript LeaveBattlefield() 
    wait 300 
  }
}

function EnterAB()
{
  echo Checking for AB Confirmation!
  if ${WoWScript[GetBattlefieldStatus(2)].Equal["confirm"]} 
  {
    WoWScript StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY") 
    echo "Entering Arathi Basin." 
    wait 2 
    Press Esc 
    wait 2 
    WoWScript AcceptBattlefieldPort(2,true) 
    do
    {
      ;echo Waiting for Battlefield Runtime.
      waitframe
      wait 100
      echo Waiting for Battlefield Runtime 120000:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    }
    while ${WoWScript[GetBattlefieldInstanceRunTime()]} < 120000
    ;run wowbot 
    if ${WoWScript[GetBattlefieldInstanceRunTime()]} > 130000
    {
       echo Running Wowbot in 5 seconds...
       wait 50
    }
    echo We're past 120000, what time is it?:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    run wowbot/wowbot 
    ;check to see if there is a winner 
    bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    ;sit tight until someone wins or i'm removed from the BG.
    while ${bgwinner.Equal[NULL]} && ${WoWScript[GetBattlefieldInstanceRunTime()]}
    { 
      wait 100
      call EnterAV
      bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    } 
    wait 10 
    ;end the bot 
    echo Ending Wowbot...
    endscript wowbot 
    wait 200
    ;leave the BG 
    WoWScript LeaveBattlefield() 
    wait 300 
  }
}

function EnterWSG()
{
  echo Checking for WSG Confirmation!
  if ${WoWScript[GetBattlefieldStatus(3)].Equal["confirm"]} 
  {
    WoWScript StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY") 
    echo "Entering Warsong Gulch." 
    wait 2 
    Press Esc 
    wait 2 
    WoWScript AcceptBattlefieldPort(3,true) 
    do
    {
      ;echo Waiting for Battlefield Runtime.
      waitframe
      wait 100
      echo Waiting for Battlefield Runtime 120000:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    }
    while ${WoWScript[GetBattlefieldInstanceRunTime()]} < 120000
    ;run wowbot 
    if ${WoWScript[GetBattlefieldInstanceRunTime()]} > 130000
    {
       echo Running Wowbot in 5 seconds...
       wait 50
    }
    echo We're past 120000, what time is it?:  ${WoWScript[GetBattlefieldInstanceRunTime()]}
    run wowbot/wowbot 
    ;check to see if there is a winner 
    bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    ;sit tight until someone wins or i'm removed from the BG.
    while ${bgwinner.Equal[NULL]} && ${WoWScript[GetBattlefieldInstanceRunTime()]}
    { 
      wait 100
      call EnterAV
      bgwinner:Set[${WoWScript[GetBattlefieldWinner()]}] 
    } 
    wait 10 
    ;end the bot 
    echo Ending Wowbot...
    endscript wowbot 
    wait 200
    ;leave the BG 
    WoWScript LeaveBattlefield() 
    wait 300 
  }
}

function queue()
{
  echo Entering Queue()
  declare AVMaster string local
  declare ABMaster string local
  declare WSGMaster string local
  switch ${Me.FactionGroup}
  {
    case Alliance
      switch ${WoWScript[GetRealZoneText()]}
      {
        case Ironforge
          AVMaster:Set[Glordrum Steelbeard]
          ABMaster:Set[Donal Osgood]
          WSGMaster:Set[Lylandris]
          break
      }
    break
    case Horde
      switch ${WoWScript[GetRealZoneText()]}
      {
        case Orgrimmar
          AVMaster:Set[Kartra Bloodsnarl]
          ABMaster:Set[Deze Snowbane]
          WSGMaster:Set[Brakgul Deathbringer]
          break
      }
    break
  }
  if ${WoWScript[GetBattlefieldStatus(1)].NotEqual["confirm"]} && ${QueueAV}
  {
    Target "${AVMaster}"
    wait 20
    call moveto ${Target.X} ${Target.Y}
    Unit[${AVMaster}]:Use
    wait 20
    WoWScript SelectGossipOption(1)
    wait 20
    WoWScript JoinBattlefield(0)
    wait 20
    Press Esc
  }
  if ${WoWScript[GetBattlefieldStatus(2)].NotEqual["confirm"]} && ${QueueAB}
  {
    Target "${ABMaster}"
    wait 20
    call moveto ${Target.X} ${Target.Y}
    Unit[${ABMaster}]:Use
    wait 20
    WoWScript SelectGossipOption(1)
    wait 20
    WoWScript JoinBattlefield(0)
    wait 20
    Press Esc
  }
  if ${WoWScript[GetBattlefieldStatus(3)].NotEqual["confirm"]} && ${QueueWSG}
  {
    Target "${WSGMaster}"
    wait 20
    call moveto ${Target.X} ${Target.Y}
    Unit[${WSGMaster}]:Use
    wait 20
    WoWScript SelectGossipOption(1)
    wait 20
    WoWScript JoinBattlefield(0)
    wait 20
    Press Esc
  }  
}

function moveto(float X,float Y)
{
  Face ${X} ${Y}
  wait 10 !${ISXWoW.Facing}
  move forward
  do
  {
    if !${ISXWoW.Facing}
    Face ${X} ${Y}
    wait 2
  }
  while "${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} > 1"
  move -stop forward
}   
