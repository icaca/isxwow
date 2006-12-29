#define DEBUG

#ifdef DEBUG 
	#macro debug(text) 
		call Debug "text" 
	#endmac 
#else 
	#macro debug(text) 
	#endmac 
#endif

function SetDebugFile(string Filename)
{
#ifdef DEBUG
	declare DebugFile string global "Debug.log"
	DebugFile:Set[${Filename}]
	redirect "${DebugFile}" echo "${Time} Debug started"
	;log "${DebugFile}"
#endif
}

function Debug(string Message)
{
#ifdef DEBUG
	redirect -append "${DebugFile}" echo "${Time} ${Display.FPS} ${Message}"
#endif
}

#ifdef DEBUG
function DumpPath(string PathName)
{
	declare Index int local 1
	do
	{
		call UpdateHudStatus "Point ${Index} ${${PathName}.PointName[${Index}]}"
	}
	while ${Index:Inc}<=${${PathName}.Points}
		
}

function DumpQuality()
{
	declare Bags int local 0
	declare Slots int local 0
	declare Count int 1
	
	;Loop through our inventory and delete if required 
	while ${Me.Bag[${Bags:Inc}](exists)}&&!${Me.InCombat}
	{
		Slots:Set[1]
		do
		{
			echo ${Me.Bag[${Bags}].Item[${Slots}]} ${WoWScript[GetContainerItemInfo(${Bags}\,${Slots}),4]}
		}
		while ${Slots:Inc}<=${Me.Bag[${Bags}].Slots}&&!${Me.InCombat}
	}
}

function DumpCollection()
{
	if "${DeleteJunk.FirstKey(exists)}"
	{
		call Debug "Dump"
	  ; We'll echo it inside our loop
	  do
	  {
		; Display the current key
		call Debug "${DeleteJunk.CurrentKey}"
	  }
	  while "${DeleteJunk.NextKey(exists)}"
	 ; This makes sure we have a next key, and continues looping until we dont
		call Debug "DumpEnd"

	}
}
#endif
