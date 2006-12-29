;+-----------------------------------------------------------------------------------------------------
;| Name: DistPointLine
;| In:  px py x1 y1 x2 y2
;| Returns: distance
;| File: math.iss
;| Description: Calculates the distance of point the defined by px,py from the line defined by
;|              x1,y1 and x2,y2
;|
;| ©2005 Fippy
;+-----------------------------------------------------------------------------------------------------

function DistPointLine(float px,float py,float x1,float y1,float x2,float y2)
{
	;Make sure the line is in fact a point
	if ${x1}==${x2} && ${y1}==${y2}
	{
	
		Return ${Math.Distance[${px},${py},${x1},${y1}]}
	}
	declare sx float ${Math.Calc[${x2}-${x1}]}
	declare sy float ${Math.Calc[${y2}-${y1}]}
	declare q float ${Math.Calc[((${px}-${x1}) * (${x2}-${x1}) + (${py} - ${y1}) * (${y2}-${y1})) / (${sx}*${sx} + ${sy}*${sy})]}
	If ${q} < 0.0
	 q:Set[0]
	If ${q} > 1.0
	 q:Set[1]
	Return ${Math.Distance[${px},${py},${Math.Calc[(1-${q})*${x1}+${q}*${x2}]},${Math.Calc[(1-${q})*${y1} + ${q}*${y2}]}]}
}