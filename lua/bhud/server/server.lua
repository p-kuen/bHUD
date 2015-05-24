--------------------------
--  RESTRICTION SYSTEM  --
--------------------------

util.AddNetworkString( "bhud_restrictions" )

-- Load restrictions
if file.Exists( "bhud_settings.txt", "DATA" ) then
	bhud.restrictions = util.JSONToTable( file.Read( "bhud_settings.txt", "DATA" ) )
else
	file.Write( "bhud_settings.txt", util.TableToJSON( { minimap = false, hovernames = false } ) )
end

-- Send restrictions to clients
local function send_res( ply )

	net.Start( "bhud_restrictions" )
		net.WriteTable( bhud.restrictions )
	net.Send( ply )

end
hook.Add( "PlayerAuthed", "bhud_player_authed", send_res )

-- Change restrictions
local function change_res( ply, cmd, args )

	if cmd != "bhud_restrict" then return end

	local s, r = args[1], tobool( args[2] )

	if bhud.restrictions[s] == nil then
		print( "[bhud-Restrictions]: The setting '" .. s .. "' doesn't exist. Please use something else!" )
		return
	end

	bhud.restrictions[s] = r
	file.Write( "bhud_settings.txt", util.TableToJSON( bhud.restrictions ) )

	print( "[bhud-Restrictions]: Changed " .. s .. "-restriction to '" .. tostring( r ) .. "'!" )

	net.Start( "bhud_restrictions" )
		net.WriteTable( bhud.restrictions )
	net.Broadcast()

end
concommand.Add( "bhud_restrict", change_res )
