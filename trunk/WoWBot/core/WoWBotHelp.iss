#includeoptional test.iss

function main()
{
	declare CurrentPageTitle string script
	declare CurrentPageBody string script
	declare CurrentPageNum int script
	declare TotalPageNum int script
	
	CurrentPageTitle:Set[What is WoWBot?]
	CurrentPageBody:Set[WoWBot is a script written in LavishScript for InnerSpace probably the most powerful\, flexible\, and extensible game automation software available. My intension for WoWBot is to provide a core framework to make automating your WoW character as easy as possible. Armed with WoWBot and a little scripting knowledge you should be able to completely automate any race/class combination.]
	CurrentPageNum:Set[1]
	TotalPageNum:Set[1]
	echo ${CurrentPageBody}
	ui -load \\scripts\\wowbot\\interface\\wowskin.xml
	ui -load \\scripts\\wowbot\\interface\\WoWBotHelpUI.xml
	wait 120

}

function atexit()
{
	ui -unload \\scripts\\wowbot\\interface\\WoWBotHelpUI.xml
	ui -unload \\scripts\\wowbot\\interface\\wowskin.xml
}