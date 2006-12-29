;+-----------------------------------------------------------------------------------------------------
;| Name: ExitGame
;| In: none
;| Returns: none
;| File: system.iss
;| Description: Activates our hearthstone then logs.
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function ExitGame()
{
			;Warping out
			Item[Hearthstone]:Use
			wait 100
			logout
			Script:End
}

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
function Beep()
{
	System:APICall[${System.GetProcAddress["Kernel32.dll", "Beep"].Hex},${Math.Dec[500]},250]
}