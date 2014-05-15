sv_bHUD = {}
cl_bHUD = {}
sh_bHUD = {}

AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )

if SERVER then

	include( "bhud/server/sv_bhud.lua" )

else

	include( "bhud/client/cl_bhud.lua" )
	include( "bhud/client/cl_fonts.lua" )

end
