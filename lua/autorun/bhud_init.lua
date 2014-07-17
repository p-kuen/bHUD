AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_sql.lua" )
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_design1.lua" )
AddCSLuaFile( "bhud/client/cl_design2.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )
AddCSLuaFile( "bhud/client/cl_derma.lua" )
AddCSLuaFile( "bhud/client/cl_animation.lua" )

if SERVER then

	-- Images
	resource.AddFile( "materials/bhud/player.png" )
	resource.AddFile( "materials/bhud/heart.png" )
	resource.AddFile( "materials/bhud/shield.png" )
	resource.AddFile( "materials/bhud/pistol.png" )
	resource.AddFile( "materials/bhud/ammo_1.png" )
	resource.AddFile( "materials/bhud/ammo_2.png" )
	resource.AddFile( "materials/bhud/cursor.png" )
	resource.AddFile( "materials/bhud/cursor_down.png" )
	resource.AddFile( "materials/bhud/cursor_up.png" )
	resource.AddFile( "materials/bhud/north.png" )
	resource.AddFile( "materials/bhud/config.png" )
	resource.AddFile( "materials/bhud/player32.png" )
	resource.AddFile( "materials/bhud/heart32.png" )
	resource.AddFile( "materials/bhud/shield32.png" )
	resource.AddFile( "materials/bhud/pistol32.png" )
	resource.AddFile( "materials/bhud/ammo_132.png" )
	resource.AddFile( "materials/bhud/ammo_232.png" )

else

	cl_bHUD = {}
	cl_bHUD_Settings = {}

	include( "bhud/client/cl_sql.lua" )
	include( "bhud/client/cl_bhud.lua" )
	include( "bhud/client/cl_design1.lua" )
	include( "bhud/client/cl_design2.lua" )
	include( "bhud/client/cl_fonts.lua" )
	include( "bhud/client/cl_derma.lua" )
	include( "bhud/client/cl_animation.lua" )

end
