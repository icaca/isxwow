;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestHealingPotion
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best healing potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function DrinkBestHealingPotion()
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

;+-----------------------------------------------------------------------------------------------------
;| Name: DrinkBestManaPotion
;| In:
;| Returns:
;| File: inventory.iss
;| Description: Finds the best mana potion in inventory and uses.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function DrinkBestManaPotion()
{
	declare MajorCooldown int 0
	declare CombatCooldown int 0
	declare SuperiorCooldown int 0
	declare GreaterCooldown int 0
	declare NormalCooldown int 0
	declare LesserCooldown int 0
	declare MinorCooldown int 0

	call GetItemCooldown "Major Mana Potion"
	MajorCooldown:Set[${Return}]
	call GetItemCooldown "Combat Mana Potion"
	CombatCooldown:Set[${Return}]
	call GetItemCooldown "Superior Mana Potion"
	SuperiorCooldown:Set[${Return}]
	call GetItemCooldown "Greater Mana Potion"
	GreaterCooldown:Set[${Return}]
	call GetItemCooldown "Mana Potion"
	NormalCooldown:Set[${Return}]
	call GetItemCooldown "Lesser Mana Potion"
	LesserCooldown:Set[${Return}]
	call GetItemCooldown "Minor Mana Potion"
	MinorCooldown:Set[${Return}]

	if ${Item[-inventory,Major Mana Potion](exists)} && ${Item[-inventory,Major Mana Potion].Usable} && !${MajorCooldown}
	{
		Item[Major Mana Potion]:Use
	}
	else
	if ${Item[-inventory,Combat Mana Potion](exists)} && ${Item[-inventory,Combat Mana Potion].Usable} && !${CombatCooldown}
	{
		Item[Combat Mana Potion]:Use
	}
	else
	if ${Item[-inventory,Superior Mana Potion](exists)} && ${Item[-inventory,Superior Mana Potion].Usable} && !${SuperiorCooldown}
	{
		Item[Superior Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Greater Mana Potion](exists)} && ${Item[-inventory,Superior Mana Potion].Usable} && !${GreaterCooldown}
	{
		Item[Greater Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Mana Potion](exists)} && ${Item[-inventory,Mana Potion].Usable} && !${NormalCooldown}
	{
		Item[Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Lesser Mana Potion](exists)} && ${Item[-inventory,Lesser Mana Potion].Usable} && !${LesserCooldown}
	{
		Item[Lesser Mana Potion]:Use
	}
	else 
	if ${Item[-inventory,Minor Mana Potion](exists)} && ${Item[-inventory,Minor Mana Potion].Usable} && !${MinorCooldown}
	{
		Item[Minor Healing Potion]:Use
	}
}

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

function UseBestBandage(string BandageTarget)
{
	declare FormerTarget string ${Me.Target}
	target ${BandageTarget}

	call GetItemCooldown "Heavy Runecloth Bandage"
	HeavyRuneCooldown:Set[${Return}]
	call GetItemCooldown "Runecloth Bandage"
	RuneCooldown:Set[${Return}]
	call GetItemCooldown "Heavy Mageweave Bandage"
	HeavyMageCooldown:Set[${Return}]
	call GetItemCooldown "Mageweave Bandage"
	MageCooldown:Set[${Return}]
	call GetItemCooldown "Heavy Silk Bandage"
	HeavySilkCooldown:Set[${Return}]
	call GetItemCooldown "Silk Bandage"
	SilkCooldown:Set[${Return}]
	call GetItemCooldown "Heavy Linen Bandage"
	HeavyLinenCooldown:Set[${Return}]
	call GetItemCooldown "Linen Bandage"
	LinenCooldown:Set[${Return}]

	if ${Item[-inventory,Heavy Runecloth Bandage](exists)} && ${Item[-inventory,Heavy Runecloth Bandage].Usable} && !${HeavyRuneCooldown}
	{
		Item[Heavy Runecloth Bandage]:Use
	}
	else
	if ${Item[-inventory,Runecloth Bandage](exists)} && ${Item[-inventory,Runecloth Bandage].Usable} && !${RuneCooldown}
	{
		Item[Runecloth Bandage]:Use
	}
	else
	if ${Item[-inventory,Heavy Mageweave Bandage](exists)} && ${Item[-inventory,Heavy Mageweave Bandage].Usable} && !${HeavyMageCooldown}
	{
		Item[Heavy Mageweave Bandage]:Use
	}
	else
	if ${Item[-inventory,Mageweave Bandage](exists)} && ${Item[-inventory,Mageweave Bandage].Usable} && !${MageCooldown}
	{
		Item[Mageweave Bandage]:Use
	}
	else
	if ${Item[-inventory,Heavy Silk Bandage](exists)} && ${Item[-inventory,Heavy Silk Bandage].Usable} && !${HeavySilkCooldown}
	{
		Item[Heavy Silk Bandage]:Use
	}
	else
	if ${Item[-inventory,Silk Bandage](exists)} && ${Item[-inventory,Silk Bandage].Usable} && !${SilkCooldown}
	{
		Item[Silk Bandage]:Use
	}
	else
	if ${Item[-inventory,Heavy Linen Bandage](exists)} && ${Item[-inventory,Heavy Linen Bandage].Usable} && !${HeavyLinenCooldown}
	{
		Item[Heavy Linen Bandage]:Use
	}
	else
	if ${Item[-inventory,Linen Bandage](exists)} && ${Item[-inventory,Linen Bandage].Usable} && !${LinenCooldown}
	{
		Item[Linen Bandage]:Use
	}

	wait 50 !${Me.Casting}
	target ${FormerTarget}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: GetItemCooldown
;| In: ItemName
;| Returns: Item's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown of given item.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function GetItemCooldown(string ItemName)
{
	return ${WoWScript[GetContainerItemCooldown(${Item[${ItemName}].Bag.Number}\, ${Item[${ItemName}].Slot}), 2]}]}	
}

;+-----------------------------------------------------------------------------------------------------
;| Name: GetFirstTrinketCooldown
;| In:
;| Returns: First Trinket's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown the first trinket in inventory. (Top one)
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function GetFirstTrinketCooldown()
{
	return ${WoWScript[GetInventoryItemCooldown("player"\, 13)]}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: SecondTrinketCooldown
;| In:
;| Returns: Second Trinket's Cooldown
;| File: inventory.iss
;| Description: Finds the cooldown the second trinket in inventory. (Bottom one)
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function SecondTrinketCooldown()
{
	return ${WoWScript[GetInventoryItemCooldown("player"\, 14)]}
}

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

function CheckDurability()
{
	declare Index int
	
	while ${Index:Inc} <= 19
	{
		if ${Me.Equip[${Index}](exists)} && ${Me.Equip[${Index}].PctDurability}<${RepairPctLevel}
		{
			call UpdateHudStatus "${Me.Equip[${Index}].Name} is too Broken best Repair"			
			NeedRepair:Set[TRUE]	
		}
	}
}

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

function CheckInventory()
{
	declare Bag int
	declare Slots int
	Slots:Set[0]
	Bag:Set[-1]
	
	while ${Bag:Inc} <= 4
	{
		if ${Me.Bag[${Bag}](exists)} && !${Me.Bag[${Bag}].Name.Find["Quiver"]} && !${Me.Bag[${Bag}].Name.Find["Ammo Pouch"]} && !${Me.Bag[${Bag}].Name.Find["Soul"]} && !${Me.Bag[${Bag}].Name.Find["Bandolier"]} && !${Me.Bag[${Bag}].Name.Find["Felcloth"]} && !${Me.Bag[${Bag}].Name.Find["Lamina"]}
		{
			Slots:Inc[${Me.Bag[${Bag}].EmptySlots}]
		}
	}
	return ${Slots}
}