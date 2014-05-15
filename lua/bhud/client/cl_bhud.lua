------------------------------------------
--  CHECK CONV AND DISABLE DEFAULT HUD  --
------------------------------------------

-- Check Convars
local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
function cl_bHUD.setDrawHUD( ply, cmd, args )

	drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )

end
concommand.Add( "cl_drawhud", cl_bHUD.setDrawHUD )

-- Disable Default-HUD
function cl_bHUD.drawHUD( HUDName )

	if HUDName == "CHudHealth" or HUDName == "CHudBattery" or HUDName == "CHudAmmo" or HUDName == "CHudSecondaryAmmo" then return false end
	
end
hook.Add( "HUDShouldDraw", "bhud_drawHUD", cl_bHUD.drawHUD )



----------------------
--  SQL - SETTINGS  --
----------------------

local sqldata = {}

-- Check if there is a table. If there is no table, bhud will create one
sql.Query( "CREATE TABLE IF NOT EXISTS bhud_settings( 'setting' TEXT, value INTEGER );" )

local check_sql = { "drawHUD", "drawTimeHUD" }

-- LOAD SQL SETTINGS
table.foreach( check_sql, function( index, setting )

	if !sql.Query( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) then
		sql.Query( "INSERT INTO bhud_settings ( setting, value ) VALUES( '" .. setting .. "', 1 )" )
	else
		sqldata[setting] = tobool( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) )
	end

end )

-- CHANGE SQL SETTINGS
function cl_bHUD.chat( ply, text, team, dead )

	if string.match( text, "^!bhud_" ) then

		local ccmd = string.Explode( " ", string.Replace( text, "!bhud_", "" ) )
		local cmd = {}

		-- If everything is correct
		if ccmd[2] == "0" or ccmd[2] == "1" then
			cmd = {
				command = ccmd[1],
				value = ccmd[2]
			}

		-- If there is a wrong value
		elseif ccmd[2] != "0" and ccmd[2] != "1" and ccmd[2] != nil then
			chat.AddText( Color( 255, 50, 0), "[bHUD - Settings ERROR] ", Color( 255, 255, 255 ), "Invalid ", Color( 0, 161, 222 ), "value (" .. ccmd[2] .. ")", Color( 255, 255, 255 ), "! Use ", Color( 0, 161, 222 ), "1 or 0", Color( 255, 255, 255 ), " to change the settings!" )
			return true

		-- If there is no value
		elseif ccmd[2] == nil then
			if ccmd[1] == "drawHUD" or ccmd[1] == "drawTimeHUD" then
				cmd = {
					command = ccmd[1],
					value = "1"
				}
			else
				-- If the player failed completely ;)
				cmd = {
					command = "help",
					value = ""
				}
			end
		end

		if sql.Query( "SELECT value FROM bhud_settings WHERE setting = '" .. cmd["command"] .. "'" ) then

			sql.Query( "UPDATE bhud_settings SET value = " .. cmd["value"] .. " WHERE setting = '" .. cmd["command"] .. "'" )
			sqldata[cmd["command"]] = tobool( cmd["value"] )

			chat.AddText( Color( 255, 50, 0), "[bHUD - Settings] ", Color( 255, 255, 255 ), "Changed ", Color( 0, 161, 222 ), cmd["command"], Color( 255, 255, 255 ), " to ", Color( 0, 161, 222 ), cmd["value"], Color( 255, 255, 255 ), "!" )
		
		else

			if cmd["command"] == "help" then
				chat.AddText( Color( 255, 50, 0), "[bHUD - HELP] ", Color( 255, 255, 255 ), "Use ", Color( 0, 161, 222 ), "!bhud_drawHUD 1/0 or !bhud_drawTimeHUD 1/0", Color( 255, 255, 255 ), " to change the bhud-settings!" )
			else
				chat.AddText( Color( 255, 50, 0), "[bHUD - Settings ERROR] ", Color( 255, 255, 255 ), "Couldn't find ", Color( 0, 161, 222 ), cmd["command"], Color( 255, 255, 255 ), "! Use ", Color( 0, 161, 222 ), "!bhud_drawHUD 1/0 or !bhud_drawTimeHUD 1/0", Color( 255, 255, 255 ), " to change the settings!" )
			end

		end

		return true

	end

end
hook.Add( "OnPlayerChat", "cl_bHUD_OnPlayerChat", cl_bHUD.chat )



-----------------------
--  PLAYER INFO HUD  --
-----------------------

bhud_hp_bar = 0
bhud_ar_bar = 0

function cl_bHUD.showHUD()

	-- Don't draw the HUD if the cvar cl_drawhud is set to 0
	if !drawHUD then return end
	-- If BHUD was deactivated with the sql-settings
	if sqldata["drawHUD"] == false then return end

	local ply = LocalPlayer()
	if !ply:Alive() or !ply:IsValid() or !ply:GetActiveWeapon():IsValid() then return end
	if ply:GetActiveWeapon():GetPrintName() == "Camera" then return end

	local player = {

		name = ply:Nick(),
		team = team.GetName( ply:Team() ),
		weapon = ply:GetActiveWeapon(),
		health = ply:Health(),
		armor = ply:Armor(),

		wep = ply:GetActiveWeapon(),
		wep_name = ply:GetActiveWeapon():GetPrintName(),
		wep_ammo_1 = ply:GetActiveWeapon():Clip1(),
		wep_ammo_2 = ply:GetActiveWeapon():Clip2(),
		wep_ammo_1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		wep_ammo_2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}
	
	-- Check the player's Team
	if player["team"] != "" and player["team"] != "Unassigned" then
		player["name"] = "[" .. player["team"] .. "] " .. ply:Nick()
	end

	-- PLAYER PANEL SIZES
	local width = 195
	local height
	if player["armor"] > 0 then height = 90 else height = 65 end
	local left = 20
	local top = ScrH() - height - 20

	local wep_width = 200
	local wep_height
	if player["wep_ammo_2_max"] != 0 then wep_height = 90 else wep_height = 65 end
	local wep_top = ScrH() - wep_height - 20
	local wep_left = left + width + 10

	-- BACKGROUND
	draw.RoundedBox( 4, left, top, width, height, Color( 50, 50, 50, 230 ) )

	-- PLAYER NAME
	surface.SetFont( "bhud_roboto_18" )
	if surface.GetTextSize( player["name"] ) > ( width - 38 - 10 ) then
		while surface.GetTextSize( player["name"] ) > ( width - 38 - 15 ) do
			player["name"] = string.Left( player["name"], string.len( player["name"] ) -1 )
		end
		player["name"] = player["name"] .. "..."
	end

	surface.SetMaterial( Material( "img/player.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 12, 16, 16 )

	draw.SimpleText( player["name"], "bhud_roboto_20", left + 38, top + 10, team.GetColor( ply:Team() ), 0, 0 )

	-- PLAYER HEALTH
	surface.SetFont( "bhud_roboto_18" )

	if bhud_hp_bar < player["health"] then
		bhud_hp_bar = bhud_hp_bar + 0.5
	elseif bhud_hp_bar > player["health"] then
		bhud_hp_bar = bhud_hp_bar - 0.5
	end

	surface.SetMaterial( Material( "img/heart.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 37, 16, 16 )

	draw.RoundedBox( 1, left + 35, top + 35, bhud_hp_bar * 1.5, 20, Color( 255, 50, 0, 230 ) )

	if 10 + surface.GetTextSize( tostring( player["health"] ) ) < bhud_hp_bar * 1.5 then
		draw.SimpleText( tostring( math.Round( bhud_hp_bar, 0 ) ), "bhud_roboto_18", left + 30 + ( bhud_hp_bar * 1.5 ) - surface.GetTextSize( tostring( player["health"] ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	else
		draw.SimpleText( tostring( math.Round( bhud_hp_bar, 0 ) ), "bhud_roboto_18", left + 40 + ( bhud_hp_bar * 1.5 ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	end

	-- PLAYER ARMOR
	if player["armor"] > 0 then

		if bhud_ar_bar < player["armor"] then
			bhud_ar_bar = bhud_ar_bar + 0.5
		elseif bhud_ar_bar > player["armor"] then
			bhud_ar_bar = bhud_ar_bar - 0.5
		end

		surface.SetMaterial( Material( "img/shield.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( left + 10, top + 62, 16, 16 )

		draw.RoundedBox( 1, left + 35, top + 60, bhud_ar_bar * 1.5, 20, Color( 0, 161, 222, 230 ) )

		if 10 + surface.GetTextSize( tostring( player["armor"] ) ) < bhud_ar_bar * 1.5 then
			draw.SimpleText( tostring( math.Round( bhud_ar_bar, 0 ) ), "bhud_roboto_18", left + 30 + ( bhud_ar_bar * 1.5 ) - surface.GetTextSize( tostring( player["armor"] ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		else
			draw.SimpleText( tostring( math.Round( bhud_ar_bar, 0 ) ), "bhud_roboto_18", left + 40 + ( bhud_ar_bar * 1.5 ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		end

	end



	-- WEAPONS

	if player["wep_ammo_1"] == -1 and player["wep_ammo_1_max"] <= 0 then return end
	if player["wep_ammo_1"] == -1 then player["wep_ammo_1"] = "1" end

	-- BACKGROUND
	draw.RoundedBox( 4, wep_left, wep_top, wep_width, wep_height, Color( 50, 50, 50, 230 ) )

	-- WEAPON NAME
	surface.SetMaterial( Material( "img/pistol.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 12, 16, 16 )

	draw.SimpleText( player["wep_name"], "bhud_roboto_20", wep_left + 38, wep_top + 10, Color( 255, 255, 255 ), 0 , 0 )

	-- AMMO 1
	surface.SetMaterial( Material( "img/ammo_1.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 37, 16, 16 )

	surface.SetFont( "bhud_roboto_20" )

	draw.SimpleText( player["wep_ammo_1"], "bhud_roboto_20", wep_left + 38, wep_top + 35, Color( 255, 255, 255 ), 0 , 0 )
	draw.SimpleText( "/ " .. player["wep_ammo_1_max"], "bhud_roboto_20", wep_left + 38 + surface.GetTextSize( player["wep_ammo_1"] ) + 6, wep_top + 35, Color( 200, 200, 200 ), 0 , 0 )

	if wep_height != 90 then return end

	-- AMMO 2
	surface.SetMaterial( Material( "img/ammo_2.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 62, 16, 16 )

	draw.SimpleText( player["wep_ammo_2_max"], "bhud_roboto_20", wep_left + 38, wep_top + 60, Color( 255, 255, 255 ), 0 , 0 )

end
hook.Add( "HUDPaint", "bhud_showHUD", cl_bHUD.showHUD )



----------------
--  TIME HUD  --
----------------

local bigtimemenu = false
local jointime = os.time()
local td = {
	time = 0,
	addon = ""
}

function cl_bHUD.showTimeHUD()

	-- Don't draw the HUD if the cvar cl_drawhud is set to 0
	if !drawHUD then return end
	-- If BHUD was deactivated by sql-settings
	if sqldata["drawHUD"] == false then return end
	-- If BHUD-Time was deactivated by sql-settings
	if sqldata["drawTimeHUD"] == false then return end

	local width

	if bigtimemenu then
		width = 150
	else
		surface.SetFont( "bhud_roboto_15" )
		width = 11 + surface.GetTextSize( os.date( "%H:%M" ) )
	end

	local height = 67
	local left = ScrW() - width - 15
	local top

	if bigtimemenu then

		top = 45

		draw.RoundedBoxEx( 4, left, top, width, 25, Color( 50, 50, 50, 230 ), true, true, false, false )
		draw.SimpleText( "Time:", "bhud_roboto_15", left + 5, top + 5, Color( 255, 255, 255 ), 0 , 0 )
		draw.SimpleText( os.date( "%H:%M" ), "bhud_roboto_15", left + width - 6, top + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

		draw.RoundedBoxEx( 4, left, top + 25, width, height, Color( 100, 100, 100, 230 ), false, false, true, true )

		-- Session
		surface.SetFont( "bhud_roboto_16" )
		draw.SimpleText( "Session:", "bhud_roboto_16", left + 6, top + 30, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( string.NiceTime( os.time() - jointime ), "bhud_roboto_16", left + 11 + surface.GetTextSize( "Session:" ), top + 30, Color( 255, 255, 255 ), 0, 0 )

		-- Total
		draw.SimpleText( "Total:", "bhud_roboto_16", left + 6, top + 50, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( string.NiceTime( td.time + ( os.time() - jointime ) ), "bhud_roboto_16", left + 11 + surface.GetTextSize( "Total:" ), top + 50, Color( 255, 255, 255 ), 0, 0 )
		
		-- Addon
		draw.SimpleText( "Addon:", "bhud_roboto_16", left + 6, top + 70, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( td.addon, "bhud_roboto_16", left + 11 + surface.GetTextSize( "Addon:" ), top + 70, Color( 255, 255, 255 ), 0, 0 )

	else

		top = 15

		draw.RoundedBoxEx( 4, left, top, width, 25, Color( 50, 50, 50, 230 ), true, true, true, true )
		draw.SimpleText( os.date( "%H:%M" ), "bhud_roboto_15", left + width - 6, top + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

	end

end
hook.Add( "HUDPaint", "bhud_showTimeHUD", cl_bHUD.showTimeHUD )

local function getTimes()

	if exsto then
		time = LocalPlayer():GetNWInt( "Time_Fixed" )
		td.addon = "Exsto"
	elseif sql.TableExists( "utime" ) then
		time = LocalPlayer():GetNWInt( "TotalUTime" )
		td.addon = "UTime"
	elseif evolve then
		time = LocalPlayer():GetNWInt( "EV_PlayTime" )
		td.addon = "Evolve"
	else
		time = 0
		td.addon = "Not found ..."
	end

end

hook.Add( "OnContextMenuOpen", "bhud_openedContextMenu", function()

	bigtimemenu = true
	getTimes()

end )

hook.Add( "OnContextMenuClose", "bhud_closedContextMenu", function()

	bigtimemenu = false
	getTimes()

end )
