---------------------------
--  CHECK CLIENT CONVAR  --
---------------------------

-- Check Convars
local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
function cl_bHUD.setDrawHUD( ply, cmd, args )
	drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
end
concommand.Add( "cl_drawhud", cl_bHUD.setDrawHUD )



----------------------
--  SQL - SETTINGS  --
----------------------

cl_bHUD_Settings = {}

sql.Query( "CREATE TABLE IF NOT EXISTS bhud_settings( 'setting' TEXT, value INTEGER );" )

local check_sql = { "drawHUD", "drawPlayerHUD", "drawHoverNames", "drawTimeHUD", "drawMapHUD", "showday" }
table.foreach( check_sql, function( index, setting )

	if !sql.Query( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) then
		sql.Query( "INSERT INTO bhud_settings ( setting, value ) VALUES( '" .. setting .. "', 1 )" )
		cl_bHUD_Settings[setting] = tobool( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) )
	else
		cl_bHUD_Settings[setting] = tobool( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) )
	end

end )

-- BHUD-SETTINGS INFORMATION
chat.AddText( Color( 255, 50, 0 ), "[bHUD - Settings]", Color( 255, 255, 255 ), " Write '", Color( 0, 161, 222 ), "!bhud_settings", Color( 255, 255, 255 ), "' to open the ", Color( 0, 161, 222 ), "Settings-Panel", Color( 255, 255, 255 ), "!" )

-- PANEL
function cl_bHUD_SettingsPanel()

	local pw = ScrW() / 4
	local ph = ScrH() / 4
	local px = ScrW() / 2 - ( pw / 2 )
	local py = ScrH() / 2 - ( ph / 2 )

	local frm = cl_bHUD.addfrm( px, py, pw, ph )
	local ch = 35
	cl_bHUD.addchk( frm, "Enable bHUD", 10, ch, "drawHUD" )
	ch = ch + 35

	cl_bHUD.addlbl( frm, "Player HUD:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Player-HUD", 10, ch, "drawPlayerHUD" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show names over players", 10, ch, "drawHoverNames" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Time HUD:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Time-HUD", 10, ch, "drawTimeHUD" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show Time and Date", 10, ch, "showday" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Minimap:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Minimap", 10, ch, "drawMapHUD" )

	cl_bHUD.addlbl( frm, "Minimap Settings:", pw / 2 + 10, 35 )
	cl_bHUD.addsld( frm, "Radius", pw / 2 + 10, 55, 155, 50, 150, bhud_map["radius"], "radius" )
	cl_bHUD.addsld( frm, "Border", pw / 2 + 10, 75, 155, 0, 15, bhud_map["border"], "border" )
	cl_bHUD.addsld( frm, "X-Position", pw / 2 + 10, 95, 155, 10 + bhud_map["radius"] + bhud_map["border"], ScrW() - bhud_map["radius"] - 10 - bhud_map["border"], bhud_map["left"], "left" )
	cl_bHUD.addsld( frm, "Y-Position", pw / 2 + 10, 115, 155, 10 + bhud_map["radius"] + bhud_map["border"], ScrH() - bhud_map["radius"] - 10 - bhud_map["border"], bhud_map["top"], "top" )

end

-- OPEN SETTINGS-PANEL
function cl_bHUD.chat( ply, text, team, dead )

	if text == "!bhud_settings" then
		cl_bHUD_SettingsPanel()
		return true
	end

end
hook.Add( "OnPlayerChat", "cl_bHUD_OnPlayerChat", cl_bHUD.chat )



-----------------------
--  PLAYER INFO HUD  --
-----------------------

-- DISABLE DEFAULT HUD
function cl_bHUD.drawHUD( HUDName )
	if !cl_bHUD_Settings["drawHUD"] then return end
	if HUDName == "CHudHealth" or HUDName == "CHudBattery" or HUDName == "CHudAmmo" or HUDName == "CHudSecondaryAmmo" then return false end
end
hook.Add( "HUDShouldDraw", "bhud_drawHUD", cl_bHUD.drawHUD )



local player_health = 0
local player_armor = 0
local background_height = 65

function cl_bHUD.showHUD()

	-- CHECK DRAWING THE HUD
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawPlayerHUD"] then return end
	if !LocalPlayer():Alive() or !LocalPlayer():IsValid() or !LocalPlayer():GetActiveWeapon():IsValid() then return end


	-- HOVER NAMES
	if cl_bHUD_Settings["drawHoverNames"] then

		table.foreach( player.GetAll(), function( id, pl )

			if LocalPlayer() == pl or !LocalPlayer():Visible( pl ) then return end

			local pos = pl:GetPos() + Vector( 0, 0, 100 )
			local screen = pos:ToScreen()
			local teamcol = team.GetColor( pl:Team() )
			local alpha = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 100 ), 0, 255 )

			surface.SetFont( "bhud_roboto_22_ns" )
			screen.x = screen.x - ( surface.GetTextSize( pl:Nick() ) / 2 )

			draw.SimpleTextOutlined( pl:Nick(), "bhud_roboto_22_ns", screen.x, screen.y, Color( alpha, alpha, alpha, alpha ), 0 , 0, 1, Color( 100, 100, 100, alpha ) )

		end )

	end


	-- GET PLAYER DATA
	local ply = LocalPlayer()
	local player = {

		name = ply:Nick(),
		team = team.GetName( ply:Team() ),
		health = ply:Health(),
		armor = ply:Armor(),

		weapon = ply:GetActiveWeapon():GetPrintName(),
		ammo1 = ply:GetActiveWeapon():Clip1(),
		ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}
	
	-- SET PLAYER'S TEAM
	if player["team"] != "" and player["team"] != "Unassigned" then
		player["name"] = "[" .. player["team"] .. "] " .. ply:Nick()
	end

	-- SET HUD SIZES
	local width = 195
	local height
	if player["armor"] > 0 then height = 90 else height = 65 end
	if background_height != height then background_height = cl_bHUD.Animation( background_height, height, 0.3 ) end
	local left = 20
	local top = ScrH() - background_height - 20

	local wep_width = 200
	local wep_height
	if player["ammo2_max"] != 0 then wep_height = 90 else wep_height = 65 end
	local wep_top = ScrH() - wep_height - 20
	local wep_left = 230

	-- BACKGROUND
	draw.RoundedBox( 4, left, top, width, background_height, Color( 50, 50, 50, 230 ) )

	-- PLAYER NAME
	surface.SetFont( "bhud_roboto_18" )
	if surface.GetTextSize( player["name"] ) > ( width - 38 - 10 ) then
		while surface.GetTextSize( player["name"] ) > ( width - 38 - 15 ) do
			player["name"] = string.Left( player["name"], string.len( player["name"] ) -1 )
		end
		player["name"] = player["name"] .. "..."
	end

	surface.SetMaterial( Material( "materials/bhud/player.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 12, 16, 16 )

	draw.SimpleText( player["name"], "bhud_roboto_20", left + 38, top + 10, team.GetColor( ply:Team() ), 0, 0 )

	-- PLAYER HEALTH
	if player_health != player["health"] then player_health = cl_bHUD.Animation( player_health, player["health"], 1 ) end

	surface.SetFont( "bhud_roboto_18" )
	surface.SetMaterial( Material( "materials/bhud/heart.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 37, 16, 16 )

	draw.RoundedBox( 1, left + 35, top + 35, player_health * 1.5, 20, Color( 255, 50, 0, 230 ) )

	if 10 + surface.GetTextSize( tostring( player["health"] ) ) < player_health * 1.5 then
		draw.SimpleText( tostring( math.Round( player_health, 0 ) ), "bhud_roboto_18", left + 30 + ( player_health * 1.5 ) - surface.GetTextSize( tostring( player["health"] ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	else
		draw.SimpleText( tostring( math.Round( player_health, 0 ) ), "bhud_roboto_18", left + 40 + ( player_health * 1.5 ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	end

	-- PLAYER ARMOR
	if player["armor"] > 0 then

		if player_armor != player["armor"] then player_armor = cl_bHUD.Animation( player_armor, player["armor"], 1 ) end

		surface.SetMaterial( Material( "materials/bhud/shield.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( left + 10, top + 62, 16, 16 )

		draw.RoundedBox( 1, left + 35, top + 60, player_armor * 1.5, 20, Color( 0, 161, 222, 230 ) )

		if 10 + surface.GetTextSize( tostring( player["armor"] ) ) < player_armor * 1.5 then
			draw.SimpleText( tostring( math.Round( player_armor, 0 ) ), "bhud_roboto_18", left + 30 + ( player_armor * 1.5 ) - surface.GetTextSize( tostring( player["armor"] ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		else
			draw.SimpleText( tostring( math.Round( player_armor, 0 ) ), "bhud_roboto_18", left + 40 + ( player_armor * 1.5 ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		end

	end



	-- WEAPONS

	if player["ammo1"] == -1 and player["ammo1_max"] <= 0 then return end
	if player["ammo1"] == -1 then player["ammo1"] = "1" end

	-- BACKGROUND
	draw.RoundedBox( 4, wep_left, wep_top, wep_width, wep_height, Color( 50, 50, 50, 230 ) )

	-- WEAPON NAME
	surface.SetMaterial( Material( "materials/bhud/pistol.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 12, 16, 16 )

	draw.SimpleText( player["weapon"], "bhud_roboto_20", wep_left + 38, wep_top + 10, Color( 255, 255, 255 ), 0 , 0 )

	-- AMMO 1
	surface.SetMaterial( Material( "materials/bhud/ammo_1.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 37, 16, 16 )

	surface.SetFont( "bhud_roboto_20" )

	draw.SimpleText( player["ammo1"], "bhud_roboto_20", wep_left + 38, wep_top + 35, Color( 255, 255, 255 ), 0 , 0 )
	draw.SimpleText( "/ " .. player["ammo1_max"], "bhud_roboto_20", wep_left + 38 + surface.GetTextSize( player["ammo1"] ) + 6, wep_top + 35, Color( 200, 200, 200 ), 0 , 0 )

	if wep_height != 90 then return end

	-- AMMO 2
	surface.SetMaterial( Material( "materials/bhud/ammo_2.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 62, 16, 16 )

	draw.SimpleText( player["ammo2_max"], "bhud_roboto_20", wep_left + 38, wep_top + 60, Color( 255, 255, 255 ), 0 , 0 )

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

local time_top = 0
local time_left = 0
local time_width = 0
local time_height = 0

function cl_bHUD.showTimeHUD()

	-- CHECK DRAWING THE HUD
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawTimeHUD"] then return end

	local width
	local height
	local top
	local time = os.date( "%H:%M" )
	if cl_bHUD_Settings["showday"] then
		time = os.date( "%d %B %Y - %H:%M" )
	end

	if bigtimemenu then
		height = 67
		width = 150
		top = 45
	else
		surface.SetFont( "bhud_roboto_15" )
		height = 0
		width = 12 + surface.GetTextSize( time )
		top = 15
	end
	local left = ScrW() - width - 15
	
	-- ANIMATIONS
	if time_top != top then time_top = cl_bHUD.Animation( time_top, top, 0.3 ) end
	if time_left != left then time_left = cl_bHUD.Animation( time_left, left, 0.3 ) end
	if time_width != width then time_width = cl_bHUD.Animation( time_width, width, 0.3 ) end
	if time_height != height then time_height = cl_bHUD.Animation( time_height, height, 0.3 ) end

	if bigtimemenu then

		draw.RoundedBoxEx( 4, time_left, time_top, time_width, 25, Color( 50, 50, 50, 230 ), true, true, false, false )
		if !cl_bHUD_Settings["showday"] then
			draw.SimpleText( "Time:", "bhud_roboto_15", time_left + 5, time_top + 5, Color( 255, 255, 255 ), 0 , 0 )
		else
			draw.SimpleText( os.date( "%d %B %Y" ), "bhud_roboto_15", time_left + 5, time_top + 5, Color( 255, 255, 255 ), 0 , 0 )
		end
		draw.SimpleText( os.date( "%H:%M" ), "bhud_roboto_15", time_left + time_width - 6, time_top + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

		draw.RoundedBoxEx( 4, time_left, time_top + 25, time_width, time_height, Color( 100, 100, 100, 230 ), false, false, true, true )

		-- Session
		if time_height < 5 then return end
		surface.SetFont( "bhud_roboto_16" )
		draw.SimpleText( "Session:", "bhud_roboto_16", time_left + 6, time_top + 30, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( string.NiceTime( os.time() - jointime ), "bhud_roboto_16", time_left + 11 + surface.GetTextSize( "Session:" ), time_top + 30, Color( 255, 255, 255 ), 0, 0 )

		-- Total
		if time_height < 45 then return end
		draw.SimpleText( "Total:", "bhud_roboto_16", time_left + 6, time_top + 50, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( string.NiceTime( td.time + ( os.time() - jointime ) ), "bhud_roboto_16", time_left + 11 + surface.GetTextSize( "Total:" ), time_top + 50, Color( 255, 255, 255 ), 0, 0 )
		
		-- Addon
		if time_height < 65 then return end
		draw.SimpleText( "Addon:", "bhud_roboto_16", time_left + 6, time_top + 70, Color( 255, 255, 255 ), 0, 0 )
		draw.SimpleText( td.addon, "bhud_roboto_16", time_left + 11 + surface.GetTextSize( "Addon:" ), time_top + 70, Color( 255, 255, 255 ), 0, 0 )

	else

		draw.RoundedBoxEx( 4, time_left, time_top, time_width, 25, Color( 50, 50, 50, 230 ), true, true, true, true )
		draw.SimpleText( time, "bhud_roboto_15", time_left + time_width - 6, time_top + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

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

end )



-------------------
--  MINIMAP HUD  --
-------------------

-- SET DEFAULT VALUES
bhud_map = {}
bhud_map["radius"] = 100
bhud_map["border"] = 7
bhud_map["left"] = ScrW() - bhud_map["radius"] - 10 - bhud_map["border"]
bhud_map["top"] = ScrH() - bhud_map["radius"] - 10 - bhud_map["border"]
bhud_map["tolerance"] = 200

-- LOAD CUSTOM SETTINGS
local check_sql = { "left", "top", "radius", "border" }
table.foreach( check_sql, function( index, setting )

	if !sql.Query( "SELECT value FROM bhud_settings WHERE setting = 'minimap_" .. setting .. "'" ) then
		sql.Query( "INSERT INTO bhud_settings ( setting, value ) VALUES( 'minimap_" .. setting .. "', " .. bhud_map[setting] .. " )" )
		bhud_map[setting] = tonumber( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = 'minimap_" .. setting .. "'" ) )
	else
		bhud_map[setting] = tonumber( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = 'minimap_" .. setting .. "'" ) )
	end

end )

function cl_bHUD.showMinimapHUD()

	-- Don't draw the HUD if the cvar cl_drawhud is set to 0
	if !drawHUD then return end
	-- If BHUD was deactivated by sql-settings
	if cl_bHUD_Settings["drawHUD"] == false then return end
	-- If BHUD-Time was deactivated by sql-settings
	if cl_bHUD_Settings["drawMapHUD"] == false then return end

	local circles = {}
	local deg = 0
	local sin, cos, rad = math.sin, math.cos, math.rad

	local function draw_circle( name, quality, xpos, ypos, size, color )

		circles[name] = {}

		for i = 1, quality do
			deg = rad( i * 360 ) / quality
			circles[name][i] = {
				x = xpos + cos( deg ) * size,
				y = ypos + sin( deg ) * size
			}
		end

		surface.SetDrawColor( color )
		draw.NoTexture()
		surface.DrawPoly( circles[name] )

	end
	
	-- BORDER
	draw_circle( "minimap_border", 60, bhud_map["left"], bhud_map["top"], bhud_map["radius"] + bhud_map["border"], Color( 255, 150, 0 ) )

	-- BACKGROUND
	draw_circle( "minimap_background", 60, bhud_map["left"], bhud_map["top"], bhud_map["radius"], Color( 50, 50, 50 ) )

	-- MIDDLE CURSOR
	surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
	surface.SetDrawColor( team.GetColor( LocalPlayer():Team() ) )
	surface.DrawTexturedRect( bhud_map["left"] - 8, bhud_map["top"] - 8, 16, 16 )

	-- NORTH
	local north = math.AngleDifference( LocalPlayer():EyeAngles().y, 0 )
	surface.SetMaterial( Material( "materials/bhud/north.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255 ) )
	surface.DrawTexturedRect( bhud_map["left"] + ( -sin( rad( north ) ) * bhud_map["radius"] ) - 11, bhud_map["top"] + ( cos( rad( north ) ) * bhud_map["radius"] ) - 11, 22, 22 )

	-- OTHER PLAYERS
	table.foreach( player.GetAll(), function( id, pl )

		if pl == LocalPlayer() then return end

		-- Set Variables ( Positions, Angles, ... )
		local e = LocalPlayer():EyeAngles().y
		local a1 = LocalPlayer():GetPos() - pl:GetPos()
		local a2 = a1:Angle().y
		local lx, ly, px, py = LocalPlayer():GetPos().x, LocalPlayer():GetPos().y, pl:GetPos().x, pl:GetPos().y
		local dist = Vector( lx, ly, 0 ):Distance( Vector( px, py, 0 ) )
		local ang = math.AngleDifference( e - 180, a2 )

		-- Calculate Player-Cursor-Positions
		local d = rad( ang + 180 )
		local posx = -sin( d ) * ( math.Clamp( dist, 0, 1000 ) / 10 )
		local posy = cos( d ) * ( math.Clamp( dist, 0, 1000 ) / 10 )

		-- Set correct Cursor-Picture
		if LocalPlayer():GetPos().z + bhud_map["tolerance"] < pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_up.png" ) )
		elseif LocalPlayer():GetPos().z - bhud_map["tolerance"] > pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_down.png" ) )
		else
			surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
		end

		-- Draw Player-Curosr
		surface.SetDrawColor( team.GetColor( pl:Team() ) )
		surface.DrawTexturedRectRotated( bhud_map["left"] + posx, bhud_map["top"] + posy, 16, 16, -math.AngleDifference( e, pl:EyeAngles().y ) )

		-- Draw Playername and Distance
		surface.SetFont( "bhud_roboto_14" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( bhud_map["left"] + posx - 8, bhud_map["top"] + posy + 10 )
		surface.DrawText( pl:Nick() )
		surface.SetTextPos( bhud_map["left"] + posx - 8, bhud_map["top"] + posy + 20 )
		surface.DrawText( math.floor( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 50 ) .. " m" )

	end )

end
hook.Add( "HUDPaint", "bhud_showMinimapHUD", cl_bHUD.showMinimapHUD )
