bhud = {}

if SERVER then

	-- Load server-files
	include( "bhud/server/server.lua" )

	-- Send files to client
	AddCSLuaFile()

	local files = file.Find( "bhud/client/designs/*.lua", "LUA" )
	table.foreach( files, function( key, plugin )
		AddCSLuaFile( "bhud/client/designs/" .. plugin )
	end )

	AddCSLuaFile( "bhud/client/sql.lua" )
	AddCSLuaFile( "bhud/client/fonts.lua" )
	AddCSLuaFile( "bhud/client/bhud.lua" )
	AddCSLuaFile( "bhud/client/derma.lua" )

	-- Force client to download bhud-images
	resource.AddFile( "materials/bhud/player16.png" )
	resource.AddFile( "materials/bhud/heart16.png" )
	resource.AddFile( "materials/bhud/shield16.png" )
	resource.AddFile( "materials/bhud/pistol16.png" )
	resource.AddFile( "materials/bhud/ammo_116.png" )
	resource.AddFile( "materials/bhud/ammo_216.png" )
	resource.AddFile( "materials/bhud/player32.png" )
	resource.AddFile( "materials/bhud/heart32.png" )
	resource.AddFile( "materials/bhud/shield32.png" )
	resource.AddFile( "materials/bhud/pistol32.png" )
	resource.AddFile( "materials/bhud/ammo_132.png" )
	resource.AddFile( "materials/bhud/ammo_232.png" )
	resource.AddFile( "materials/bhud/cursor.png" )
	resource.AddFile( "materials/bhud/cursor_up.png" )
	resource.AddFile( "materials/bhud/cursor_down.png" )
	resource.AddFile( "materials/bhud/north.png" )
	resource.AddFile( "materials/bhud/config.png" )

else

	bhud = {
		cdraw = tobool( GetConVarNumber( "cl_drawhud" ) ),
		defs = {},
		ply = {},
		res = {}
	}

	include( "bhud/client/sql.lua" )
	include( "bhud/client/fonts.lua" )

	local fs = file.Find( "bhud/client/designs/*.lua", "LUA" )
	bhud.designs = #fs
	table.foreach( fs, function( key, file )
		include( "bhud/client/designs/" .. file )
	end )

	include( "bhud/client/bhud.lua" )
	include( "bhud/client/derma.lua" )

end
