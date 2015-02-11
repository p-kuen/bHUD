if SERVER then

	-- Send files to client
	AddCSLuaFile()
	AddCSLuaFile( "bhud/client/sql.lua" )
	AddCSLuaFile( "bhud/client/bhud.lua" )
	AddCSLuaFile( "bhud/client/fonts.lua" )
	AddCSLuaFile( "bhud/client/derma.lua" )

	local files = file.Find( "bhud/client/designs/*.lua", "LUA" )
	table.foreach( files, function( key, plugin )
		AddCSLuaFile( "bhud/client/designs/" .. plugin )
	end )

	-- Create Restrictions-Table
	local bhud_restrictions = { minimap = false, hovername = false }

	-- Pool Network Strings
	util.AddNetworkString( "bhud_authed" )

	-- Load Restrictions
	if file.Exists( "bhud_server_settings.txt", "DATA" ) then

		local cont = file.Read( "bhud_server_settings.txt", "DATA" )
		if util.JSONToTable( cont ) != nil then
			bhud_restrictions = util.JSONToTable( cont )
		end

	end

	-- Change/Save Restrictions
	concommand.Add( "bhud_restrict", function( ply, cmd, args )
		
		if args[2] != "true" and args[2] != "false" or bhud_restrictions[ args[1] ] == nil then

			print( "Setting is wrong! Use 'minimap' or 'hovernames'! (e.g. bhud_restrict minimap true)" )

		else

			bhud_restrictions[ args[1] ] = tobool( args[2] )
			file.Write( "bhud_server_settings.txt", util.TableToJSON( bhud_restrictions ) )
			print( "Set " .. args[1] .. "-restriction to " .. args[2] .. "!" )
			print( "Please restart the server when you are finish." )

		end

	end )

	-- Send Restrictions
	local function bhud_player_authed( ply, sid, uid )

		net.Start( "bhud_authed" )
			net.WriteTable( bhud_restrictions )
		net.Send( ply )

	end
	hook.Add( "PlayerAuthed", "bhud_player_authed", bhud_player_authed )

	-- Load Images
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
		cl_drawhud = tobool( GetConVarNumber( "cl_drawhud" ) ),
		drawhud = nil,
		cmenu = false,
		popen = false,
		res = {},
		me = nil,
		defs = {},
		ply = {},
		phud = {},
		hhud = {},
		thud = {},
		mhud = {}
	}

	include( "bhud/client/sql.lua" )
	include( "bhud/client/bhud.lua" )
	include( "bhud/client/fonts.lua" )
	include( "bhud/client/derma.lua" )

	bhud.phud.designs = 0
	local files = file.Find( "bhud/client/designs/*.lua", "LUA" )
	table.foreach( files, function( key, plugin )
		include( "bhud/client/designs/" .. plugin )
		bhud.phud.designs = bhud.phud.designs + 1
	end )

end
