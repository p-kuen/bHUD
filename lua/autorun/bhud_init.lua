-- Send files to client
AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_sql.lua" )
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )
AddCSLuaFile( "bhud/client/cl_derma.lua" )
AddCSLuaFile( "bhud/client/cl_animation.lua" )

if SERVER then
	
	local bhud_restrictions = {
		minimap = false,
		hovername = false,
		deathnote = false
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
	resource.AddFile( "materials/bhud/player32.png" )
	resource.AddFile( "materials/bhud/heart32.png" )
	resource.AddFile( "materials/bhud/shield32.png" )
	resource.AddFile( "materials/bhud/pistol32.png" )
	resource.AddFile( "materials/bhud/ammo_132.png" )
	resource.AddFile( "materials/bhud/ammo_232.png" )
	resource.AddFile( "materials/bhud/cursor.png" )
	resource.AddFile( "materials/bhud/cursor_up.png" )
	resource.AddFile( "materials/bhud/cursor_down.png" )
	resource.AddFile( "materials/bhud/skull32.png" )
	resource.AddFile( "materials/bhud/north.png" )
	resource.AddFile( "materials/bhud/config.png" )

	-- Network strings
	util.AddNetworkString( "bhud_authed" )
	util.AddNetworkString( "bhud_deathnotice" )

	-- Death notice
	function bhud_player_authed( ply, sid, uid )
		net.Start( "bhud_authed" )
			net.WriteTable( bhud_restrictions )
		net.Send( ply )
	end
	hook.Add( "PlayerAuthed", "bhud_player_authed", bhud_player_authed )

	-- Death notice
	function bhud_player_death( vic, inf, att )
		net.Start( "bhud_deathnotice" )
			net.WriteTable( { vic, inf, att } )
		net.Broadcast()
		if bhud_restrictions.deathnote == false then return false end
	end
	hook.Add( "PlayerDeath", "bhud_player_death", bhud_player_death )

else

	cl_bHUD = {}
	cl_bHUD_Settings = {}

	include( "bhud/client/cl_sql.lua" )
	include( "bhud/client/cl_bhud.lua" )
	include( "bhud/client/cl_fonts.lua" )
	include( "bhud/client/cl_derma.lua" )
	include( "bhud/client/cl_animation.lua" )

end
