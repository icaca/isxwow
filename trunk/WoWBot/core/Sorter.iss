atom(global) keep()
{
	WoWBotInv:AddToKeep[${UIElement[ItemBox@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) sell()
{
	WoWBotInv:AddToSell[${UIElement[ItemBox@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) open()
{
	WoWBotInv:AddToOpen[${UIElement[ItemBox@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) trash()
{
	WoWBotInv:AddToDestroy[${UIElement[ItemBox@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) removekeep()
{
	WoWBotInv:RemFromKeep[${UIElement[ItemBox@Keep@SorterTabs@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) removesell()
{
	WoWBotInv:RemFromSell[${UIElement[ItemBox@Sell@SorterTabs@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) removeopen()
{
	WoWBotInv:RemFromOpen[${UIElement[ItemBox@Open@SorterTabs@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) removetrash()
{
	WoWBotInv:RemFromDestroy[${UIElement[ItemBox@Destroy@SorterTabs@Sorter@WoWBotTab@WoWBot].SelectedItem}]
	checkinv
}

atom(global) checkinv()
{
	declare Bags int 1
	declare Slots int 1
	declare Count int 1
	declare Add bool TRUE
	UIElement[ItemBox@Sorter@WoWBotTab@WoWBot]:ClearItems
	UIElement[ItemBox@Keep@SorterTabs@Sorter@WoWBotTab@WoWBot]:ClearItems
	UIElement[ItemBox@Sell@SorterTabs@Sorter@WoWBotTab@WoWBot]:ClearItems
	UIElement[ItemBox@Destroy@SorterTabs@Sorter@WoWBotTab@WoWBot]:ClearItems
	UIElement[ItemBox@Open@SorterTabs@Sorter@WoWBotTab@WoWBot]:ClearItems
	;Redirect -append debuginv.txt echo Displaying Keep
	WoWBotInv:DispKeepItems[ItemBox@Keep@SorterTabs@Sorter@WoWBotTab@WoWBot]

	;Redirect -append debuginv.txt echo Displaying Sell
	WoWBotInv:DispSellItems[ItemBox@Sell@SorterTabs@Sorter@WoWBotTab@WoWBot]

	;Redirect -append debuginv.txt echo Displaying Open
	WoWBotInv:DispOpenItems[ItemBox@Open@SorterTabs@Sorter@WoWBotTab@WoWBot]

	;Redirect -append debuginv.txt echo Displaying Destroy
	WoWBotInv:DispDestroyItems[ItemBox@Destroy@SorterTabs@Sorter@WoWBotTab@WoWBot]

	;Redirect -append debuginv.txt echo Displaying Bags
	Bags:Set[0]
	do
	{
		Slots:Set[1]
		do
		{
			if ${Me.Bag[${Bags}].Item[${Slots}](exists)}
			{
				;Redirect -append debuginv.txt echo Checking ${Bags}:${Slots}:${Me.Bag[${Bags}].Item[${Slots}].Name}
				Add:Set[TRUE]
				;Redirect -append debuginv.txt echo Checking Keep
				if ${WoWBotInv.IsInKeep[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
				{
					;Redirect -append debuginv.txt echo Yes
					Add:Set[FALSE]
				}
				;Redirect -append debuginv.txt echo Checking Sell
				if ${WoWBotInv.IsInSell[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
				{
					;Redirect -append debuginv.txt echo Yes
					Add:Set[FALSE]
				}
				;Redirect -append debuginv.txt echo Checking Open
				if ${WoWBotInv.IsInOpen[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
				{
					;Redirect -append debuginv.txt echo Yes
					Add:Set[FALSE]
				}
				;Redirect -append debuginv.txt echo Checking Destroy
				if ${WoWBotInv.IsInDestroy[${Me.Bag[${Bags}].Item[${Slots}].Name}]}
				{
					;Redirect -append debuginv.txt echo Yes
					Add:Set[FALSE]
				}
				if ${Add}
				{
					;Redirect -append debuginv.txt echo Adding ${Bags}:${Slots}
					UIElement[ItemBox@Sorter@WoWBotTab@WoWBot]:AddItem[${Me.Bag[${Bags}].Item[${Slots}]}]
				}
			}

		}
		while ${Slots:Inc}<=${Me.Bag[${Bags}].Slots}
	}
	while ${Me.Bag[${Bags:Inc}](exists)}
	;Redirect -append debuginv.txt echo Done Displaying
}