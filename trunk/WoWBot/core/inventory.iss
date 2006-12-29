objectdef WoWBotInventory
{
	variable collection:int Keep
	variable collection:int Sell
	variable collection:int Open
	variable collection:int Destroy
	variable string invFilename

;+------------------------------
;|
;| Inventory Save/Load
;|
;+------------------------------

	method Initialize(string Filename)
	{
		This:Load[${invFilename}]
	}

	method Shutdown()
	{
		This:Save
	}
	
	method Load(string Filename)
	{
		if !${Filename.Equal[""]}
		{
			;Redirect debuginv.txt echo Declaring Variables
			variable settingsetref invSettings
			variable iterator setIterate
			;Redirect -append debuginv.txt echo Done
			invFilename:Set[${Filename}]
			LavishSettings:AddSet[WoWBotInv]
			invSettings:Set[${LavishSettings[WoWBotInv]}]
			;Redirect -append debuginv.txt echo Clearing Vars
			invSettings:Clear
			This.Keep:Clear
			This.Sell:Clear
			This.Open:Clear
			This.Destroy:Clear
			;Redirect -append debuginv.txt echo Loading XML
			invSettings:Import[${Filename}]
			;Load Keep Settings
			;Redirect -append debuginv.txt echo Loading Keep
			if ${invSettings.FindSet[Keep](exists)}
			{
				invSettings.FindSet[Keep]:GetSettingIterator[setIterate]
				setIterate:First
				do
				{
					This.Keep:Set[${setIterate.Key},${setIterate.Value.Int}]
				}
				while ${setIterate:Next(exists)}
				
			}
			;Load Sell Settings
			;Redirect -append debuginv.txt echo Loading Sell
			if ${invSettings.FindSet[Sell](exists)}
			{
				invSettings.FindSet[Sell]:GetSettingIterator[setIterate]
				setIterate:First
				do
				{
					This.Sell:Set[${setIterate.Key},${setIterate.Value.Int}]
				}
				while ${setIterate:Next(exists)}
				
			}
			;Load Open Settings
			;Redirect -append debuginv.txt echo Loading Open
			if ${invSettings.FindSet[Open](exists)}
			{
				invSettings.FindSet[Open]:GetSettingIterator[setIterate]
				setIterate:First
				do
				{
					This.Open:Set[${setIterate.Key},${setIterate.Value.Int}]
				}
				while ${setIterate:Next(exists)}
				
			}
			;Load Destroy Settings
			;Redirect -append debuginv.txt echo Loading Destroy
			if ${invSettings.FindSet[Destroy](exists)}
			{
				invSettings.FindSet[Destroy]:GetSettingIterator[setIterate]
				setIterate:First
				do
				{
					This.Destroy:Set[${setIterate.Key},${setIterate.Value.Int}]
				}
				while ${setIterate:Next(exists)}
				
			}
			;Redirect -append debuginv.txt echo Done Loading
		}
	}
	
	method Save()
	{
		variable settingsetref invSettings
		LavishSettings:AddSet[WoWBotInv]
		invSettings:Set[${LavishSettings[WoWBotInv].GUID}]
		invSettings:Clear
		;Save Keep Settings
		if ${This.Keep.FirstKey(exists)}
		{
			invSettings:AddSet[Keep]
			do
			{
				invSettings.FindSet[Keep]:AddSetting[${This.Keep.CurrentKey},${This.Keep.CurrentValue}]
			}
			while ${This.Keep.NextKey(exists)}
		}
		;Save Sell Settings
		if ${This.Sell.FirstKey(exists)}
		{
			invSettings:AddSet[Sell]
			do
			{
				invSettings.FindSet[Sell]:AddSetting[${This.Sell.CurrentKey},${This.Sell.CurrentValue}]
			}
			while ${This.Sell.NextKey(exists)}
		}
		;Save Open Settings
		if ${This.Open.FirstKey(exists)}
		{
			invSettings:AddSet[Open]
			do
			{
				invSettings.FindSet[Open]:AddSetting[${This.Open.CurrentKey},${This.Open.CurrentValue}]
			}
			while ${This.Open.NextKey(exists)}
		}
		;Save Destroy Settings
		if ${This.Destroy.FirstKey(exists)}
		{
			invSettings:AddSet[Destroy]
			do
			{
				invSettings.FindSet[Destroy]:AddSetting[${This.Destroy.CurrentKey},${This.Destroy.CurrentValue}]
			}
			while ${This.Destroy.NextKey(exists)}
		}
		invSettings:Export[${invFilename}]
	}

;+------------------------------
;|
;| Inventory Keep Functions
;|
;+------------------------------

	member:bool IsInKeep(string ItemName)
	{
		if ${This.Keep.Element[${ItemName}](exists)}
		{
			return TRUE
		}
		return FALSE
	}

	member:int NumToKeep(string ItemName)
	{
		if ${This.Keep.Element[${ItemName}](exists)}
		{
			return ${This.Keep.Element[${ItemName}]}
		}
		return -1
	}

	method AddToKeep(string ItemName, int NumToKeep=0)
	{
		This.Keep:Set[${ItemName},${NumToKeep}]
	}

	method RemFromKeep(string ItemName)
	{
		This.Keep:Erase[${ItemName}]
	}

	method DispKeepItems(string FQN)
	{
		if ${This.Keep.FirstKey(exists)}
		{
			do
			{
				;Redirect -append debuginv.txt echo Displaying ${This.Keep.CurrentKey}
				UIElement[${FQN}]:AddItem[${This.Keep.CurrentKey}]
			}
			while ${This.Keep.NextKey(exists)}
		}
	}

;+------------------------------
;|
;| Inventory Sell Functions
;|
;+------------------------------

	member:bool IsInSell(string ItemName)
	{
		if ${This.Sell.Element[${ItemName}](exists)}
		{
			return TRUE
		}
		return FALSE
	}

	member:int NumToSell(string ItemName)
	{
		if ${This.Sell.Element[${ItemName}](exists)}
		{
			return ${Sell.Element[${ItemName}]}
		}
		return -1
	}

	method AddToSell(string ItemName, int NumToSell=0)
	{
		This.Sell:Set[${ItemName},${NumToSell}]
	}

	method RemFromSell(string ItemName)
	{
		This.Sell:Erase[${ItemName}]
	}

	method DispSellItems(string FQN)
	{
		if ${This.Sell.FirstKey(exists)}
		{
			do
			{
				;Redirect -append debuginv.txt echo Displaying ${This.Sell.CurrentKey}
				UIElement[${FQN}]:AddItem[${This.Sell.CurrentKey}]
			}
			while ${This.Sell.NextKey(exists)}
		}
	}

;+------------------------------
;|
;| Inventory Open Functions
;|
;+------------------------------

	member:bool IsInOpen(string ItemName)
	{
		if ${This.Open.Element[${ItemName}](exists)}
		{
			return TRUE
		}
		return FALSE
	}

	member:int NumToOpen(string ItemName)
	{
		if ${This.Open.Element[${ItemName}](exists)}
		{
			return ${This.Open.Element[${ItemName}]}
		}
		return -1
	}

	method AddToOpen(string ItemName, int NumToOpen=0)
	{
		This.Open:Set[${ItemName},${NumToOpen}]
	}

	method RemFromOpen(string ItemName)
	{
		This.Open:Erase[${ItemName}]
	}

	method DispOpenItems(string FQN)
	{
		if ${This.Open.FirstKey(exists)}
		{
			do
			{
				;Redirect -append debuginv.txt echo Displaying ${This.Open.CurrentKey}
				UIElement[${FQN}]:AddItem[${This.Open.CurrentKey}]
			}
			while ${This.Open.NextKey(exists)}
		}
	}

;+------------------------------
;|
;| Inventory Destroy Functions
;|
;+------------------------------

	member:bool IsInDestroy(string ItemName)
	{
		if ${This.Destroy.Element[${ItemName}](exists)}
		{
			return TRUE
		}
		return FALSE
	}

	member:int NumToDestroy(string ItemName)
	{
		if ${This.Destroy.Element[${ItemName}](exists)}
		{
			return ${This.Destroy.Element[${ItemName}]}
		}
		return -1
	}

	method AddToDestroy(string ItemName, int NumToDestroy=0)
	{
		This.Destroy:Set[${ItemName},${NumToDestroy}]
	}

	method RemFromDestroy(string ItemName)
	{
		This.Destroy:Erase[${ItemName}]
	}

	method DispDestroyItems(string FQN)
	{
		if ${This.Destroy.FirstKey(exists)}
		{
			do
			{
				;Redirect -append debuginv.txt echo Displaying ${This.Destroy.CurrentKey}
				UIElement[${FQN}]:AddItem[${This.Destroy.CurrentKey}]
			}
			while ${This.Destroy.NextKey(exists)}
		}
	}
}