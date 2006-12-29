;+-----------------------------------------------------------------------------------------------------
;| Name: SendMail
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: If near a mailbox, sends a letter with the given parameters. Money is in copper.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function SendMail(string To, string Subject, string Message, int Money, string Package, bool CashOnDelivery)
{
	if ${Object[Mailbox](exists)} && ${Object[Mailbox].Distance} <= 5
	{
		if ${To.Equal[""]}
		{
			call UpdateHudStatus "Recipient required to send mail."
			return
		}

		if ${Subject.Equal[""]} > 0 && !${Item[-inventory,${Package}](exists)}
		{
			call UpdateHudStatus "Subject needed to send mail."
			return
		}

		Object[Mailbox]:Use
		if ${Item[-inventory,${Package}](exists)}
		{
			Item[-inventory,${Package}]:PickUp
			wowscript ClickSendMailItemButton()
			wait 3
		}

		if ${Money}
		{
			if ${CashOnDelivery}
			{
				call UpdateHudStatus "Sending mail COD."
				wowscript SetSendMailCOD(${Money})
			}
			else
			{
				wowscript SetSendMailMoney(${Money})
			}
		}

		wowscript SendMail(\"${To}\"\, \"${Subject}\"\, \"${Message}\")

		call UpdateHudStatus "Mail sent."
	}
	else
	{
		call UpdateHudStatus "Mailbox not in range."
	}

	wait 3
}

;+-----------------------------------------------------------------------------------------------------
;| Name: IsMounted
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Determines if player is mounted, and returns the buff name. Returns FALSE otherwise.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function IsMounted()
{
	if ${Me.Class.Equal[Paladin]}
	{
		; Summonable Epic Paladin Mount
		if ${Me.Buff[Summon Charger](exists)}
		{
			return ${Me.Buff[Summon Charger]}
		}

		; Summonable Paladin Mount
		if ${Me.Buff[Summon Warhorse](exists)}
		{
			return ${Me.Buff[Summon Warhorse]}
		}
	}

	if ${Me.Class.Equal[Warlock]}
	{
		; Summonable Epic Warlock Mount
		if ${Me.Buff[Summon Dreadsteed](exists)}
		{
			return ${Me.Buff[Summon Dreadsteed]}
		}

		; Summonable Warlock Mount
		if ${Me.Buff[Summon Felsteed](exists)}
		{
			return ${Me.Buff[Summon Felsteed]}
		}
	}

	; Check if player can even ride epic mounts.
	if ${Me.Level} >= 60
	{
		; Epic Horde Mounts
		if ${Me.FactionGroup.Equal[Horde]}
		{
			; Done first since all 60's can get this easily.
			if ${Me.Buff[Frostwolf Howler](exists)}
			{
				return ${Me.Buff[Frostwolf Howler]}
			}

			if ${Me.Buff[Swift Timber Wolf](exists)}
			{
				return ${Me.Buff[Swift Timber Wolf]}
			}

			if ${Me.Buff[Swift Gray Wolf](exists)}
			{
				return ${Me.Buff[Red Wolf]}
			}

			if ${Me.Buff[Swift Brown Wolf](exists)}
			{
				return ${Me.Buff[Red Wolf]}
			}

			if ${Me.Buff[Swift Blue Raptor](exists)}
			{
				return ${Me.Buff[Swift Blue Raptor]}
			}

			if ${Me.Buff[Swift Olive Raptor](exists)}
			{
				return ${Me.Buff[Swift Olive Raptor]}
			}

			if ${Me.Buff[Swift Orange Raptor](exists)}
			{
				return ${Me.Buff[Swift Orange Raptor]}
			}

			if ${Me.Buff[Purple Skeletal Warhorse](exists)}
			{
				return ${Me.Buff[Purple Skeletal Warhorse]}
			}

			if ${Me.Buff[Green Skeletal Warhorse](exists)}
			{
				return ${Me.Buff[Purple Skeletal Warhores]}
			}

			if ${Me.Buff[Great Brown Kodo](exists)}
			{
				return ${Me.Buff[Great Brown Kodo]}
			}

			if ${Me.Buff[Great Gray Kodo](exists)}
			{
				return ${Me.Buff[Great Gray Kodo]}
			}

			if ${Me.Buff[Great White Kodo](exists)}
			{
				return ${Me.Buff[Great White Kodo]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Red Skeletal Warhorse](exists)}
			{
				return ${Me.Buff[Purple Skeletal Warhorse]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Raptor](exists)}
			{
				return ${Me.Buff[Black War Raptor]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Kodo](exists)}
			{
				return ${Me.Buff[Black War Kodo]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Wolf](exists)}
			{
				return ${Me.Buff[Black War Wolf]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Green Kodo](exists)}
			{
				return ${Me.Buff[Green Kodo]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Teal Kodo](exists)}
			{
				return ${Me.Buff[Teal Kodo]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Artic Wolf](exists)}
			{
				return ${Me.Buff[Artic Wolf]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Mottled Red Raptor](exists)}
			{
				return ${Me.Buff[Mottled Red Raptor]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Ivory Raptor](exists)}
			{
				return ${Me.Buff[Ivory Raptor]}
			}
		}

		; Epic Alliance Mounts
		if ${Me.FactionGroup.Equal[Alliance]}
		{
			; Done first since all 60's can get this easily.
			if ${Me.Buff[Stormpike Battle Charger](exists)}
			{
				return ${Me.Buff[Stormpike Battle Charger]}
			}

			if ${Me.Buff[Swift Brown Steed](exists)}
			{
				return ${Me.Buff[Swift Brown Steed]}
			}

			if ${Me.Buff[Swift Palomino](exists)}
			{
				return ${Me.Buff[Swift Palomino]}
			}

			if ${Me.Buff[Swift White Steed](exists)}
			{
				return ${Me.Buff[Swift White Steed]}
			}

			if ${Me.Buff[Swift Brown Ram](exists)}
			{
				return ${Me.Buff[Swift Brown Ram]}
			}

			if ${Me.Buff[Swift Gray Ram](exists)}
			{
				return ${Me.Buff[Swift Gray Ram]}
			}

			if ${Me.Buff[Swift White Ram](exists)}
			{
				return ${Me.Buff[Swift White Ram]}
			}

			if ${Me.Buff[Swift White Mechanostrider](exists)}
			{
				return ${Me.Buff[Swift White Mechanostrider]}
			}

			if ${Me.Buff[Swift Yellow Mechanostrider](exists)}
			{
				return ${Me.Buff[Swift Yellow Mechanostrider]}
			}

			if ${Me.Buff[Swift Frostsaber](exists)}
			{
				return ${Me.Buff[Swift Frostsaber]}
			}

			if ${Me.Buff[Swift Mistsaber](exists)}
			{
				return ${Me.Buff[Swift Mistsaber]}
			}

			if ${Me.Buff[Swift Stormsaber](exists)}
			{
				return ${Me.Buff[Swift Stormsaber]}
			}

			; Reputation Nightelf Mount
			if ${Me.Buff[Winterspring Frostsaber](exists)}
			{
				return ${Me.Buff[Winterpsring Frostsaber]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Tiger](exists)}
			{
				return ${Me.Buff[Black War Tiger]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Steed](exists)}
			{
				return ${Me.Buff[Black War Steed]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black War Ram](exists)}
			{
				return ${Me.Buff[Black War Ram]}
			}

			; Epic PVP Mount
			if ${Me.Buff[Black Battlestrider](exists)}
			{
				return ${Me.Buff[Black Battlestrider]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[White Mechanostrider](exists)}
			{
				return ${Me.Buff[Icy Blue Mechanostrider]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Icy Blue Mechanostrider](exists)}
			{
				return ${Me.Buff[Icy Blue Mechanostrider]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[White Stallion](exists)}
			{
				return ${Me.Buff[White Stallion]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Frost Ram](exists)}
			{
				return ${Me.Buff[Frost Ram]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Palamino](exists)}
			{
				return ${Me.Buff[Palamino]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Frostsaber](exists)}
			{
				return ${Me.Buff[Frostsaber]}
			}

			; Old Item - No longer sold
			if ${Me.Buff[Nightsaber](exists)}
			{
				return ${Me.Buff[Nightsaber]}
			}
		}

		; Epic Mount Drop from Zul'Gurub
		if ${Me.Buff[Swift Razzashi Raptor](exists)}
		{
			return ${Me.Buff[Swift Razzashi Raptor]}
		}

		; Epic Mount Drop from Zul'Gurub
		if ${Me.Buff[Swift Zulian Tiger](exists)}
		{
			return ${Me.Buff[Swift Zulian Tiger]}
		}

		; Epic Mount Drop from Baron Rivendare from UD Strat
		if ${Me.Buff[Deathcharger](exists)}
		{
			return ${Me.Buff[Deathcharger]}
		}

		; Epic Mount Drop from Ahn'Qiraj
		if ${Me.Buff[Summon Blue Qiraji Battle Tank](exists)}
		{
			return ${Me.Buff[Summon Blue Qiraji Battle Tank]}
		}

		; Epic Mount Drop from Ahn'Qiraj
		if ${Me.Buff[Summon Green Qiraji Battle Tank](exists)}
		{
			return ${Me.Buff[Summon Green Qiraji Battle Tank]}
		}

		; Epic Mount Drop from Ahn'Qiraj
		if ${Me.Buff[Summon Red Qiraji Battle Tank](exists)}
		{
			return ${Me.Buff[Summon Red Qiraji Battle Tank]}
		}

		; Epic Mount Drop from Ahn'Qiraj
		if ${Me.Buff[Summon Yellow Qiraji Battle Tank](exists)}
		{
			return ${Me.Buff[Summon Yellow Qiraji Battle Tank]}
		}

		; Prize for ringing Ahn'Qiraj Gong
		if ${Me.Buff[Summon Black Qiraji Battle Tank](exists)}
		{
			return ${Me.Buff[Summon Black Qiraji Battle Tank]}
		}
	}

	; Normal Horde Mounts
	if ${Me.FactionGroup.Equal[Horde]}
	{
		if ${Me.Buff[Large Timber Wolf](exists)}
		{
			return ${Me.Buff[Large Timber Wolf]}
		}

		if ${Me.Buff[Red Wolf](exists)}
		{
			return ${Me.Buff[Red Wolf]}
		}

		if ${Me.Buff[Winter Wolf](exists)}
		{
			return ${Me.Buff[Winter Wolf]}
		}

		if ${Me.Buff[Black Wolf](exists)}
		{
			return ${Me.Buff[Black Wolf]}
		}

		if ${Me.Buff[Emerald Raptor](exists)}
		{
			return ${Me.Buff[Emerald Raptor]}
		}

		if ${Me.Buff[Obsidian Raptor](exists)}
		{
			return ${Me.Buff[Obsidian Raptor]}
		}

		if ${Me.Buff[Turquoise Raptor](exists)}
		{
			return ${Me.Buff[Turquoise Raptor]}
		}

		if ${Me.Buff[Violet Raptor](exists)}
		{
			return ${Me.Buff[Violet Raptor]}
		}

		if ${Me.Buff[Blue Skeletal Horse](exists)}
		{
			return ${Me.Buff[Blue Skeletal Horse]}
		}

		if ${Me.Buff[Brown Skeletal Horse](exists)}
		{
			return ${Me.Buff[Brown Skeletal Horse]}
		}

		if ${Me.Buff[Red Skeletal Horse](exists)}
		{
			return ${Me.Buff[Red Skeletal Horse]}
		}

		if ${Me.Buff[Brown Kodo](exists)}
		{
			return ${Me.Buff[Brown Kodo]}
		}

		if ${Me.Buff[Gray Kodo](exists)}
		{
			return ${Me.Buff[Gray Kodo]}
		}
	}

	; Normal Alliance Mounts
	if ${Me.FactionGroup.Equal[Alliance]}
	{
		if ${Me.Buff[Brown Horse](exists)}
		{
			return ${Me.Buff[Brown Horse]}
		}

		if ${Me.Buff[Chestnut Mare](exists)}
		{
			return ${Me.Buff[Chestnut Mare]}
		}

		if ${Me.Buff[Pinto Horse](exists)}
		{
			return ${Me.Buff[Pinto Horse]}
		}

		if ${Me.Buff[Gray Ram](exists)}
		{
			return ${Me.Buff[Gray Ram]}
		}

		if ${Me.Buff[White Ram](exists)}
		{
			return ${Me.Buff[White Ram]}
		}

		if ${Me.Buff[Blue Mechanostrider](exists)}
		{
			return ${Me.Buff[Blue Mechanostrider]}
		}

		if ${Me.Buff[Green Mechanostrider](exists)}
		{
			return ${Me.Buff[Green Mechanostrider]}
		}

		if ${Me.Buff[Red Mechanostrider](exists)}
		{
			return ${Me.Buff[Red Mechanostrider]}
		}

		if ${Me.Buff[Unpainted Mechanostrider](exists)}
		{
			return ${Me.Buff[Unpainted Mechanostrider]}
		}

		if ${Me.Buff[Spotted Frostsaber](exists)}
		{
			return ${Me.Buff[Spotted Frostsaber]}
		}

		if ${Me.Buff[Striped Frostsaber](exists)}
		{
			return ${Me.Buff[Striped Frostsaber]}
		}

		if ${Me.Buff[Striped Nightsaber](exists)}
		{
			return ${Me.Buff[Striped Nightsaber]}
		}

		; Old Item - No longer sold
		if ${Me.Buff[Black Ram](exists)}
		{
			return ${Me.Buff[Gray Ram]}
		}

		; Old Item - No longer sold
		if ${Me.Buff[Black Stallion](exists)}
		{
			return ${Me.Buff[Black Stallion]}
		}
	}

	return FALSE
}

;+-----------------------------------------------------------------------------------------------------
;| Name: Dismount
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Determines if player is mounted, then dismounts if true.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function Dismount()
{
	call IsMounted
	if ${Return.NotEqual[FALSE]}
	{
		Me.Buff[${Return}]:Remove
	}
}

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

function MountUp()
{

}

;+-----------------------------------------------------------------------------------------------------
;| Name: AntiAFK
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Initiates a random action in 27.5 + 0-10 seconds.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function AntiAFK()
{
	call AntiAFKMovement ${Math.Rand[100]:Inc[275]}
}

;+-----------------------------------------------------------------------------------------------------
;| Name: AntiAFKMovement
;| In: none
;| Returns: none
;| File: misc.iss
;| Description: Creates a random movement after the given wait time in tenths of a second.
;|
;| ©2006 Tenshi
;+-----------------------------------------------------------------------------------------------------

function AntiAFKMovement(int WaitTime)
{
	declare MoveType int
	MoveType:Set[${Math.Rand[11]:Inc[1]}]

	Switch ${MoveType}
	{
		case 1
			echo "Jumping in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress jump
			break
		case 2
			echo "Moving forward in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold moveforward
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release moveforward
			break
		case 3
			echo "Moving backwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold movebackward
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release movebackward
			break
		case 4 
			echo "Jumping backwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold movebackward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release movebackward
			break
		case 5
			echo "Jumping forwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold moveforward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release moveforward
			break
		case 6
			echo "Jump turning left in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnleft
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnleft
			break	
		case 7
			echo "Jump turning right in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnright
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnright
			break
		case 8
			echo "Jump turning right backwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnright
			wowpress -hold movebackward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnright
			wowpress -release movebackward
			break
		case 9
			echo "Jump turning right forwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnright
			wowpress -hold moveforward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnright
			wowpress -release moveforward
			break
		case 10
			echo "Jump turning left backwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnleft
			wowpress -hold movebackward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnleft
			wowpress -release movebackward
			break
		case 11
			echo "Jump turning left forwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnleft
			wowpress -hold moveforward
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnleft
			wowpress -release moveforward
			break
/*
		case 12 
			echo "Strafing right in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold straferight
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release straferight
			break
		case 13
			echo "Jumping forwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold strafeleft
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release strafeleft
			break
		case 14
			echo "Jump turning left backwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnleft
			wowpress -hold straferight
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnright
			wowpress -release straferight
			break
		case 15
			echo "Jump turning left forwards in ${Math.Calc[${WaitTime}/10]} seconds."
			wait ${WaitTime} ${Me.Ghost}
			wowpress -hold turnleft
			wowpress -hold strafeleft
			wowpress jump
			wait ${Math.Rand[3]:Inc[2]}
			wowpress -release turnright
			wowpress -release strafeleft
			break

*/
	}
}