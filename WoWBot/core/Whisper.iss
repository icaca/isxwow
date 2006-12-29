atom AddWhisper(string Line,string eventid, string message, string speaker, string language, ... junk)
{
	ReceivedWhispers:Inc
	UIElement[WoWWhisper@Whispers@WoWBotConsoleTab@Status@WoWBotTab@WoWBot]:Echo["[${Time.Time24}] ${speaker}: ${message}"]
	Redirect -append "${Realm}/${CharacterName}/Logs/${StartTime}.txt" Echo "[${Time.Time24}] ${speaker}: ${message}"
}