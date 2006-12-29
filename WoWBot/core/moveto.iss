;+-----------------------------------------------------------------------------------------------------
;| Name: SmartFace
;| In: X,Y
;| Returns: 
;| Description: Checks your not already facing the supplied X, Y and if not then 
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function SmartFace(float X,float Y)
{
	if ${ISXWoW.Facing}
	   return
	declare distance float local ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}
	
	; check if we are not already facing the loc scaling the precision we want to face on the distance from the point.
	;debug("SmartFace: if (${distance}<10 && !${Me.WillCollide[${X},${Y},2]}) || (${distance}>9 && !${Me.WillCollide[${X},${Y},${Math.Calc[5+(${distance}/5)]}]})")
	if (${distance}<10 && !${Me.WillCollide[${X},${Y},2]}) || (${distance}>9 && !${Me.WillCollide[${X},${Y},${Math.Calc[5+(${distance}/5)]}]})
	{
		;Turn to face the desired loc
		if ${distance}<9||${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]}<10
		{
			;debug("SmartFace:Facing fast")
			Face -fast ${X} ${Y}
			call CheckFacing
			wait 1
		}
		else
		{
			;debug("SmartFace:Facing slow")
			Face ${X} ${Y}
			call CheckFacing
			
		}		
	}
}
;+-----------------------------------------------------------------------------------------------------
;| Name: CheckFacing
;| In: 
;| Returns: 
;| Description: Checks to see if you are spinning and stops you
;|
;| ©2006 
;+-----------------------------------------------------------------------------------------------------
function CheckFacing() 
{ 
  wait 3 !${ISXWoW.Facing} 
  if ${ISXWoW.Facing} 
  { 
    face -stop 
  } 
} 
;------------------------------------------------------------------------------------------------------
; IsPathObstructed by eqjoe 
;
;
;
;------------------------------------------------------------------------------------------------------
function IPO(float X,float Y,float Z)
{

	
	declare radius int local 0
	declare degrees int local 0
	declare TestDist float local 
	declare GoodLoc bool local FALSE
	declare TargetDistTemp float local 
	declare TestPoint bool local 
	declare TestTarget bool local 
	declare GoodPath bool local 
	 
	GoodPath:Set[FALSE]
	TestPoint:Set[FALSE]
	TestTarget:Set[FALSE]
	TargetDistTemp:Set[${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}]
	TargetDist:Set[${Math.Calc[${TargetDistTemp}+2]}]
	if !${Me.IsPathObstructed[${X},${Y},${Z},${TargetDist}]}
	{
	  ;call UpdateHudStatus "Path to Target is not Obstructed"
	  ;echo "Path to Target is not Obstructed"
	  return
	}  
	
	
	call UpdateHudStatus "Path to Target IS Obstructed"
	
		
	do 
	{
	
	   degrees:Set[0]
	   do
	   {
	     TestLocXIPO:Set[${Me.X} + (${radius}*${Math.Cos[${degrees}]})]
	     TestLocYIPO:Set[${Me.Y} + (${radius}*${Math.Sin[${degrees}]})]
	     call CheckTestObst
	     TestPoint:Set[${Return}]
	     if ${TestPoint}
	     {
	       ;echo "Good TestPoint: ${TestLocX},${TestLocY}"
	       ;call UpdateHudStatus "Good TestPoint: ${TestLocXIPO},${TestLocYIPO}"
	       call CheckTest2Target ${X} ${Y} ${Z}
	       TestTarget:Set[${Return}]
	       if ${TestTarget}
	       {
	         call UpdateHudStatus "Found a path to target using ${TestLocXIPO},${TestLocYIPO}"
	         ;echo "Found a path to target using ${TestLocX},${TestLocY}"
	         call moveto2 ${TestLocXIPO} ${TestLocYIPO} 6
	         ;call moveto2 ${X} ${Y} 5
	         GoodPath:Set[TRUE]
	         return
	       }  
	     }  
	     
	   }
	   while ${degrees:Inc[20]}<361
	}  
	while ${radius:Inc[10]}<51
	if !${GoodPath}
	{
	   call UpdateHudStatus "No Route Around Obstical Found in Range"
           ;echo "No Route Around Obstical Found in Range"
        }   
}

function CheckTestObst()
{
  if ${Me.IsPathObstructed[${TestLocXIPO},${TestLocYIPO},${Z},${TargetDist}]}
  {
    Return "FALSE"
  }
  if !${Me.IsPathObstructed[${TestLocXIPO},${TestLocYIPO},${Z},${TargetDist}]}
  {
      Return "TRUE"
  }
  

}
function CheckTest2Target(float X,float Y,float Z)
{
  if ${Me.IsPathObstructed[${TestLocXIPO},${TestLocYIPO},${Z},${TargetDist},${X},${Y},${Z}]}
  {
    Return "FALSE"
  }
  if !${Me.IsPathObstructed[${TestLocXIPO},${TestLocYIPO},${Z},${TargetDist},${X},${Y},${Z}]}
  {
      Return "TRUE"
  }


}





function moveto2(float X,float Y, float Precision)
{
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*20)]}
	
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
			;ensure we are still facing our target loc
			call SmartFace ${X} ${Y}

			;press and hold the forward button 
			move forward
			
			;wait for our pc to move
			wait 3
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
		move -stop forward
	}
}



;+-----------------------------------------------------------------------------------------------------
;| Name: moveto
;| In: X,Y, Precision
;| Returns: 
;| Description: Moves you to within Precision yards of  supplied X, Y then stops you. 
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function moveto(float X,float Y, float Precision)
{
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*20)]}
	call IPO ${X} ${Y} ${Me.Z}
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
			;ensure we are still facing our target loc
			call SmartFace ${X} ${Y}

			;press and hold the forward button 
			move forward
			
			;wait for our pc to move
			wait 3
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
		move -stop forward
	}
}


;+-----------------------------------------------------------------------------------------------------
;| Name: movetocont
;| In: X,Y, Precision
;| Returns: 
;| Description: Moves you to within Precision yards of  supplied X, Y without stopping you.. 
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function movetocont(float X,float Y, float Precision)
{
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
	call IPO ${X} ${Y} ${Me.Z}
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;debug("movetocont: ${X} ${Y} ${Precision}")
	;Check that we are not already there!
	;debug("movetocont: if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}")
	
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
			;ensure we are still facing our target loc
			call SmartFace ${X} ${Y}
			call CheckFacing
			;press and hold the forward button 
			move forward
			
			;wait for our pc to move
			wait 3
			;check to make sure we have moved if not then try and avoid the
			;obstacle thats in our path
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1
			{
				;debug("movetocont:Stuck")
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
;| Description: Moves you to within Precision yards of  supplied X, Y omiting the check if you have aggro.
;|              this is intended to be used for escaping whilst you are aggroed. 
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

	;debug("fleeto: ${X} ${Y} ${Precision}")
	call IPO ${X} ${Y} ${Me.Z}
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
		
			;ensure we are still facing our target loc
			call SmartFace ${X} ${Y}
			call CheckFacing
			;press and hold the forward button 
			move forward

			;wait for our pc to move
			wait 3
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
		move -stop forward
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: skirmishto
;| In: X,Y, Precision
;| Returns: 
;| Description: Moves you to within Precision yards of supplied X, Y whilst searching for target along
;|              the route then stops you once you are within Precision yards.. 
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function skirmishto(float X,float Y, float Precision)
{
   if ${Me.Ghost} && ${TravelState}!=CR
   {
   	call SetAdvancePath
   	return
   }
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
	call IPO ${X} ${Y} ${Me.Z}
	;debug("skirmishto:${X} ${Y} ${Precision}")
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
	
	
		Do
		{			
			;ensure we are still facing our target loc
			Face ${X} ${Y}
			call CheckFacing
			;press and hold the forward button 
			move forward

			;wait for our pc to move
			wait 3

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
		while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision})&&(!${Me.Dead})&&(!${Me.InCombat})&&(${LavishScript.RunningTime}<${BailOut})
		
		;Made it to our target loc
		move -stop forward
	}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: skirmishtocont
;| In: X,Y, Precision
;| Returns: 
;| Description: Moves you to within Precision yards of supplied X, Y whilst searching for target along
;|              the route without stopping.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function skirmishtocont(float X,float Y, float Precision)
{
   if ${Me.Ghost} && ${TravelState}!=CR
   {
   	call SetAdvancePath
   	return
   }
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}
	;debug("skirmishtocont:${X} ${Y} ${Precision}")
	call IPO ${X} ${Y} ${Me.Z}
	;Turn to face the desired loc
	Face ${X} ${Y}
	call CheckFacing
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
			;ensure we are still facing our target loc
			Face ${X} ${Y}
			call CheckFacing
			;press and hold the forward button 
			move forward
			
			;wait for our pc to move
			wait 3
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
;| Description: This function moves you to within MaxDist yards of the specified Object and no 
;| closer than MinDist.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function movetoobject(string ObjectGUID,float MaxDist=10,float MinDist=1)
{

; need to check aggro and bailout if needed.
	
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*20)]}
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
	call IPO ${Object[${ObjectGUID}].X} ${Object[${ObjectGUID}].Y} ${Object[${ObjectGUID}].Z}
	Do
	{
		SavX:Set[${Me.X}]
		SavY:Set[${Me.Y}]
		SavZ:Set[${Me.Z}]
		
		; Ensure we are still facing our target loc
		Face ${Object[${ObjectGUID}].X} ${Object[${ObjectGUID}].Y}
		call CheckFacing
		;If too far away run forward
		if ${Object[${ObjectGUID}].Distance}>${MaxDist}
		{
			;debug("movetoobject:Too far closing")
			;press and hold the forward button 
			move -stop backward
			move forward
		}

		;If too close then run backward
		if ${Object[${ObjectGUID}].Distance}<${MinDist}
		{
			;debug("movetoobject:Too close backing up")
			;press and hold the backward button 
			move -stop forward
			move backward
		}
		
		;If we are close enough stop running
		if ${Object[${ObjectGUID}].Distance}>${MinDist}&&${Object[${ObjectGUID}].Distance}<${MaxDist}
		{
			move -stop forward
			move -stop backward
			StuckCheck:Set[FALSE]
		}

		;If the object disappeard then bail out
		if !${Object[${ObjectGUID}](exists)}
		{
			;debug("movetoobject:Object i was moving too disappeared")
			return
		}
		
		;wait for our pc to move
		wait 3
		
		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}<1&&${Object[${ObjectGUID}].Distance}>${MaxDist}
		{
			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				;debug("movetoobject:I might be stuck")
				StuckCheck:Set[TRUE]
                wowpress jump
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			} 
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${LavishScript.RunningTime}-${StuckCheckTime}>8000
				{
					;debug("movetoobject:Yep I am stuck trying to free myself")
					call Obstacle
					StuckCheck:Set[FALSE]
				}
			}
		}
		
		; If I have moved away from my saved spot reset my stuck toggle
		if ${StuckCheck}&&${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}>3
		{
			;debug("movetoobject:I am no longer stuck")
			StuckCheck:Set[FALSE]
		}
		
	}
	while (${Object[${ObjectGUID}].Distance}>${MaxDist}||${Object[${ObjectGUID}].Distance}<${MinDist})&&${LavishScript.RunningTime}<${BailOut}

	move -stop backward
	move -stop forward
}

;+-----------------------------------------------------------------------------------------------------
;| Name: movetopoint
;| In: filename, world, EndPoint
;| Returns: 
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
			call moveto ${MovePath.Point[${PathIndex}].X} ${MovePath.Point[${PathIndex}].Y} ${Math.Rand[3]:Inc[4]}
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
;| Description: Function to do a backup and a random strafe to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Obstacle()
{
    debug("In Obstacle()")
	call UpdateHudStatus "Stuck, backing up"

	;backup a little
	move -stop forward
	move backward
    wait ${Math.Rand[6]:Inc[2]}
	move -stop backward

	;randomly pick a direction
	if ${Math.Rand[10]}>5
	{
		call UpdateHudStatus "Strafing Left"
		;use lau to strafe left
		WoWScript StrafeLeftStart(GetTime() * 1000 )
		wait ${Math.Rand[4]:Inc[4]}
		WoWScript StrafeLeftStop((GetTime() + 1.5) * 1000 )
		wait ${Math.Rand[11]:Inc[10]}
	}
	else
	{
		call UpdateHudStatus "Strafing Right"
		;use lau to strafe right
		WoWScript StrafeRightStart(GetTime() * 1000 )
		wait ${Math.Rand[4]:Inc[4]}
		WoWScript StrafeRightStop((GetTime() + 1.5) * 1000 )
		wait ${Math.Rand[11]:Inc[10]}
	}
	call UpdateHudStatus "Advancing"
	;Start moving forward again
	move forward
    if ${Math.Rand[3]}
    {
      wowpress jump
    }
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Obstacle2
;| In: 
;| Returns: 
;| Description: Function to do a backup and a random turn to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------
function Obstacle2()
{
    debug("In Obstacle2()")
	call UpdateHudStatus "Stuck, backing up"

	;backup a little
	move -stop
	move backward
	wait ${Math.Rand[5]:Inc[2]}
	move -stop backward

	;randomly pick a direction
	if ${Math.Rand[10]}>5
	{
		call UpdateHudStatus "Running Left"
		;turn left a bit
		Turn -${Math.Rand[21]:Inc[20]}
		move forward
        wowpress jump
		wait ${Math.Rand[6]:Inc[3]}
	}
	else
	{
		call UpdateHudStatus "Running Right"
		;turn right a bit
		Turn ${Math.Rand[21]:Inc[20]}
		move forward
        wowpress jump
		wait ${Math.Rand[6]:Inc[3]}
	}
	call UpdateHudStatus "Advancing"
	;Start moving forward again
	move forward
    if ${Math.Rand[3]}
    {
        wowpress jump
    }
}


;+-----------------------------------------------------------------------------------------------------
;| Name: WalkPath
;| In: world, StartPoint, EndPoint
;| Returns: 
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
			call moveto ${MovePath.Point[${PathIndex}].X} ${MovePath.Point[${PathIndex}].Y} ${Math.Rand[3]:Inc[4]}
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

; Function to load a Navigation file, then find the nearest point
; to you.
;
function MoveToNearestPoint(string filename,string world)
{
	declare NearestPoint string local
	
	Navigation -load ${filename}

	NearestPoint:Set["${Navigation.World["${world}"].NearestPoint[${Me.X},${Me.Y}]}"]
	call UpdateHudStatus "Running to ${NearestPoint}"
	call moveto ${Navigation.World["${world}"].Point[${NearestPoint}].X} ${Navigation.World["${world}"].Point[${NearestPoint}].Y} ${Math.Rand[3]:Inc[4]}
	call UpdateHudStatus "Made it to ${NearestPoint}"
}

;
; function to move you to the safest (determined my the proximity of possible aggros) nearby spot
;

;+-----------------------------------------------------------------------------------------------------
;Move To Safe Spot - Used for rez routine
;

function MoveToSafeSpot()
{
	declare Indexx int local 1 
	declare TargetList guidlist local 
	declare TestLocX float  
	declare TestLocY float 
	declare radius int local 10 
	declare degrees int local 0
	declare TestDist float local 
	declare GoodLoc bool local FALSE
	declare CurrentSafestX float ${Me.X}
	declare CurrentSafestY float ${Me.Y}
	declare CurrentLargestDist float 100
	declare LargestSmallest float 0

	
	call UpdateHudStatus "Looking for Safe Spot"
	
	;Get all the targets that are within 60 of my corpse
	TargetList:Search[-units,-nearest,-nopets,-alive,-untapped,-nonfriendly,-range 60]

	;Look for a safe spot circling outwards 
	;If the nearest target is far enough away or there are no targets then we are safe already
	if ${TargetList.Count}<1||${Unit[${TargetList.GUID[1]}].Distance}>40
	{ 
		call UpdateHudStatus "We are already Safe"
		move -stop 
		return 
	} 

	;Were not already safe so lets search by checking the distance to all targets
	;We will search outwards every 10 yards up to 30 yards
	do
	{
		;call UpdateHudStatus "MoveToSafeSpot:Radius-${radius}"
		;We will search every 20 degrees
		degrees:Set[0]
		do
		{
			;call UpdateHudStatus "MoveToSafeSpot:Degrees-${degrees}" 
			TestLocX:Set[${Me.X} + (${radius}*${Math.Cos[${degrees}]})]
			TestLocY:Set[${Me.Y} + (${radius}*${Math.Sin[${degrees}]})]
			;call UpdateHudStatus "Check: ${TestLocX}, ${TestLocY}"
			;echo "Check: ${TestLocX}, ${TestLocY}"
			GoodLoc:Set[FALSE]
			CurrentLargestDist:Set[100]
			Indexx:Set[1]
			do
			{
			         
				;Test each unit for its distance from our chosen loc
				TestDist:Set[${Math.Distance[${TestLocX},${TestLocY},${Unit[${TargetList.GUID[${Indexx}]}].X},${Unit[${TargetList.GUID[${Indexx}]}].Y}]}]
				;See if this distant is greater than our current best
				if ${TestDist}<${CurrentLargestDist}
				{
					
					CurrentLargestDist:Set[${TestDist}]
					
					   
				}
				
				;If we are greater than the unit assist radius then this is a safe space
				;echo "MoveToSafeSpot:LargestDist ${CurrentLargestDist}"
				if ${CurrentLargestDist}>40
				{
					GoodLoc:Set[TRUE]
				}
				
			}
			while ${Indexx:Inc}<=${TargetList.Count}&&!${GoodLoc} 
			
			if ${LargestSmallest}<${CurrentLargestDist}
			{
			    LargestSmallest:Set[${CurrentLargestDist}]
			    CurrentSafestX:Set[${TestLocX}]
			    CurrentSafestY:Set[${TestLocY}]
			    call UpdateHudStatus "Current Best Distance is ${LargestSmallest}"
			}    
			;if we have checked all units and its still not a bad loc then we have our spot 
			if ${GoodLoc} 
			{ 
				call UpdateHudStatus "Moving to safe location ${CurrentSafestX} ${CurrentSafestY}"
				call moveto ${CurrentSafestX} ${CurrentSafestY} ${Math.Rand[3]:Inc[4]} 
				move -stop 
				return 
			} 
		} 
		while ${degrees:Inc[20]}<360
		
	} 
	while ${radius:Inc[10]}<51 

	call UpdateHudStatus "No safe spot found best loc is ${CurrentSafestX} ${CurrentSafestY}"
	call moveto ${CurrentSafestX} ${CurrentSafestY} ${Math.Rand[3]:Inc[4]}
	move -stop 
	return 

}

function SmartFacePrecision(float X,float Y, int PRECISION=45) 
{ 
     if ${ISXWoW.Facing}
   	return
	;Turn to face the desired loc 
     if ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]}>${PRECISION}
     { 
           ;debug("SmartFace:Close to point") 
           if ${UseFaceFast} 
           { 
                debug("SmartFace: Facing fast") 
                Face -fast ${X} ${Y} 
                wait 1
           } 
           else 
           { 
                Face ${X} ${Y} 
           } 
     } 
}
