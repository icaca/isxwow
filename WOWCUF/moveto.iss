;+-----------------------------------------------------------------------------------------------------
;| Name: SmartFace
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Checks your not already facing the supplied X, Y and if not then
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function SmartFace(float X,float Y)
{
     variable bool Stopping = FALSE
     ; check if we are not already facing the loc scaling the precision we want to face on the distance from the point.
     if !${Me.WillCollide[${X},${Y},((${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}/10000)*200)]}
     {
          ;Turn to face the desired loc
          if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<9||${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]}<10
          {
               ;debug("SmartFace:Close to point")
               if ${UseFaceFast}
               {
                    ;debug("SmartFace:Facing fast")
                    Face -fast ${X} ${Y}
                    wait 30 !${ISXWoW.Facing}
               }
               else
               {
                    ;debug("SmartFace:Stopping and Facing slow")
                    ;move -stop
                    if ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]}>90
                    {
                         move -stop
                         Stopping:Set[TRUE]
                    }
                    Face ${X} ${Y}
                    wait 30 !${ISXWoW.Facing}
                    if ${Stopping}
                    {
                         while ${ISXWoW.Facing}
                         {
                              wait 30 !${ISXWoW.Facing}
                         }
                         move -forward
                    }
               }
          }
          else
          {
               ;debug("SmartFace:Facing slow")
               Face ${X} ${Y}
               wait 30 !${ISXWoW.Facing}
          }           
     }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: moveto
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of  supplied X, Y then stops you.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function moveto(float X,float Y, float Precision)
{
#ifdef SKIRMISH
   if !${Me.Dead} && !${Me.Ghost}
   {
      call skirmishto ${X}, ${Y}, ${Precision}
      return
   }
#endif

   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*60)]}
   
   ;Turn to face the desired loc
   call SmartFace ${X} ${Y}

   ;Check that we are not already there!
   if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
   {
      Do
      {
         ;ensure we are still facing our target loc
         call SmartFace ${X} ${Y}

         ;press and hold the forward button
         wowpress -hold moveforward
         
         ;wait for half a second to give our pc a chance to move
         wait 5
         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
         {
            call Obstacle2
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
         SavZ:Set[${Me.Z}]
      }
      while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})
      
      ;Made it to our target loc
      wowpress -release moveforward
   }
}


;+-----------------------------------------------------------------------------------------------------
;| Name: movetocont
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of  supplied X, Y without stopping you..
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function movetocont(float X,float Y, float Precision)
{
#ifdef SKIRMISH
   if !${Me.Dead} && !${Me.Ghost}
   {
      call skirmishtocont ${X}, ${Y}, ${Precision}
      return
   }
#endif

   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
   
   ;Turn to face the desired loc
   call SmartFace ${X} ${Y}
   
   ;Check that we are not already there!
   if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
   {
      Do
      {
         ;ensure we are still facing our target loc
         call SmartFace ${X} ${Y}

         ;press and hold the forward button
         wowpress -hold moveforward
         
         ;wait for half a second to give our pc a chance to move
         wait 5
         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
         {
            debug("movetocont:Stuck")
            call Obstacle2
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
         SavZ:Set[${Me.Z}]
      }
      while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})
      
   }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: fleeto
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of  supplied X, Y omiting the check if you have 
;|              aggro. This is intended to be used for escaping whilst you are aggroed.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function fleeto(float X,float Y, float Precision)
{
   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
   
   ;Turn to face the desired loc
   call SmartFace ${X} ${Y}
   
   ;Check that we are not already there!
   if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
   {
      Do
      {
      
         ;ensure we are still facing our target loc
         call SmartFace ${X} ${Y}

         ;press and hold the forward button
         wowpress -hold moveforward

         ;wait for half a second to give our pc a chance to move
         wait 5
         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
         {
            call Obstacle2
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
         SavZ:Set[${Me.Z}]
      }
      while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(${LavishScript.RunningTime}<${BailOut})
      
      ;Made it to our target loc
      wowpress -release moveforward
   }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: skirmishto
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of supplied X, Y whilst searching for target along
;|              the route then stops you once you are within Precision yards..
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function skirmishto(float X,float Y, float Precision)
{
   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
   debug("skirmishto:Running to ${X} ${Y}")
   ;Turn to face the desired loc
   call SmartFace ${X} ${Y}
   
   ;Check that we are not already there!
   if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
   {
      Do
      {         
         ;ensure we are still facing our target loc
         call SmartFace ${X} ${Y}

         ;press and hold the forward button
         wowpress -hold moveforward

         ;wait for half a second to give our pc a chance to move
         wait 5

         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
         {
            call Obstacle2
         }
         call FindTarget
         if ${TargetGUID.NotEqual[NOTARGET]}
         {
            Return
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
         SavZ:Set[${Me.Z}]
      }
      while "(${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})"
      
      ;Made it to our target loc
      wowpress -release moveforward
   }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: skirmishtocont
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of supplied X, Y whilst searching for target along
;|              the route without stopping.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function skirmishtocont(float X,float Y, float Precision)
{
   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   ;set BailOut timer (4 minutes)
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
   debug("skirmishtocont:Running to ${X} ${Y}")
   ;Turn to face the desired loc
   call SmartFace ${X} ${Y}
   
   ;Check that we are not already there!
   if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
   {
      Do
      {
         ;ensure we are still facing our target loc
         call SmartFace ${X} ${Y}

         ;press and hold the forward button
         wowpress -hold moveforward
         
         ;wait for half a second to give our pc a chance to move
         wait 5
         ;check to make sure we have moved if not then try and avoid the
         ;obstacle thats in our path
         if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
         {
            call Obstacle2
         }
         call FindTarget
         if ${TargetGUID.NotEqual[NOTARGET]}
         {
            Return
         }
         ;store our current location for future checking
         SavX:Set[${Me.X}]
         SavY:Set[${Me.Y}]
         SavZ:Set[${Me.Z}]
      }
      while "(${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})"
      
      ;Made it to our target loc
   }
}


;+-----------------------------------------------------------------------------------------------------
;| Name: movetoobject
;| In: ObjectGUID, MaxDist, MinDist
;| Returns: none
;| File: moveto.iss
;| Description: This function moves you to within MaxDist yards of the specified Object and no
;|              closer than MinDist.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function movetoobject(string ObjectGUID,float MaxDist=10,float MinDist=1)
{
   declare Index int local 0
   declare SavX float local ${Me.X}
   declare SavY float local ${Me.Y}
   declare SavZ float local ${Me.Z}
   declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*120)]}
   declare StuckCheck bool local FALSE
   declare StuckCheckTime int local
   
   ;Check our arguments are sensible
   if ${MinDistance}>${MaxDistance}
   {
      echo Invalid arguments min distance must be less than max
      return "ERROR"
   }
      
   if ${MinDist}<0||${MaxDist}<0
   {
      echo Invalid value for min or max distance
      return "ERROR"
   }
      
   if ${GUID.Equal[NULL]}
   {
      echo no object specified
      return "NOTARGET"
   }
   
   Do
   {
      SavX:Set[${Me.X}]
      SavY:Set[${Me.Y}]
      SavZ:Set[${Me.Z}]
      
      ; Ensure we are still facing our target loc
      call SmartFace ${Object[${ObjectGUID}].X} ${Object[${ObjectGUID}].Y}
      
      ;If too far away run forward
      if ${Object[${ObjectGUID}].Distance}>${MaxDist}
      {
         debug("movetoobject:Too far closing")
         ;press and hold the forward button
         wowpress -release movebackward
         wowpress -hold moveforward
      }

      ;If too close then run backward
      if ${Object[${ObjectGUID}].Distance}<${MinDist}
      {
         debug("movetoobject:Too close backing up")
         ;press and hold the backward button
         wowpress -release moveforward
         wowpress -hold movebackward
      }
      
      ;If we are close enough stop running
      if ${Object[${ObjectGUID}].Distance}>${MinDist}&&${Object[${ObjectGUID}].Distance}<${MaxDist}
      {
         wowpress -release moveforward
         wowpress -release movebackward
         StuckCheck:Set[FALSE]
      }

      ;If the object disappeard then bail out
      if !${Object[${ObjectGUID}](exists)}
      {
         debug("movetoobject:Object i was moving too disappeared")
         return
      }
      
      ;wait for half a second to give our pc a chance to move
      wait 5
      
      ; Check to make sure we have moved if not then try and avoid the
      ; obstacle thats in our path
      if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Object[${ObjectGUID}].Distance}>${MaxDist}
      {
         ; I think i might be stuck so save off the current time
         if !${StuckCheck}
         {
            debug("movetoobject:I might be stuck")
            StuckCheck:Set[TRUE]
            StuckCheckTime:Set[${LavishScript.RunningTime}]
         }
         else
         {
            ; If I am still stuck after 8 seconds then try and avoid the obstacle.
            if ${LavishScript.RunningTime}-${StuckCheckTime}>8000
            {
               debug("movetoobject:Yep I am stuck trying to free myself")
               call Obstacle
               StuckCheck:Set[FALSE]
            }
         }
      }
      
      ; If I have moved away from my saved spot reset my stuck toggle
      if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
      {
         debug("movetoobject:I am no longer stuck")
         StuckCheck:Set[FALSE]
      }
      
   }
   while (${Object[${ObjectGUID}].Distance}>${MaxDist}||${Object[${ObjectGUID}].Distance}<${MinDist})&&${LavishScript.RunningTime}<${BailOut}&&${Index:Inc}<=15

   wowpress -release movebackward
   wowpress -release moveforward
}

;+-----------------------------------------------------------------------------------------------------
;| Name: movetopoint
;| In: filename, world, EndPoint
;| Returns:
;| File: moveto.iss
;| Description: Load the navigation file specified by filename and then plots a path in the world
;|              specified by world to the point specified by EndPoint.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function movetopoint(string filename,string world,string EndPoint)
{
   declare NearestPoint string local
   declare PathIndex int local 1
   declare MovePath navpath local

   ; Load the navigation file
   Navigation -load ${filename}
   
   ; Retrieve the name of the navpoint closest to our current location
   NearestPoint:Set[${Navigation.World["${world}"].NearestPoint[${Me.X},${Me.Y}]}]
   
   ; Generate a path to our destination point
   MovePath:GetPath["${world}","${NearestPoint}","${EndPoint}"]
   
   ; If we have a valid path then loop around walking to each step
   if ${MovePath.Points}>0
   {
      call UpdateHudStatus "Running from ${NearestPoint} to ${EndPoint}"
      call UpdateHudStatus "This journey will be ${MovePath.Points} points long"
      do
      {
         call moveto ${MovePath.Point[${PathIndex}].X} ${MovePath.Point[${PathIndex}].Y} 5
         call UpdateHudStatus ${Navigation.World["${world}"].NearestPoint[${Me.X},${Me.Y}]}
         PathIndex:Inc
      }
      while ${PathIndex}<=${MovePath.Points}&&!${Me.InCombat}&&!${Me.Dead}
      return "PATH_COMPLETE"
   }
   else
   {
      call UpdateHudStatus "No valid path found"
      return "INVALID_PATH"
   }


}


;+-----------------------------------------------------------------------------------------------------
;| Name: Obstacle
;| In:
;| Returns:
;| File: moveto.iss
;| Description: Function to do a backup and a random strafe to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function Obstacle()
{
   call UpdateHudStatus "Stuck, backing up"

   ;backup a little
   wowpress -release moveforward
   wowpress -hold movebackward
   wait 10
   wowpress -release movebackward

   ;randomly pick a direction
   if ${Math.Rand[10]}>5
   {
      call UpdateHudStatus "Strafing Left"
      ;use lau to strafe left
      WoWScript StrafeLeftStart(GetTime() * 1000 )
      wait 5
      WoWScript StrafeLeftStop((GetTime() + 1.5) * 1000 )
      wait 30
   }
   else
   {
      call UpdateHudStatus "Strafing Right"
      ;use lau to strafe right
      WoWScript StrafeRightStart(GetTime() * 1000 )
      wait 5
      WoWScript StrafeRightStop((GetTime() + 1.5) * 1000 )
      wait 30
   }
   call UpdateHudStatus "Advancing"
   ;Start moving forward again
   wowpress -hold moveforward
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Obstacle2
;| In:
;| Returns:
;| File: moveto.iss
;| Description: Function to do a backup and a random turn to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function Obstacle2()
{
   call UpdateHudStatus "Stuck, backing up"

   ;backup a little
   move -stop
   wowpress -hold movebackward
   wait 10
   wowpress -release movebackward

   ;randomly pick a direction
   if ${Math.Rand[10]}>5
   {
      call UpdateHudStatus "Running Left"
      ;turn left a bit
      Turn -45
      wowpress -hold moveforward
      wait 30
   }
   else
   {
      call UpdateHudStatus "Running Right"
      ;turn right a bit
      Turn 45
      wowpress -hold moveforward
      wait 30
   }
   call UpdateHudStatus "Advancing"
   ;Start moving forward again
   wowpress -hold moveforward
}


;+-----------------------------------------------------------------------------------------------------
;| Name: WalkPath
;| In: world, StartPoint, EndPoint
;| Returns:
;| File: moveto.iss
;| Description: Plots a path in the world specified by world between the points specified by StartPoint
;|              and EndPoint.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function WalkPath(string world,string StartPoint,string EndPoint)
{
   declare PathIndex int local 1
   declare MovePath navpath local
   
   call UpdateHudStatus "Running from ${StartPoint} to ${EndPoint}"
   MovePath:GetPath["${world}","${StartPoint}","${EndPoint}"]
   
   if "${MovePath.Points}>0"
   {
      call UpdateHudStatus "This journey will be ${MovePath.Points} points long"
      do
      {
         call moveto ${MovePath.Point[${PathIndex}].X} ${MovePath.Point[${PathIndex}].Y} 5
         call UpdateHudStatus ${Navigation.World["${world}"].NearestPoint[${Me.X},${Me.Y}]}
         PathIndex:Inc
      }
      while "${PathIndex}<=${MovePath.Points}&&!${Me.InCombat}"
      return "PATH_COMPLETE"
   }
   else
   {
      call UpdateHudStatus "No valid path found"
      return "INVALID_PATH"
   }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: MoveToNearestPoint
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Loads a Navigation file, then find the nearest point
;|              to you.
;|
;| ©200X Fippy
;+-----------------------------------------------------------------------------------------------------

function MoveToNearestPoint(string filename,string world)
{
   declare NearestPoint string local
   
   Navigation -load ${filename}

   NearestPoint:Set["${Navigation.World["${world}"].NearestPoint[${Me.X},${Me.Y}]}"]
   call UpdateHudStatus "Running to ${NearestPoint}"
   call moveto ${Navigation.World["${world}"].Point[${NearestPoint}].X} ${Navigation.World["${world}"].Point[${NearestPoint}].Y} 5
   call UpdateHudStatus "Made it to ${NearestPoint}"
}

;+-----------------------------------------------------------------------------------------------------
;| Name: MoveToSafeSpot
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Moves you to the safest (determined my the proximity of possible aggros) nearby spot
;|
;| ©200X Fippy
;+-----------------------------------------------------------------------------------------------------

function MoveToSafeSpot()
{
   declare Index int local 1
   declare TargetList guidlist local
   declare TestLocX float 
   declare TestLocY float
   declare radius int local 10
   declare degrees int local
   declare TestDist float local
   declare GoodLoc bool local FALSE
   declare CurrentSafestX float ${Me.X}
   declare CurrentSafestY float ${Me.Y}
   declare CurrentLargestDist float 100

   call UpdateHudStatus "Looking for Safe Spot"
   
   ;Get all the targets that are within 60 of my corpse
   TargetList:Search[-units,-nearest,-nopets,-alive,-untapped,-nonfriendly,-range 60]

   ;Look for a safe spot circling outwards
   ;If the nearest target is far enough away or there are no targets then we are safe already
   if ${TargetList.Count}<1||${Unit[${TargetList.GUID[1]}].Distance]}>25
   {
      call UpdateHudStatus "We are already Safe"
      move -stop
      return
   }

   ;Were not already safe so lets search by checking the distance to all targets
   ;We will search outwards every 10 yards up to 30 yards
   do
   {
      debug("MoveToSafeSpot:Radius-${radius}")
      ;We will search every 20 degrees
      degrees:Set[0]
      do
      {
         debug("MoveToSafeSpot:Degrees-${degrees}")
         TestLocX:Set[${Me.X} + (${radius}*${Math.Cos[${degrees}]})]
         TestLocY:Set[${Me.Y} + (${radius}*${Math.Sin[${degrees}]})]
         GoodLoc:Set[FALSE]
         Index:Set[1]
         do
         {
            ;Test each unit for its distance from our chosen loc
            TestDist:Set[${Math.Distance[${TestLocX},${TestLocY},${Unit[${TargetList.GUID[${Index}]}].X},${Unit[${TargetList.GUID[${Index}]}].Y}]}]
            ;See if this distant is greater than our current best
            if ${TestDist}<${CurrentLargestDist}
            {
               CurrentSafestX:Set[${TestLocX}]
               CurrentSafestY:Set[${TestLocY}]
               CurrentLargestDist:Set[${TestDist}]
            }
            
            ;If we are greater than the unit assist radius then this is a safe space
            debug("MoveToSafeSpot:LargestDist ${CurrentLargestDist}")
            if ${CurrentLargestDist}>25
            {
               GoodLoc:Set[TRUE]
            }
         }
         while ${Index:Inc}<=${TargetList.Count}&&!${GoodLoc}
         ;if we have checked all units and its still not a bad loc then we have our spot
         if ${GoodLoc}
         {
            call UpdateHudStatus "Moving to safe location ${CurrentSafestX} ${CurrentSafestY}"
            call moveto ${CurrentSafestX} ${CurrentSafestY} 3
            move -stop
            return
         }
      }
      while ${degrees:Inc[20]}<360
      
   }
   while ${radius:Inc[10]}<31

   call UpdateHudStatus "No safe spot found best loc is ${CurrentSafestX} ${CurrentSafestY}"
   call moveto ${CurrentSafestX} ${CurrentSafestY} 3
   move -stop
   return

}

;+-----------------------------------------------------------------------------------------------------
;| Name: SmartFacePrecision
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Checks your not already facing the supplied X, Y and if not then turn, using precision(Default 45 degrees)
;|
;| ©200X Fippy
;+-----------------------------------------------------------------------------------------------------

function SmartFacePrecision(float X,float Y, int PRECISION=35)
{
     ;Turn to face the desired loc
     if ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]}>${PRECISION}
     {
           ;debug("SmartFace:Close to point")
           if ${UseFaceFast}
           {
                ;debug("SmartFace:Facing fast")
                Face -fast ${X} ${Y}
                        wait 30 !${ISXWoW.Facing}
           }
           else
           {
                Face ${X} ${Y}
                wait 30 !${ISXWoW.Facing}
           }
     }
}