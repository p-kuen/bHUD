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
	if !cl_bHUD.Settings["drawHUD"] then return end
	if HUDName == "CHudHealth" or HUDName == "CHudBattery" or HUDName == "CHudAmmo" or HUDName == "CHudSecondaryAmmo" then return false end
end
hook.Add( "HUDShouldDraw", "bhud_drawHUD", cl_bHUD.drawHUD )



-----------------------
--  PLAYER INFO HUD  --
-----------------------

function cl_bHUD.showHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD.Settings[ "drawHUD" ] or !cl_bHUD.Settings[ "drawPlayerHUD" ] then return end
	if !LocalPlayer():Alive() or !LocalPlayer():IsValid() then return end

	cl_bHUD["design_" .. tostring( cl_bHUD.Settings["design"] )]()

end
hook.Add( "HUDPaint", "bhud_showHUD", cl_bHUD.showHUD )



-----------------
--  HOVERNAME  --
-----------------

function cl_bHUD.showHovernameHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD.Settings["drawHoverNames"] or bhud_restrictions["hovername"] == true or engine.ActiveGamemode() == "prop_hunt" then return end

	table.foreach( player.GetAll(), function( id, pl )
		
		if pl == LocalPlayer() or !pl:Alive() then return end
		local pos = pl:GetPos() + Vector( 0, 0, 100 )
		local screen = pos:ToScreen()
		local teamcol = team.GetColor( pl:Team() )
		local alpha = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 20 ), 0, 255 )

		surface.SetFont( "bhud_roboto_22" )
		screen.x = screen.x - ( surface.GetTextSize( pl:Nick() ) / 2 )

		draw.SimpleTextOutlined( pl:Nick(), "bhud_roboto_22", screen.x, screen.y, Color( teamcol.r, teamcol.g, teamcol.b, alpha ), 0 , 0, 1, Color( 100, 100, 100, alpha ) )

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
	width = 100,
	top = 20,
	atop = 0,
	left = ScrW() - 120,
	aleft = 0,
	awidth = 0,
	height = 26,
	mode = false,
	cmenu = false
}

function cl_bHUD.showTimeHUD()

	-- CHECK HUD DRAW
	if !drawHUD or !cl_bHUD.Settings["drawHUD"] or !cl_bHUD.Settings["drawTimeHUD"] then return end

	-- CURRENT TIME HUD
	time.ctime = os.date( "%H:%M" )
	if time.cmenu then
		time.width = 150
		time.mode = false
		time.top = 50
	else
		if cl_bHUD.Settings["showday"] then time.ctime = os.date( "%d %B %Y - %H:%M" ) end
		surface.SetFont( "bhud_roboto_16" )
		time.width = surface.GetTextSize( time.ctime ) + 10
		time.mode = true
		time.top = 20
	end
	time.left = ScrW() - time.width - 20

	-- Animation
	time.atop = cl_bHUD.Animation( time.atop, time.top, 0.3 )
	time.aleft = cl_bHUD.Animation( time.aleft, time.left, 0.3 )
	time.awidth = cl_bHUD.Animation( time.awidth, time.width, 0.3 )

	draw.RoundedBoxEx( 4, time.aleft, time.atop, time.awidth, time.height, Color( 0, 0, 0, 230 ), true, true, time.mode, time.mode )
	draw.SimpleText( time.ctime, "bhud_roboto_16", ScrW() - 25, time.atop + 5, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

	-- CHECK C-KEY / EXTENDED TIME HUD
	if !time.cmenu then return end

	-- Header
	if !cl_bHUD.Settings["showday"] then time.ctime = "Time: " else time.ctime = os.date( "%d %B %Y" ) end
	draw.SimpleText( time.ctime, "bhud_roboto_16", time.aleft + 5, time.atop + 5, Color( 255, 255, 255 ), 0 , 0 )

	-- Background
	draw.RoundedBoxEx( 4, time.aleft, time.atop + time.height, time.awidth, 65, Color( 0, 0, 0, 200 ), false, false, true, true )

	-- Session
	draw.SimpleText( "Session:", "bhud_roboto_14", time.aleft + 5, time.atop + 30, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( os.time() - time.jtime ), "bhud_roboto_14", time.aleft + 11 + surface.GetTextSize( "Session:" ), time.atop + 30, Color( 255, 255, 255 ), 0, 0 )

	-- Total
	draw.SimpleText( "Total:", "bhud_roboto_14", time.aleft + 5, time.atop + 50, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( string.NiceTime( time.time + ( os.time() - time.jtime ) ), "bhud_roboto_14", time.aleft + 11 + surface.GetTextSize( "Total:" ), time.atop + 50, Color( 255, 255, 255 ), 0, 0 )
	
	-- Addon
	draw.SimpleText( "Addon:", "bhud_roboto_14", time.aleft + 5, time.atop + 70, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( time.addon, "bhud_roboto_14", time.aleft + 11 + surface.GetTextSize( "Addon:" ), time.atop + 70, Color( 255, 255, 255 ), 0, 0 )

end
hook.Add( "HUDPaint", "bhud_showTimeHUD", cl_bHUD.showTimeHUD )



-------------------
--  MINIMAP HUD  --
-------------------

function cl_bHUD.showMinimapHUD()

	-- CHECK HUD-DRAW
	if !drawHUD or !cl_bHUD.Settings["drawHUD"] or !cl_bHUD.Settings["drawMapHUD"] or bhud_restrictions["minimap"] == true or engine.ActiveGamemode() == "prop_hunt" then return end

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
	draw_circle( "minimap_border", 60, cl_bHUD.Settings[ "map_left" ], cl_bHUD.Settings[ "map_top" ], cl_bHUD.Settings[ "map_radius" ] + cl_bHUD.Settings[ "map_border" ], Color( 255, 150, 0 ) )

	-- CIRCLE BACKGROUND
	draw_circle( "minimap_background", 60, cl_bHUD.Settings[ "map_left" ], cl_bHUD.Settings[ "map_top" ], cl_bHUD.Settings[ "map_radius" ], Color( 50, 50, 50 ) )

	-- MIDDLE CURSOR
	surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
	surface.SetDrawColor( team.GetColor( LocalPlayer():Team() ) )
	surface.DrawTexturedRect( cl_bHUD.Settings[ "map_left" ] - 8, cl_bHUD.Settings[ "map_top" ] - 8, 16, 16 )

	-- NORTH
	local north = math.AngleDifference( LocalPlayer():EyeAngles().y, 0 )
	surface.SetMaterial( Material( "materials/bhud/north.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255 ) )
	surface.DrawTexturedRect( cl_bHUD.Settings[ "map_left" ] + ( -sin( rad( north ) ) * cl_bHUD.Settings[ "map_radius" ] ) - 8, cl_bHUD.Settings[ "map_top" ] + ( cos( rad( north ) ) * cl_bHUD.Settings[ "map_radius" ] ) - 8, 16, 16 )

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
		local posx = -sin( d ) * ( math.Clamp( dist, 0, cl_bHUD.Settings[ "map_radius" ] * 10 ) / 10 )
		local posy = cos( d ) * ( math.Clamp( dist, 0, cl_bHUD.Settings[ "map_radius" ] * 10 ) / 10 )

		-- Set correct Cursor-Picture
		if LocalPlayer():GetPos().z + cl_bHUD.Settings[ "map_tolerance" ] < pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_up.png" ) )
		elseif LocalPlayer():GetPos().z - cl_bHUD.Settings[ "map_tolerance" ] > pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_down.png" ) )
		else
			surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
		end

		-- Draw Player-Curosr
		surface.SetDrawColor( team.GetColor( pl:Team() ) )
		surface.DrawTexturedRectRotated( cl_bHUD.Settings[ "map_left" ] + posx, cl_bHUD.Settings[ "map_top" ] + posy, 16, 16, -math.AngleDifference( e, pl:EyeAngles().y ) )

		-- Draw Playername and Distance
		surface.SetFont( "bhud_roboto_14" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( cl_bHUD.Settings[ "map_left" ] + posx - 8, cl_bHUD.Settings[ "map_top" ] + posy + 10 )
		surface.DrawText( pl:Nick() )
		surface.SetTextPos( cl_bHUD.Settings[ "map_left" ] + posx - 8, cl_bHUD.Settings[ "map_top" ] + posy + 20 )
		surface.DrawText( math.Round( ( LocalPlayer():GetPos():Distance( pl:GetPos() ) * 0.75 ) * 0.0254, 0 ) .. " m" )

	end )

end
hook.Add( "HUDPaint", "bhud_showMinimapHUD", cl_bHUD.showMinimapHUD )



---------------------
--  SETTINGS ICON  --
---------------------

function cl_bHUD.showSettingsIcon()

	if !time.cmenu then return end

	-- If Gamemode is Prop Hunt open the settings panel immediatly
	if engine.ActiveGamemode() == "prop_hunt" and !bhud_panel_open then
		cl_bHUD.SettingsPanel()
		bhud_panel_open = true
		return
	end

	-- Check Mouse-Click and Mouse-Position
	if input.IsMouseDown( MOUSE_LEFT ) and !bhud_panel_open then
		local x, y = gui.MousePos()
		if x >= ScrW() - 5 - 16 and x <= ScrW() - 5 and y >= ScrH() - 5 - 16 and y <= ScrH() - 5 then
			cl_bHUD.SettingsPanel()
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
