local fonts = {}
function bhud.font( f, s, b, a, sh, sy )

	b = b or 500
	a = a or true
	sh = sh or false
	sy = sy or false

	local fstr = "bhud_" .. f .. "_" .. tostring( s ) .. "_" .. tostring( b ) .. "_" .. string.sub( tostring( a ), 1, 1 ) .. "_" .. string.sub( tostring( sh ), 1, 1 )

	if table.HasValue( fonts, fstr ) then return fstr end

	surface.CreateFont( fstr, {
		font = f,
		size = s,
		weight = b,
		antialias = a,
		shadow = sh,
		symbol = sy
	} )

	table.insert( fonts, fstr )

	return fstr

end
