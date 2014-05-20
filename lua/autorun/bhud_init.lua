cl_bHUD = {}

AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )
AddCSLuaFile( "bhud/client/cl_derma.lua" )

if SERVER then

	include( "bhud/server/sv_bhud.lua" )

else

	include( "bhud/client/cl_bhud.lua" )
	include( "bhud/client/cl_fonts.lua" )
	include( "bhud/client/cl_derma.lua" )

end
