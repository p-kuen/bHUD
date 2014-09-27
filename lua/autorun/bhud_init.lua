-- Send files to client
AddCSLuaFile()
AddCSLuaFile( "bhud/client/cl_sql.lua" )
AddCSLuaFile( "bhud/client/cl_bhud.lua" )
AddCSLuaFile( "bhud/client/cl_fonts.lua" )
AddCSLuaFile( "bhud/client/cl_derma.lua" )
AddCSLuaFile( "bhud/client/cl_animation.lua" )

if SERVER then

	-- Load restrictions
	local bhud_restrictions = {}

	if file.Exists( "bhud_server_settings.txt", "DATA" ) then
		local cont = file.Read( "bhud_server_settings.txt", "DATA" )
		cont = string.Replace( cont, "=", ";" )
		cont = string.Explode( ";", cont )
		bhud_restrictions.minimap = tobool( cont[2] )
		bhud_restrictions.hovername = tobool( cont[4] )
		bhud_restrictions.deathnote = tobool( cont[6] )
	else
		bhud_restrictions.minimap = false
		bhud_restrictions.hovername = false
		bhud_restrictions.deathnote = false
	end

	-- Change/Save restrictions
	concommand.Add( "bhud_restrict", function( ply, cmd, args )
		
		local content = ""
		if !file.Exists( "bhud_server_settings.txt", "DATA" ) then
			file.Write( "bhud_server_settings.txt", "minimap=false;hovernames=false;deathnote=false;" )
		end
		content = file.Read( "bhud_server_settings.txt", "DATA" )
		local a = string.find( content, args[1] )
		if !a then
			print( "Setting is wrong! Use 'minimap' or 'hovernames' or 'deathnote'! (e.g. bhud_restrict minimap true)" )
			return
		end
		local b = string.find( content, ";", a )
		local s = string.sub( content, a, b )
		local r = args[1] .. "=" .. args[2] .. ";"
		content = string.Replace( content, s, r )
		file.Write( "bhud_server_settings.txt", content )
		print( "Done!" )

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
