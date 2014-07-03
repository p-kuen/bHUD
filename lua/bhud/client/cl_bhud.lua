--------------------------
--  ENABLE DISABLE HUD  --
--------------------------

-- CL_DRAWHUD - CONVAR
local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
cvars.AddChangeCallback( "cl_drawhud", function( name, old, new )
	if tobool( new ) then drawHUD = true else drawHUD = false end
end )

-- DISABLE DEFAULT HUD
function cl_bHUD.drawHUD( HUDName )
	if !cl_bHUD_Settings["drawHUD"] then return end
	if HUDName == "CHudHealth" or HUDName == "CHudBattery" or HUDName == "CHudAmmo" or HUDName == "CHudSecondaryAmmo" then return false end
end
hook.Add( "HUDShouldDraw", "bhud_drawHUD", cl_bHUD.drawHUD )



-----------------------
--  PLAYER INFO HUD  --
-----------------------

local health = 0
local armor = 0
local way = false
local h_pulse = 230

function cl_bHUD.showHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawPlayerHUD"] then return end
	if !LocalPlayer():Alive() or !LocalPlayer():IsValid() or !LocalPlayer():GetActiveWeapon():IsValid() then return end

	-- HOVER NAMES
	if cl_bHUD_Settings["drawHoverNames"] then

		table.foreach( player.GetAll(), function( id, pl )
			
			if pl == LocalPlayer() or !pl:Alive() then return end

			local pos = pl:GetPos() + Vector( 0, 0, 100 )
			local screen = pos:ToScreen()
			local teamcol = team.GetColor( pl:Team() )
			local alpha = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 20 ), 0, 255 )

			surface.SetFont( "bhud_roboto_22_ns" )
			screen.x = screen.x - ( surface.GetTextSize( pl:Nick() ) / 2 )

			draw.SimpleTextOutlined( pl:Nick(), "bhud_roboto_22_ns", screen.x, screen.y, Color( 255, 255, 255, alpha ), 0 , 0, 1, Color( 100, 100, 100, alpha ) )

		end )

	end

	-- PLAYER DATA
	local ply = LocalPlayer()
	local player = {

		name = ply:Nick(),
		health = ply:Health(),
		armor = ply:Armor(),

		weapon = ply:GetActiveWeapon():GetPrintName(),
		ammo1 = ply:GetActiveWeapon():Clip1(),
		ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}

	-- HUD SIZES
	local width = 195
	local height
	if player["armor"] > 0 then height = 90 else height = 65 end
	local left = 20
	local top = ScrH() - height - 20

	local wep_width = 200
	local wep_height
	if player["ammo2_max"] != 0 then wep_height = 90 else wep_height = 65 end
	local wep_top = ScrH() - wep_height - 20
	local wep_left = 230

	-- BACKGROUND
	draw.RoundedBox( 4, left, top, width, height, Color( 50, 50, 50, 230 ) )

	-- PLAYER NAME
	surface.SetFont( "bhud_roboto_20" )
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
	health = cl_bHUD.Animation( health, player["health"], 1 )

	surface.SetFont( "bhud_roboto_18" )
	surface.SetMaterial( Material( "materials/bhud/heart.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 37, 16, 16 )

	if player["health"] <= 20 then
		if h_pulse >= 230 then way = false elseif h_pulse <= 100 then way = true end
		if way then h_pulse = h_pulse + 2.5 else h_pulse = h_pulse - 2.5 end
	else h_pulse = 230 end
	draw.RoundedBox( 1, left + 35, top + 35, math.Clamp( health * 1.5, 0, 150 ), 20, Color( 255, 50 + ( 230 - h_pulse ), 0, 230 ) )

	if 10 + surface.GetTextSize( tostring( player["health"] ) ) < health * 1.5 then
		draw.SimpleText( tostring( math.Round( health, 0 ) ), "bhud_roboto_18", left + 30 + ( math.Clamp( health * 1.5, 0, 150 ) ) - surface.GetTextSize( tostring( player["health"] ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	else
		draw.SimpleText( tostring( math.Round( health, 0 ) ), "bhud_roboto_18", left + 40 + ( math.Clamp( health * 1.5, 0, 150 ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	end

	-- PLAYER ARMOR
	if player["armor"] > 0 then

		armor = cl_bHUD.Animation( armor, player["armor"], 1 )

		surface.SetMaterial( Material( "materials/bhud/shield.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( left + 10, top + 62, 16, 16 )

		draw.RoundedBox( 1, left + 35, top + 60, math.Clamp( armor * 1.5, 0, 150 ), 20, Color( 0, 161, 222, 230 ) )

		if 10 + surface.GetTextSize( tostring( player["armor"] ) ) < armor * 1.5 then
			draw.SimpleText( tostring( math.Round( armor, 0 ) ), "bhud_roboto_18", left + 30 + ( math.Clamp( armor * 1.5, 0, 150 ) ) - surface.GetTextSize( tostring( player["armor"] ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		else
			draw.SimpleText( tostring( math.Round( armor, 0 ) ), "bhud_roboto_18", left + 40 + ( math.Clamp( armor * 1.5, 0, 150 ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
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

	-- Color
	local ammocol = Color( 255, 255, 255 )
	-- Convert Ammo to a number if it is a string
	if type( player["ammo1"] ) == "string" then player["ammo1"] = tonumber( player["ammo1"] ) end
	if player["ammo1"] <= 5 and !string.find( player["weapon"], "Grenade" ) and !string.find( player["weapon"], "RPG" ) then
		ammocol = Color( 255, 0, 0 )
	end

	draw.SimpleText( player["ammo1"], "bhud_roboto_20", wep_left + 38, wep_top + 35, ammocol, 0 , 0 )
	draw.SimpleText( "| " .. player["ammo1_max"], "bhud_roboto_20", wep_left + 38 + surface.GetTextSize( player["ammo1"] ) + 6, wep_top + 35, Color( 200, 200, 200 ), 0 , 0 )

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

local bhud_cmenu = false
local jointime = os.time()
local td = {
	time = 0,
	addon = ""
}

local anim_top = 0
local anim_left = 0
local anim_width = 0

function cl_bHUD.showTimeHUD()

	-- CHECK HUD DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawTimeHUD"] then return end

	-- CURRENT TIME HUD
	local time = os.date( "%H:%M" )
	local height = 25
	local top
	local width
	local mode

	surface.SetFont( "bhud_roboto_15" )
	if bhud_cmenu then
		width = 150
		mode = false
		top = 50
	else
		if cl_bHUD_Settings["showday"] then time = os.date( "%d %B %Y - %H:%M" ) end
		width = surface.GetTextSize( time ) + 10
		mode = true
		top = 20
	end

	local left = ScrW() - width - 20

	anim_top = cl_bHUD.Animation( anim_top, top, 0.3 )
	anim_left = cl_bHUD.Animation( anim_left, left, 0.3 )
	anim_width = cl_bHUD.Animation( anim_width, width, 0.3 )

	draw.RoundedBoxEx( 4, anim_left, anim_top, anim_width, height, Color( 50, 50, 50, 230 ), true, true, mode, mode )
	draw.SimpleText( time, "bhud_roboto_15", ScrW() - 25, anim_top + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

	-- CHECK C-KEY
	if !bhud_cmenu then return end

	-- EXTENDED TIME HUD
	local header
	if !cl_bHUD_Settings["showday"] then header = "Time: " else header = os.date( "%d %B %Y" ) end

	draw.SimpleText( header, "bhud_roboto_15", anim_left + 5, anim_top + 5, Color( 255, 255, 255 ), 0 , 0 )

	draw.RoundedBoxEx( 4, anim_left, anim_top + height, anim_width, 67, Color( 100, 100, 100, 230 ), false, false, true, true )

	-- Session
	draw.SimpleText( "Session:", "bhud_roboto_15", anim_left + 5, anim_top + 30, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( os.time() - jointime ), "bhud_roboto_15", anim_left + 11 + surface.GetTextSize( "Session:" ), anim_top + 30, Color( 255, 255, 255 ), 0, 0 )

	-- Total
	draw.SimpleText( "Total:", "bhud_roboto_15", anim_left + 5, anim_top + 50, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( td.time + ( os.time() - jointime ) ), "bhud_roboto_15", anim_left + 11 + surface.GetTextSize( "Total:" ), anim_top + 50, Color( 255, 255, 255 ), 0, 0 )
	
	-- Addon
	draw.SimpleText( "Addon:", "bhud_roboto_15", anim_left + 5, anim_top + 70, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( td.addon, "bhud_roboto_15", anim_left + 11 + surface.GetTextSize( "Addon:" ), anim_top + 70, Color( 255, 255, 255 ), 0, 0 )

end
hook.Add( "HUDPaint", "bhud_showTimeHUD", cl_bHUD.showTimeHUD )



-------------------
--  MINIMAP HUD  --
-------------------

-- DEFAULT MINIMAP VALUES
bhud_map = {}
bhud_map["radius"] = 100
bhud_map["border"] = 7
bhud_map["left"] = ScrW() - bhud_map["radius"] - 10 - bhud_map["border"]
bhud_map["top"] = ScrH() - bhud_map["radius"] - 10 - bhud_map["border"]
bhud_map["tolerance"] = 200

-- CUSTOM MINIMAP SETTINGS
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

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawMapHUD"] then return end

	-- DRAW CIRCLES
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
	
	-- CIRCLE BORDER
	draw_circle( "minimap_border", 60, bhud_map["left"], bhud_map["top"], bhud_map["radius"] + bhud_map["border"], Color( 255, 150, 0 ) )

	-- CIRCLE BACKGROUND
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
		local posx = -sin( d ) * ( math.Clamp( dist, 0, bhud_map["radius"] * 10 ) / 10 )
		local posy = cos( d ) * ( math.Clamp( dist, 0, bhud_map["radius"] * 10 ) / 10 )

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
		surface.DrawText( math.Round( ( LocalPlayer():GetPos():Distance( pl:GetPos() ) * 0.75 ) * 0.0254, 0 ) .. " m" )

	end )

end
hook.Add( "HUDPaint", "bhud_showMinimapHUD", cl_bHUD.showMinimapHUD )



---------------------
--  SETTINGS ICON  --
---------------------

function cl_bHUD.showSettingsIcon()

	if !bhud_cmenu then return end

	-- Check Mouse-Click and Mouse-Position
	if input.IsMouseDown( MOUSE_LEFT ) and !bhud_panel_open then
		local x, y = gui.MousePos()
		if x >= ScrW() - 5 - 16 and x <= ScrW() - 5 and y >= ScrH() - 5 - 16 and y <= ScrH() - 5 then
			cl_bHUD_SettingsPanel()
			bhud_panel_open = true
		end
	end

	-- Draw little symbol
	surface.SetMaterial( Material( "materials/bhud/config.png" ) )
	surface.SetDrawColor( Color( 255, 150, 0, 255 ) )
	surface.DrawTexturedRect( ScrW() - 5 - 16, ScrH() - 5 - 16, 16, 16 )

end
hook.Add( "HUDPaint", "bhud_showSettingsIcon", cl_bHUD.showSettingsIcon )



--------------
--  C-MENU  --
--------------

hook.Add( "OnContextMenuOpen", "bhud_openedContextMenu", function()

	bhud_cmenu = true

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

end )

hook.Add( "OnContextMenuClose", "bhud_closedContextMenu", function()

	bhud_cmenu = false

end )
