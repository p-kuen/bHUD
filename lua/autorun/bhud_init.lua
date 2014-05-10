sv_bHUD = {}
cl_bHUD = {}
sh_bHUD = {}

AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_bhud.lua" )

if SERVER then

	include( "bhud/server/sv_bhud.lua" )

else

	include( "bhud/client/cl_bhud.lua" )

end

print("bhud geladen")
