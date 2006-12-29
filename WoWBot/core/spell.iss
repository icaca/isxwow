; this function returns the cooldown of the named spell. If the spell is currently
; useable then the return value will be 0 otherwise it will be the total cooldown
; time of the spell in seconds.
;
function GetSpellCooldown(string SpellName)
{
	return ${Spell[${SpellName}].Cooldown}
}

; routine to cast a spell and delay until its finished.
function TargetAndCastSpell(string SpellName,string SpellTargetGUID)
{
   
	if !${Spell[${SpellName}](exists)}
	{
		debug("TargetAndCastSpell:You do not have the spell ${SpellName}")
		return
	}

	declare CurrentTargetGUID string local ${Target.GUID}
	
	;If we dont have the Target for the spell targeted then target it.
	if ${SpellTargetGUID.NotEqual[${CurrentTargetGUID}]}
	{
		Target ${SpellTargetGUID}
	}
	
	; If its not an instacast make sure we are not running
	if ${Spell[${SpellName}].CastTime}>0
	{
		wowpress -release moveforward
		wowpress -release movebackward         
		wait 5
	}

	call UpdateHudStatus "Casting ${SpellName} on ${Object[${SpellTargetGUID}].Name}"
   
	Cast "${SpellName}"
   
	; Check if spell is awaiting target and supply one if it is
	if "${WoWScript[SpellIsTargeting()]}"
	{
		SpellTarget ${SpellTargetGUID}
	}
   
	;Wait for the global cooldown delay
	wait 15
	if ${SpellTargetGUID.NotEqual[${Me.GUID}]}
	{
		face ${Object[${SpellTargetGUID}].X} ${Object[${SpellTargetGUID}].Y}
	}
   
	;Wait for us to finish Casting 
	do
	{
		waitframe
		if ${SpellTargetGUID.NotEqual[${Me.GUID}]}
		{
			face ${Object[${SpellTargetGUID}].X} ${Object[${SpellTargetGUID}].Y}
			wait 1
		}
	}
	while ${Me.Casting}

	;If we changed out target then switch it back.
	if ${Target.GUID.NotEqual[${CurrentTargetGUID}]}
	{
		Target ${CurrentTargetGUID}
	}
}

;
; function to cast a spell on the run without stopping
;
function CastOnRun(string SpellName,string SpellTargetGUID=NONE)
{
	if !${Spell[${SpellName}](exists)}
	{
		debug("CastOnRun:You do not have the spell ${SpellName}")
		return
	}

	; If its not an instacast make sure we are not running
	if ${Spell[${SpellName}].CastTime}>0
	{
		move -stop
		wait 5
	}
	
	call UpdateHudStatus "Casting ${SpellName}"
   
	Cast "${SpellName}"
	waitframe
   
	; Check if spell is awaiting target and supply one if it is.	
	if ${WoWScript[SpellIsTargeting()]}
	{
		; If no target has been supplied assume self.
		if ${SpellTargetGUID.Equal[NONE]}
		{
			SpellTargetGUID:Set[${Me.GUID}]
		}

		SpellTarget ${SpellTargetGUID}
	}
	
	;Wait for us to finish Casting 
	while (${Me.Casting} || ${Me.GlobalCooldown}) && !${Target.Dead} && !${Me.Dead}
	{
		waitframe
		if !${SpellTargetGUID.Equal[${Me.GUID}]}
		{
			call SmartFacePrecision ${Object[${Target.GUID}].X} ${Object[${Target.GUID}].Y}
		}
	}

}

;
; function to cast a spell and auto target if required
;
function CastSpell(string SpellName,string SpellTargetGUID=NONE)
{
	if !${Spell[${SpellName}](exists)}
	{
		debug("CastSpell:You do not have the spell ${SpellName}")
		return
	}
	
	if !${Me.Action[${SpellName}](exists)}
	{
		debug("CastSpell:${SpellName} is not assigned to an action button")
	}

	if !${Me.Action[${SpellName}].Usable} || ${Spell[${SpellName}].Cooldown}
	{
	  debug("Me.Action[${SpellName}].Usable: ${Me.Action[${SpellName}].Usable}")
	  debug("Spell[${SpellName}].Cooldown: ${Spell[${SpellName}].Cooldown}")
		debug("CastSpell:${SpellName} is not ready")
		return
	}

	; Make sure we are not running
	if ${Spell[${SpellName}].CastTime} > 0 
	{
	  debug("Not an instant cast spell, stoping movement")
	  move -stop
	  waitframe
	}
	
	call UpdateHudStatus "Casting ${SpellName}"
 	Cast "${SpellName}"
	waitframe
   
	; Check if spell is awaiting target and supply one if it is.	
	if ${WoWScript[SpellIsTargeting()]}
	{
		; If no target has been supplied assume self.
		if ${SpellTargetGUID.Equal[NONE]}
		{
			SpellTargetGUID:Set[${Me.GUID}]
		}

		SpellTarget ${SpellTargetGUID}
	}
	
	;Wait for us to finish Casting 
	while (${Me.Casting} || ${Me.GlobalCooldown} > 0) && !${Target.Dead} && ${Target(exists)} && !${Me.Dead} && ${Spell[${SpellName}].CastTime}
	{
   	debug("CastSpell:(${Me.Casting} || ${Me.GlobalCooldown}>0) && !${Target.Dead} && !${Me.Dead}")
		waitframe
		if !${SpellTargetGUID.Equal[${Me.GUID}]}
		{
			call SmartFacePrecision ${Object[${Target.GUID}].X} ${Object[${Target.GUID}].Y} 45
		}
	}
	debug("waitframe, spell.iss line 177 or so...")
	waitframe
}

; routine to cast a spell by rank and delay until its finished.
function CastSpellByRank(string SpellName,int Rank,string SpellTargetGUID)
{   
	if !${Spell[${SpellName}](exists)}
	{
		debug("CastSpellByRank:You do not have the spell ${SpellName}")
		return
	}

	; If its not an instacast make sure we are not running
	if ${Spell[${SpellName}].CastTime}>0
	{
		wowpress -release moveforward
		wowpress -release movebackward         
	}

	wait 5
	call UpdateHudStatus "Casting ${SpellName} on ${Object[${SpellTargetGUID}].Name}"
   
	Cast "${SpellName}" ${Rank}
   
	; Check if spell is awaiting target and supply one if it is
	if "${WoWScript[SpellIsTargeting()]}"
	{
		SpellTarget ${SpellTargetGUID}
	}
   
	;Wait for the global cooldown delay
	wait 15
	if ${SpellTargetGUID.NotEqual[${Me.GUID}]}
	{
		call SmartFacePrecision ${Object[${SpellTargetGUID}].X} ${Object[${SpellTargetGUID}].Y}
	}
   
	;Wait for us to finish Casting 
	do
	{
		waitframe
		if ${SpellTargetGUID.NotEqual[${Me.GUID}]}
		{
			SmartFacePrecision ${Object[${SpellTargetGUID}].X} ${Object[${SpellTargetGUID}].Y}
			wait 1
		}
	}
	while ${Me.Casting}

}