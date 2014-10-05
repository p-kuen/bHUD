-- Send files to client
AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_sql.lua" )
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )
AddCSLuaFile( "bhud/client/cl_derma.lua" )
AddCSLuaFile( "bhud/client/cl_animation.lua" )

local files = file.Find( "bhud/client/designs/*.lua", "LUA" )
table.foreach( files, function( key, plugin )
	AddCSLuaFile( "bhud/client/designs/" .. plugin )
end )

if SERVER then
	
	local bhud_restrictions = {
		minimap = false,
		hovername = false
	}

	-- Load restrictions
	if file.Exists( "bhud_server_settings.txt", "DATA" ) then

		local cont = file.Read( "bhud_server_settings.txt", "DATA" )
		if util.JSONToTable( cont ) != nil then
			bhud_restrictions = util.JSONToTable( cont )
		end

	end

	-- Change/Save restrictions
	concommand.Add( "bhud_restrict", function( ply, cmd, args )
		
		if args[2] != "true" and args[2] != "false" or bhud_restrictions[ args[1] ] == nil then

			print( "Setting is wrong! Use 'minimap' or 'hovernames' or 'deathnote'! (e.g. bhud_restrict minimap true)" )

		else

			bhud_restrictions[ args[1] ] = tobool( args[2] )
			file.Write( "bhud_server_settings.txt", util.TableToJSON( bhud_restrictions ) )
			print( "Set " .. args[1] .. "-restriction to " .. args[2] .. "!" )

		end

	end )

	-- Images
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

	-- Network strings
	util.AddNetworkString( "bhud_authed" )
	util.AddNetworkString( "bhud_deathnotice" )

	-- Server restrictions
	function bhud_player_authed( ply, sid, uid )
		net.Start( "bhud_authed" )
			net.WriteTable( bhud_restrictions )
		net.Send( ply )
	end
	hook.Add( "PlayerAuthed", "bhud_player_authed", bhud_player_authed )

else

	cl_bHUD = {}
	cl_bHUD_Settings = {}

	include( "bhud/client/cl_sql.lua" )
	include( "bhud/client/cl_bhud.lua" )
	include( "bhud/client/cl_fonts.lua" )
	include( "bhud/client/cl_derma.lua" )
	include( "bhud/client/cl_animation.lua" )
	
	local files = file.Find( "bhud/client/designs/*.lua", "LUA" )
	local designs = 0
	table.foreach( files, function( key, plugin )
		include( "bhud/client/designs/" .. plugin )
		designs = designs + 1
	end )

	cl_bHUD_Settings[ "designs" ] = designs

end
