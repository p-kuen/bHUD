--------------------------
--  ENABLE DISABLE HUD  --
--------------------------

-- CL_DRAWHUD - CONVAR
local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
cvars.AddChangeCallback( "cl_drawhud", function( name, old, new )
	if tobool( new ) then drawHUD = true else drawHUD = false end
end )

local bhud_restrictions = {}
net.Receive( "bhud_authed", function( len )
	bhud_restrictions = net.ReadTable()
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

local topa = 0
local topwa = 0
local logo_size = 42
local bar_size = 200
local width = bar_size + logo_size
local left = 20
local leftw = ScrW() - width - 20

local health = 0
local armor = 0
local clip1 = 0
local clip2 = 0
local clip_max_1 = {}
local clip_max_2 = {}
local ammotext = ""

local function MakeTriangle( xpos, ypos, size, col )

	local triangle = {
		{ x = xpos, y = ypos },
		{ x = xpos + ( size * 0.5 ), y = ypos + ( size / 2 ) },
		{ x = xpos, y = ypos + size }
	}

	if !col then surface.SetDrawColor( 50, 50, 50, 255 ) else surface.SetDrawColor( col ) end
	draw.NoTexture()
	surface.DrawPoly( triangle )

end

local function MakeBox( l, t, v, c1, pic, c2, v2 )

	v2 = v2 or nil
	if c2 == nil then c2 = Color( 255, 255, 255 ) end
	if isstring( v ) then
		if !v2 then v2 = v end
		v = 100
	end

	draw.RoundedBox( 0, l, t, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, l + logo_size, t, bar_size * ( math.Clamp( v, 0, 100 ) / 100 ), logo_size, c1 )
	MakeTriangle( l + logo_size, t + ( logo_size / 2 ) - 7, 15 )

	surface.SetMaterial( Material( "materials/bhud/" .. pic ) )
	surface.SetDrawColor( c2 )
	surface.DrawTexturedRect( l + 5, t + 5, 32, 32 )

	if !v2 then
		draw.SimpleText( tostring( math.Round( v, 0 ) ), "bhud_roboto_32_ns", l + logo_size + 10, t + 6, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( v2, "bhud_roboto_32_ns", l + logo_size + 10, t + 6, Color( 255, 255, 255 ), 0, 0 )
	end

end

function cl_bHUD.showHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawPlayerHUD"] then return end
	if !LocalPlayer():Alive() or !LocalPlayer():IsValid() or !LocalPlayer():GetActiveWeapon():IsValid() then return end

	-- PLAYER DATA
	local ply = LocalPlayer()
	local player = {

		name = ply:Nick(),
		health = ply:Health(),
		armor = ply:Armor(),

		weapon = ply:GetActiveWeapon():GetPrintName(),
		class = ply:GetActiveWeapon():GetClass(),
		ammo1 = ply:GetActiveWeapon():Clip1(),
		ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}

	
	local top = ScrH() - left - ( logo_size * 2 ) - 10
	if player["armor"] > 0 then top = top - ( logo_size + 10 ) end
	topa = cl_bHUD.Animation( topa, top, 0.5 )

	local topw = ScrH() - left - ( logo_size * 2 ) - 10
	if player["ammo2_max"] != 0 then topw = topw - ( logo_size + 10 ) end
	topwa = cl_bHUD.Animation( topwa, topw, 0.5 )


	-- NAME
	MakeBox( left, topa, player["name"], Color( 100, 100, 100 ), "player32.png", team.GetColor( ply:Team() ) )
	draw.SimpleText( team.GetName( ply:Team() ), "bhud_default_12_ns", left + logo_size + 10, topa + 30, Color( 255, 255, 255 ), 0, 0 )

	-- HEALTH
	health = cl_bHUD.Animation( health, player["health"], 1 )
	MakeBox( left, topa + 52, health, Color( 255, 25, 0 ), "heart32.png" )
	
	-- ARMOR
	armor = cl_bHUD.Animation( armor, player["armor"], 1 )
	if player["armor"] > 0 then
		MakeBox( left, topa + 104, armor, Color( 0, 161, 222 ), "shield32.png" )
	end

	-- WEAPON
	if player["ammo1"] == -1 and player["ammo1_max"] <= 0 then return end
	if player["ammo1"] == -1 then
		player["ammo1"] = player["ammo1_max"]
		player["ammo1_max"] = ""
	end
	MakeBox( leftw, topwa, player["weapon"], Color( 100, 100, 100 ), "pistol32.png" )

	-- AMMO 1
	if !clip_max_1[ player["class"] ] or player["ammo1"] > clip_max_1[ player["class"] ] then clip_max_1[ player["class"] ] = player["ammo1"] end
	clip1 = cl_bHUD.Animation( clip1, player["ammo1"], 0.25 )
	if player["ammo1_max"] == "" then ammotext = tostring( player["ammo1"] ) else ammotext = tostring( player["ammo1"] ) .. " / " .. tostring( player["ammo1_max"] ) end
	MakeBox( leftw, topwa + 52, ( 100 / clip_max_1[ player["class"] ] ) * clip1, Color( 255, 150, 0 ), "ammo_132.png", nil, ammotext )

	-- AMMO 2
	if !clip_max_2[ player["class"] ] or player["ammo2_max"] > clip_max_2[ player["class"] ] then clip_max_2[ player["class"] ] = player["ammo2_max"] end
	if player["ammo2_max"] != 0 then
		clip2 = cl_bHUD.Animation( clip2, player["ammo2_max"], 0.25 )
		MakeBox( leftw, topwa + 104, ( 100 / clip_max_2[ player["class"] ] ) * clip2, Color( 255, 150, 0 ), "ammo_232.png", nil, tostring( player["ammo2_max"] ) )
	end

end
hook.Add( "HUDPaint", "bhud_showHUD", cl_bHUD.showHUD )



-----------------------------------
--  HOVERNAME / DEATHNOTICE HUD  --
-----------------------------------

local dmsgs = {}
function cl_bHUD.showHovernameHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHoverNames"] or bhud_restrictions["hovernames"] == true then return end

	table.foreach( player.GetAll(), function( id, pl )
		
		if pl == LocalPlayer() or !pl:Alive() then return end
		local pos = pl:GetPos() + Vector( 0, 0, 100 )
		local screen = pos:ToScreen()
		local teamcol = team.GetColor( pl:Team() )
		local alpha = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 20 ), 0, 255 )

		surface.SetFont( "bhud_roboto_22_ns" )
		screen.x = screen.x - ( surface.GetTextSize( pl:Nick() ) / 2 )

		draw.SimpleTextOutlined( pl:Nick(), "bhud_roboto_22_ns", screen.x, screen.y, Color( teamcol.r, teamcol.g, teamcol.b, alpha ), 0 , 0, 1, Color( 100, 100, 100, alpha ) )

	end )

	-- DEATH NOTES
	net.Receive( "bhud_deathnotice", function( len )

		if bhud_restrictions["deathnote"] == true then return end

		local translations = {
			rpg_missile = "RPG",
			npc_grenade_frag = "Grenade",
			prop_physics = "Physics"
		}
		local death = net.ReadTable()
		local infl = death[2]:GetClass()
		if translations[ infl ] != nil then
			infl = translations[ infl ]
		end
		local last = 0
		if #dmsgs > 0 then last = table.GetLastKey( dmsgs ) end
		if death[1] != death[2] and death[3]:IsPlayer() and death[1] != death[3] then
			dmsgs[ last + 1 ] = { death[3]:Nick() .. " killed " .. death[1]:Nick() .. " [" .. infl .. "]", os.time(), 255, 0 }
		elseif death[1] == death[3] then
			dmsgs[ last + 1 ] = { death[1]:Nick() .. " killed himself [" .. infl .. "]", os.time(), 255, 0 }
		elseif death[3]:IsWorld() then
			dmsgs[ last + 1 ] = { "World killed " .. death[1]:Nick(), os.time(), 255, 0 }
		else
			dmsgs[ last + 1 ] = { death[1]:Nick() .. " suicided", os.time(), 255, 0 }
		end

	end )
	
	table.foreach( dmsgs, function( key, dmsg )

		if dmsg[2] + 5 < os.time() then
			dmsg[3] = dmsg[3] - 10
		end
		if dmsg[3] <= 0 then table.remove( dmsgs, key ) end

		surface.SetFont( "bhud_roboto_32_ns" )
		local ww = surface.GetTextSize( dmsg[1] )
		local dx = ScrW() - ww - logo_size - 40
		local dy = 60 + ( 60 * ( key - 1 ) )
		dmsg[4] = cl_bHUD.Animation( dmsg[4], dy, 0.3 )

		-- Box
		draw.RoundedBox( 0, dx, dmsg[4], logo_size, logo_size, Color( 255, 0, 0, dmsg[3] ) )
		draw.RoundedBox( 0, dx + logo_size, dmsg[4], ww + 20, logo_size, Color( 50, 50, 50, dmsg[3] ) )
		MakeTriangle( dx + logo_size, dmsg[4] + ( logo_size / 2 ) - 7, 15, Color( 255, 0, 0, dmsg[3] ) )

		-- Icon & Text
		surface.SetMaterial( Material( "materials/bhud/skull32.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, dmsg[3] ) )
		surface.DrawTexturedRect( dx + 5, dmsg[4] + 5, 32, 32 )
		draw.SimpleText( dmsg[1], "bhud_roboto_32_ns", dx + logo_size + 10, dmsg[4] + 6, Color( 255, 255, 255, dmsg[3] ), 0, 0 )

	end )

end
hook.Add( "HUDPaint", "bhud_showHovernameHUD", cl_bHUD.showHovernameHUD )



----------------
--  TIME HUD  --
----------------

local time = {
	time = 0,
	addon = "",
	jtime = os.time(),
	ctime = os.date( "%H:%M" ),
	top = 0,
	atop = 0,
	left = 0,
	aleft = 0,
	width = 0,
	awidth = 0,
	height = 25,
	mode = false,
	cmenu = false
}

function cl_bHUD.showTimeHUD()

	-- CHECK HUD DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawTimeHUD"] then return end

	-- CURRENT TIME HUD
	time.ctime = os.date( "%H:%M" )
	if time.cmenu then
		time.width = 150
		time.mode = false
		time.top = 50
	else
		if cl_bHUD_Settings["showday"] then time.ctime = os.date( "%d %B %Y - %H:%M" ) end
		surface.SetFont( "bhud_roboto_15_ns" )
		time.width = surface.GetTextSize( time.ctime ) + 10
		time.mode = true
		time.top = 20
	end
	time.left = ScrW() - time.width - 20

	-- Animation
	time.atop = cl_bHUD.Animation( time.atop, time.top, 0.3 )
	time.aleft = cl_bHUD.Animation( time.aleft, time.left, 0.3 )
	time.awidth = cl_bHUD.Animation( time.awidth, time.width, 0.3 )

	draw.RoundedBoxEx( 4, time.aleft, time.atop, time.awidth, time.height, Color( 50, 50, 50, 230 ), true, true, time.mode, time.mode )
	draw.SimpleText( time.ctime, "bhud_roboto_15_ns", ScrW() - 25, time.atop + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

	-- CHECK C-KEY / EXTENDED TIME HUD
	if !time.cmenu then return end

	-- Header
	if !cl_bHUD_Settings["showday"] then time.ctime = "Time: " else time.ctime = os.date( "%d %B %Y" ) end
	draw.SimpleText( time.ctime, "bhud_roboto_15_ns", time.aleft + 5, time.atop + 5, Color( 255, 255, 255 ), 0 , 0 )

	-- Background
	draw.RoundedBoxEx( 4, time.aleft, time.atop + time.height, time.awidth, 67, Color( 100, 100, 100, 230 ), false, false, true, true )

	-- Session
	draw.SimpleText( "Session:", "bhud_roboto_15_ns", time.aleft + 5, time.atop + 30, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( os.time() - time.jtime ), "bhud_roboto_15_ns", time.aleft + 11 + surface.GetTextSize( "Session:" ), time.atop + 30, Color( 255, 255, 255 ), 0, 0 )

	-- Total
	draw.SimpleText( "Total:", "bhud_roboto_15_ns", time.aleft + 5, time.atop + 50, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( time.time + ( os.time() - time.jtime ) ), "bhud_roboto_15_ns", time.aleft + 11 + surface.GetTextSize( "Total:" ), time.atop + 50, Color( 255, 255, 255 ), 0, 0 )
	
	-- Addon
	draw.SimpleText( "Addon:", "bhud_roboto_15_ns", time.aleft + 5, time.atop + 70, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( time.addon, "bhud_roboto_15_ns", time.aleft + 11 + surface.GetTextSize( "Addon:" ), time.atop + 70, Color( 255, 255, 255 ), 0, 0 )

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
	end
	bhud_map[setting] = tonumber( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = 'minimap_" .. setting .. "'" ) )

end )

function cl_bHUD.showMinimapHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD_Settings["drawHUD"] or !cl_bHUD_Settings["drawMapHUD"] or bhud_restrictions["minimap"] == true then return end

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
	surface.DrawTexturedRect( bhud_map["left"] + ( -sin( rad( north ) ) * bhud_map["radius"] ) - 8, bhud_map["top"] + ( cos( rad( north ) ) * bhud_map["radius"] ) - 8, 16, 16 )

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

	if !time.cmenu then return end

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

	time.cmenu = true

	if exsto then
		time.time = LocalPlayer():GetNWInt( "Time_Fixed" )
		time.addon = "Exsto"
	elseif utime_enable and utime_enable:GetBool() then
		time.time = LocalPlayer():GetNWInt( "TotalUTime" )
		time.addon = "UTime"
	elseif evolve then
		time.time = LocalPlayer():GetNWInt( "EV_PlayTime" )
		time.addon = "Evolve"
	else
		time.time = 0
		time.addon = "Not found ..."
	end

end )

hook.Add( "OnContextMenuClose", "bhud_closedContextMenu", function()

	time.cmenu = false

end )
