function ShowMessage(string Message)
{
	Messagebox -template WoW.messagebox -ok "${Message}"
	Switch ${UserInput}
	{	
		case OK
			break
		
		case NULL
			Script:End
			break
	}
}