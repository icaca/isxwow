
Current Function List as of 09-02-06

;+-----------------------------------------------------------------------------------------------------
;| Name: UseBestBandage
;| In: BandageTarget
;| Returns:
;| File: inventory.iss
;| Description: Finds the best bandage in inventory and uses on BandageTarget.
;|              returns target to previous target afterwards.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestManaPotion
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best mana potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestHealingPotion
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best healing potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: GetItemCooldown
;| In: ItemName
;| Returns: Item's Cooldown
;| Description: Finds the cooldown of given item.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: GetFirstTrinketCooldown
;| In:
;| Returns: First Trinket's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown the first trinket in inventory. (Top one)
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: SecondTrinketCooldown
;| In:
;| Returns: Second Trinket's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown the second trinket in inventory. (Bottom one)
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CheckDurability
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Loops through your inventory and sets a flag if anything is below the repair percentage 
;|              level set in your config file.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CheckInventory
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Loops through your inventory and counts free slots, while excluding quivers, 
;|              ammo pouches, and soul bags
;|
;| ©2006 Vendan
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: GetSpellCooldown
;| In:
;| Returns:
;| Description: Returns the cooldown of the named spell. If the spell is currently
;|              useable then the return value will be 0 otherwise it will be the total cooldown
;|              time of the spell in seconds.
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CastSpellByRank
;| In:
;| Returns:
;| File: spells.iss
;| Description: Cast a spell by rank and delay until its finished.
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CastSpell
;| In:
;| Returns:
;| File: spells.iss
;| Description: Cast a spell and auto target if required
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: CastOnRun
;| In:
;| Returns:
;| File: spells.iss
;| Description: Cast a spell on the run without stopping
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: TargetAndCastSpell
;| In:
;| Returns:
;| File: spells.iss
;| Description: Cast a spell and delay until its finished.
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: GetSpellCooldown
;| In:
;| Returns:
;| File: spells.iss
;| Description: Returns the cooldown of the named spell. If the spell is currently
;|              useable then the return value will be 0 otherwise it will be the total cooldown
;|              time of the spell in seconds.
;|
;| ©200X ?????
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: DistPointLine
;| In:  px py x1 y1 x2 y2
;| Returns: distance
;| File: math.iss
;| Description: Calculates the distance of point the defined by px,py from the line defined by
;|              x1,y1 and x2,y2
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: ExitGame
;| In: none
;| Returns: none
;| File: system.iss
;| Description: Activates our hearthstone then logs.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: Beep
;| In: none
;| Returns: none
;| File: system.iss
;| Description: Just makes a beep using the system speaker.
;| Updated by: Tenshi
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: SmartFace
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Checks your not already facing the supplied X, Y and if not then
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: moveto
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of  supplied X, Y then stops you.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: movetocont
;| In: X,Y, Precision
;| Returns:
;| File: moveto.iss
;| Description: Moves you to within Precision yards of  supplied X, Y without stopping you..
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

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

;+-----------------------------------------------------------------------------------------------------
;| Name: Obstacle
;| In:
;| Returns:
;| File: moveto.iss
;| Description: Function to do a backup and a random strafe to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: Obstacle2
;| In:
;| Returns:
;| File: moveto.iss
;| Description: Function to do a backup and a random turn to attempt to avoid an obstacle.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

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

;+-----------------------------------------------------------------------------------------------------
;| Name: MoveToSafeSpot
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Moves you to the safest (determined my the proximity of possible aggros) nearby spot
;|
;| ©200X Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: SmartFacePrecision
;| In: X,Y
;| Returns:
;| File: moveto.iss
;| Description: Checks your not already facing the supplied X, Y and if not then turn, using precision(Default 45 degrees)
;|
;| ©200X Fippy
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: IsMounted
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Determines if player is mounted, and returns the buff name. Returns FALSE otherwise.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: Dismount
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Determines if player is mounted, then dismounts if true.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: MountUp
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Finds the first fastest mount in inventory, then uses it.
;|              Currently used as placeholder until Tenshi has time to finish it.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: AntiAFK
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Initiates a random action in 27.5 + 0-10 seconds.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: AntiAFKMovement
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Creates a random movement after the given wait time in tenths of a second.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

;+-----------------------------------------------------------------------------------------------------
;| Name: SendMail
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: If near a mailbox, sends a letter with the given parameters. Money is in copper.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------