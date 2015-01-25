-----------------------
--  INITIALIZE VARS  --
-----------------------

local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
cl_bHUD.Restrictions = {}



--------------------------
--  ANIMATION FUNCTION  --
--------------------------

function cl_bHUD.Animation( start, goal, dur )
	
	local fps = 1 / RealFrameTime()
	local diff = math.abs( goal - start )
	local st = ( diff / fps ) / dur

	return start + math.Clamp( goal - start, -st, st )

end



--------------------------
--  ENABLE/DISABLE HUD  --
--------------------------

-- CL_DRAWHUD - CONVAR
cvars.AddChangeCallback( "cl_drawhud", function( name, old, new )
	drawHUD = tobool( new )
end )

net.Receive( "bhud_authed", function( len )
	cl_bHUD.Restrictions = net.ReadTable()
end )

-- BLOCK DEFAULT HUD
function cl_bHUD.shouldDrawHUD( name )

	if !cl_bHUD.Settings.drawHUD then return end
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then return false end

end
hook.Add( "HUDShouldDraw", "bhud_shouldDrawHUD", cl_bHUD.shouldDrawHUD )



-----------------------
--  PLAYER INFO HUD  --
-----------------------

function cl_bHUD.drawPlayerHUD()

	if !drawHUD or !cl_bHUD.Settings.drawHUD or !cl_bHUD.Settings.drawPlayerHUD or !LocalPlayer():Alive() or !LocalPlayer():IsValid() then return end

	cl_bHUD[ "design_" .. tostring( cl_bHUD.Settings.design ) ]()

	-- Necessary to recreate full HUD when changed back to Design 3 (avatar)
	if bhud_init3 and cl_bHUD.Settings.design != 3 then
		bhud_init3 = false
		bhud_avatar_f:Remove()
	end

end
hook.Add( "HUDPaint", "bhud_drawPlayerHUD", cl_bHUD.drawPlayerHUD )



-----------------
--  HOVERNAME  --
-----------------

function cl_bHUD.drawHoverNameHUD()

	if !drawHUD or !cl_bHUD.Settings.drawHUD or !cl_bHUD.Settings.drawHoverNames or cl_bHUD.Restrictions.hovername == true or engine.ActiveGamemode() == "prop_hunt" then return end

	table.foreach( player.GetAll(), function( id, pl )
		
		if pl == LocalPlayer() or !pl:Alive() then return end
		local pos = pl:GetPos() + Vector( 0, 0, 100 )
		local scr = pos:ToScreen()
		local tcol = team.GetColor( pl:Team() )
		local a = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 20 ), 0, 255 )

		surface.SetFont( "bhud_roboto_22" )
		scr.x = scr.x - ( surface.GetTextSize( pl:Nick() ) / 2 )

		draw.SimpleTextOutlined( pl:Nick(), "bhud_roboto_22", scr.x, scr.y, Color( tcol.r, tcol.g, tcol.b, a ), 0 , 0, 1, Color( 100, 100, 100, a ) )

	end )

end
hook.Add( "HUDPaint", "bhud_drawHoverNameHUD", cl_bHUD.drawHoverNameHUD )



----------------
--  TIME HUD  --
----------------

local time = { time = 0, addon = "", jtime = os.time(), ctime = nil, width = 100, awidth = 100, top = 20, atop = 0, left = ScrW() - 120, aleft = ScrW() - 120, height = 26, cmenu = false }
function cl_bHUD.drawTimeHUD()

	if !drawHUD or !cl_bHUD.Settings.drawHUD or !cl_bHUD.Settings.drawTimeHUD then return end

	if !cl_bHUD.Settings.showday then time.ctime = os.date( "%H:%M" ) else time.ctime = os.date( "%d %B %Y - %H:%M" ) end
	surface.SetFont( "bhud_roboto_16" )
	time.width = surface.GetTextSize( time.ctime ) + 10

	if time.cmenu then
		time.width = math.Clamp( time.width, 150, 300 )
		time.top = 50
	else
		time.top = 20
	end
	time.left = ScrW() - time.width - 20

	-- Animation
	time.atop = cl_bHUD.Animation( time.atop, time.top, 0.1 )
	time.aleft = cl_bHUD.Animation( time.aleft, time.left, 0.1 )
	time.awidth = cl_bHUD.Animation( time.awidth, time.width, 0.1 )

	draw.RoundedBoxEx( 4, time.aleft, time.atop, time.awidth, time.height, Color( 0, 0, 0, 230 ), true, true, !time.cmenu, !time.cmenu )
	draw.SimpleText( time.ctime, "bhud_roboto_16", ScrW() - 25, math.Round( time.atop + 5, 0 ), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, 0 )

	-- check 'C'-Key
	if !time.cmenu then return end

	-- Header
	if !cl_bHUD.Settings.showday then draw.SimpleText( "Time:", "bhud_roboto_16", time.aleft + 5, math.Round( time.atop + 5, 0 ), Color( 255, 255, 255 ), 0, 0 ) end

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
hook.Add( "HUDPaint", "bhud_drawTimeHUD", cl_bHUD.drawTimeHUD )



-------------------
--  MINIMAP HUD  --
-------------------

function cl_bHUD.showMinimapHUD()

	if !drawHUD or !cl_bHUD.Settings.drawHUD or !cl_bHUD.Settings.drawMapHUD or cl_bHUD.Restrictions.minimap == true or engine.ActiveGamemode() == "prop_hunt" then return end

	local circles = {}
	local deg = 0
	local sin, cos, rad = math.sin, math.cos, math.rad

	local function draw_circle( name, quality, xpos, ypos, size, color )

		circles[ name ] = {}

		for i = 1, quality do
			deg = rad( i * 360 ) / quality
			circles[ name ][ i ] = {
				x = xpos + cos( deg ) * size,
				y = ypos + sin( deg ) * size
			}
		end

		surface.SetDrawColor( color )
		draw.NoTexture()
		surface.DrawPoly( circles[ name ] )

	end
	
	-- CIRCLE BORDER
	draw_circle( "minimap_border", 60, cl_bHUD.Settings.map_left, cl_bHUD.Settings.map_top, cl_bHUD.Settings.map_radius + cl_bHUD.Settings.map_border, Color( 255, 150, 0 ) )

	-- CIRCLE BACKGROUND
	draw_circle( "minimap_background", 60, cl_bHUD.Settings.map_left, cl_bHUD.Settings.map_top, cl_bHUD.Settings.map_radius, Color( 50, 50, 50 ) )

	-- MIDDLE CURSOR
	surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
	surface.SetDrawColor( team.GetColor( LocalPlayer():Team() ) )
	surface.DrawTexturedRect( cl_bHUD.Settings.map_left - 8, cl_bHUD.Settings.map_top - 8, 16, 16 )

	-- NORTH
	local north = math.AngleDifference( LocalPlayer():EyeAngles().y, 0 )
	surface.SetMaterial( Material( "materials/bhud/north.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255 ) )
	surface.DrawTexturedRect( cl_bHUD.Settings.map_left + ( -sin( rad( north ) ) * cl_bHUD.Settings.map_radius ) - 8, cl_bHUD.Settings.map_top + ( cos( rad( north ) ) * cl_bHUD.Settings.map_radius ) - 8, 16, 16 )

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
		local posx = -sin( d ) * ( math.Clamp( dist, 0, cl_bHUD.Settings.map_radius * 10 ) * 0.1 )
		local posy = cos( d ) * ( math.Clamp( dist, 0, cl_bHUD.Settings.map_radius * 10 ) * 0.1 )

		-- Set correct Cursor-Picture
		if LocalPlayer():GetPos().z + cl_bHUD.Settings.map_tolerance < pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_up.png" ) )
		elseif LocalPlayer():GetPos().z - cl_bHUD.Settings.map_tolerance > pl:GetPos().z then
			surface.SetMaterial( Material( "materials/bhud/cursor_down.png" ) )
		else
			surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
		end

		-- Draw Player-Curosr
		surface.SetDrawColor( team.GetColor( pl:Team() ) )
		surface.DrawTexturedRectRotated( cl_bHUD.Settings.map_left + posx, cl_bHUD.Settings.map_top + posy, 16, 16, -math.AngleDifference( e, pl:EyeAngles().y ) )

		-- Draw Playername and Distance
		surface.SetFont( "bhud_roboto_14" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( cl_bHUD.Settings.map_left + posx - 8, cl_bHUD.Settings.map_top + posy + 10 )
		surface.DrawText( pl:Nick() )
		surface.SetTextPos( cl_bHUD.Settings.map_left + posx - 8, cl_bHUD.Settings.map_top + posy + 20 )
		surface.DrawText( math.Round( ( LocalPlayer():GetPos():Distance( pl:GetPos() ) * 0.75 ) * 0.0254, 0 ) .. " m" )

	end )

end
hook.Add( "HUDPaint", "bhud_showMinimapHUD", cl_bHUD.showMinimapHUD )



---------------------
--  SETTINGS ICON  --
---------------------

function cl_bHUD.drawSettingsIcon()

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
hook.Add( "HUDPaint", "bhud_drawSettingsIcon", cl_bHUD.drawSettingsIcon )



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
