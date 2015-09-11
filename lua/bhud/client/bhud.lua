-----------------
--  ANIMATION  --
-----------------

function bhud.animate( start, goal, dur )
	
	local fps = 1 / RealFrameTime()
	local diff = math.abs( goal - start )
	local st = ( diff / fps ) / dur

	return start + math.Clamp( goal - start, -st, st )

end



---------------------
--  Short Strings  --
---------------------

function bhud.short( s, w, f )

	surface.SetFont( f )
	if surface.GetTextSize( s ) <= w then return s end
	local ss, ts = "", ""
	for i = 1, string.len( s ) do
		ts = string.sub( s, 1, i ) .. "..."
		if surface.GetTextSize( ts ) < w then ss = string.sub( s, 1, i ) .. "..." end
	end

	return ss

end



------------------
--  CL_DRAWHUD  --
------------------

-- Update cl_drawhud-ConVar
cvars.AddChangeCallback( "cl_drawhud", function( name, old, new )

	bhud.cdraw = tobool( new )

end )



-------------------------
--  Block Vanilla-HUD  --
-------------------------

local function blockVHUD( name )

	if !bhud.cdraw or !bhud.draw then return end
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then return false end

end
hook.Add( "HUDShouldDraw", "bhud_blockVHUD", blockVHUD )



--------------------
--  Restrictions  --
--------------------

net.Receive( "bhud_restrictions", function( len )

	bhud.res = net.ReadTable()

end )



--------------------
--  Context Menu  --
--------------------

hook.Add( "OnContextMenuOpen", "bhud_openedContextMenu", function()

	bhud.cmenu = true
	if exsto then
		bhud.thud.time = LocalPlayer():GetNWInt( "Time_Fixed" )
	elseif utime_enable and utime_enable:GetBool() then
		bhud.thud.time = LocalPlayer():GetNWInt( "TotalUTime" )
	elseif evolve then
		bhud.thud.time = LocalPlayer():GetNWInt( "EV_PlayTime" )
	else
		bhud.thud.time = 0
	end

end )

hook.Add( "OnContextMenuClose", "bhud_closedContextMenu", function()

	bhud.cmenu = false

end )



--------------------------
--  DRAG FUNCTIONALITY  --
--------------------------

local drag, ix, iy
local huds = { "phud", "whud", "mhud" }
hook.Add( "GUIMousePressed", "bhud_pmouse", function( k )

	if k != MOUSE_LEFT then return end
	local x, y = gui.MousePos()

	table.foreach( huds, function( i, hud )

		if !bhud[hud] or ( bhud[hud].draw != nil and !bhud[hud].draw ) then return end
		if x > bhud[hud].x and x < ( bhud[hud].x + bhud[hud].w ) and y > bhud[hud].y and y < ( bhud[hud].y + bhud[hud].h ) then
			ix, iy = x - bhud[hud].x, y - bhud[hud].y
			drag = hud
		end

	end )

end )

hook.Add( "GUIMouseReleased", "bhud_rmouse", function()

	if drag then
		drag = nil
		bhud.save()
	end

end )



----------------
--  DRAW HUD  --
----------------

local function drawHUD()

	if !bhud.me or bhud.ply.name == "unconnected" then
		bhud.me = LocalPlayer()
		bhud.ply.name = bhud.me:Nick()
	end

	-- DRAG
	if drag then

		-- Set position
		local x, y = gui.MousePos()
		bhud[drag].x = math.Round( x - ix, -1 )
		bhud[drag].y = math.Round( y - iy, -1 )

		-- Draw position-information
		surface.SetFont( bhud.font( "roboto", 14 ) )
		local tx = surface.GetTextSize( tostring( bhud[drag].x ) .. ", " .. tostring( bhud[drag].y ) )
		draw.RoundedBox( 4, bhud[drag].x, bhud[drag].y - 30, tx + 10, 23, Color( 0, 0, 0, 200 ) )
		draw.SimpleText( tostring( bhud[drag].x ) .. ", " .. tostring( bhud[drag].y ), bhud.font( "roboto", 14 ), bhud[drag].x + 5, bhud[drag].y - 25, Color( 255, 255, 255 ) )

	end

	-- SETTINGS ICON
	if bhud.cmenu then

		-- Prophunt
		if engine.ActiveGamemode() == "prop_hunt" and !bhud.popen then
			bhud.spanel()
			bhud.popen = true
			return
		end

		-- Check Mouse-Click and Mouse-Position
		if input.IsMouseDown( MOUSE_LEFT ) and !bhud.popen then
			local x, y = gui.MousePos()
			if x >= ScrW() - 5 - 16 and x <= ScrW() - 5 and y >= ScrH() - 5 - 16 and y <= ScrH() - 5 then
				bhud.spanel()
				bhud.popen = true
			end
		end

		-- Draw little symbol
		surface.SetMaterial( Material( "materials/bhud/config.png" ) )
		surface.SetDrawColor( Color( 255, 150, 0, 255 ) )
		surface.DrawTexturedRect( ScrW() - 5 - 16, ScrH() - 5 - 16, 16, 16 )

	end

	-- GENERAL DRAW
	if !bhud.cdraw or !bhud.draw or !bhud.me:Alive() then return end

	-- SET PLAYER DATA
	bhud.ply.health = bhud.me:Health()
	bhud.ply.armor = bhud.me:Armor()
	if bhud.me:GetActiveWeapon():IsValid() then
		bhud.ply.weapon = bhud.me:GetActiveWeapon():GetPrintName()
		bhud.ply.class = bhud.me:GetActiveWeapon():GetClass()
		bhud.ply.clip1 = bhud.me:GetActiveWeapon():Clip1()
		bhud.ply.mclip1 = bhud.me:GetActiveWeapon():GetMaxClip1()
		bhud.ply.mclip2 = bhud.me:GetActiveWeapon():GetMaxClip2()
		bhud.ply.ammo1 = bhud.me:GetAmmoCount( bhud.me:GetActiveWeapon():GetPrimaryAmmoType() )
		bhud.ply.ammo2 = bhud.me:GetAmmoCount( bhud.me:GetActiveWeapon():GetSecondaryAmmoType() )
	end

	-- PlayerHUD
	if bhud.phud.draw then

		bhud[ "des" .. tostring( bhud.phud.design ) ].draw()

		if bhud.phud.design != bhud.cdes then
			table.foreach( bhud[ "des" .. tostring( bhud.phud.design ) ].data, function( s, v )
				bhud.phud[s] = v
			end )
			table.foreach( bhud[ "des" .. tostring( bhud.phud.design ) ].wdata, function( s, v )
				bhud.whud[s] = v
			end )
			bhud.cdes = bhud.phud.design
		end

	end

	-- HoverHUD
	if bhud.hhud.draw and bhud.res.hovernames != true then

		table.foreach( player.GetAll(), function( id, pl )

			if pl != bhud.me and pl:Alive() then

				local pos = pl:GetPos() + Vector( 0, 0, 100 )
				local scr = pos:ToScreen()
				local tcol = team.GetColor( pl:Team() )
				local a = math.Clamp( 255 - ( LocalPlayer():GetPos():Distance( pl:GetPos() ) / 20 ), 0, 255 )

				surface.SetFont( bhud.font( "roboto", 22 ) )
				scr.x = scr.x - ( surface.GetTextSize( pl:Nick() ) / 2 )
				draw.SimpleTextOutlined( pl:Nick(), bhud.font( "roboto", 22 ), scr.x, scr.y, Color( tcol.r, tcol.g, tcol.b, a ), 0 , 0, 1, Color( 100, 100, 100, a ) )

			end

		end )

	end

	-- TimeHUD
	if bhud.thud.draw then

		-- Caluclate vars
		if !bhud.thud.day then bhud.thud.ptime = os.date( "%H:%M" ) else bhud.thud.ptime = os.date( "%d %B %Y - %H:%M" ) end
		surface.SetFont( bhud.font( "roboto", 16, 750 ) )
		bhud.thud.width = surface.GetTextSize( bhud.thud.ptime ) + 10
--[[
		if bhud.cmenu then
			bhud.thud.width = math.Clamp( bhud.thud.width, 130, 300 )
			bhud.thud.top = 50
		else
]]
			bhud.thud.top = 20
--[[
		end
]]
		bhud.thud.left = ScrW() - 20 - bhud.thud.width

		-- Background
--[[	--draw.RoundedBoxEx( 4, bhud.thud.left, bhud.thud.top, bhud.thud.width, 22, Color( 0, 0, 0, 230 ), true, true, !bhud.cmenu, !bhud.cmenu ) ]]
		draw.RoundedBox( 4, bhud.thud.left, bhud.thud.top, bhud.thud.width, 22, Color( 0, 0, 0, 230 ) )

		-- Time
		draw.SimpleText( bhud.thud.ptime, bhud.font( "roboto", 16 ), ScrW() - 25, bhud.thud.top + 3, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
--[[
		if bhud.cmenu then

			-- Background
			draw.RoundedBoxEx( 4, al, at + 22, aw, 50, Color( 0, 0, 0, 200 ), false, false, true, true )

			-- Stats
			if !bhud.thud.day then draw.SimpleText( "Stats:", bhud.font( "roboto", 16, 750 ), al + 5, at + 3, Color( 255, 255, 255 ) ) end

			-- Session
			draw.SimpleText( "Session:", bhud.font( "roboto", 14 ), al + 10, at + 30, Color( 255, 255, 255 ), 0, 0 )
			draw.SimpleText( string.NiceTime( os.time() - bhud.jtime ), bhud.font( "roboto", 14 ), al + 12 + surface.GetTextSize( "Session:" ), at + 30, Color( 255, 255, 255 ) )

			-- Total
			draw.SimpleText( "Total:", bhud.font( "roboto", 14 ), al + 10, at + 50, Color( 255, 255, 255 ), 0, 0 )
			draw.SimpleText( string.NiceTime( bhud.thud.time + ( os.time() - bhud.jtime ) ), bhud.font( "roboto", 14 ), al + 12 + surface.GetTextSize( "Total:" ), at + 50, Color( 255, 255, 255 ) )

		end
]]
	end

	-- MapHUD
	if bhud.mhud.draw and bhud.res.minimap != true and engine.ActiveGamemode() != "prop_hunt" then

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

		local mx, my = bhud.mhud.x + ( bhud.mhud.rad + bhud.mhud.bor ), bhud.mhud.y + ( bhud.mhud.rad + bhud.mhud.bor )

		-- CIRCLE BORDER
		draw_circle( "minimap_border", 60, mx, my, bhud.mhud.rad + bhud.mhud.bor, Color( 255, 150, 0 ) )

		-- CIRCLE BACKGROUND
		draw_circle( "minimap_background", 60, mx, my, bhud.mhud.rad, Color( 50, 50, 50 ) )

		-- MIDDLE CURSOR
		surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
		surface.SetDrawColor( team.GetColor( bhud.me:Team() ) )
		surface.DrawTexturedRect( mx - 8, my - 8, 16, 16 )

		-- NORTH
		local north = math.AngleDifference( bhud.me:EyeAngles().y, 0 )
		surface.SetMaterial( Material( "materials/bhud/north.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255 ) )
		surface.DrawTexturedRect( mx + ( -sin( rad( north ) ) * bhud.mhud.rad ) - 8, my + ( cos( rad( north ) ) * bhud.mhud.rad ) - 8, 16, 16 )

		-- OTHER PLAYERS
		table.foreach( ents.GetAll(), function( id, pl )

			if ( !pl:IsPlayer() and !pl:IsNPC() ) or pl:Health() <= 0 or pl == bhud.me then return end
			if pl:IsNPC() and !bhud.mhud.npc then return end

			-- Set Variables ( Positions, Angles, ... )
			local dist = Vector( bhud.me:GetPos().x, bhud.me:GetPos().y, 0 ):Distance( Vector( pl:GetPos().x, pl:GetPos().y, 0 ) )
			local ang = math.AngleDifference( bhud.me:EyeAngles().y - 180, ( bhud.me:GetPos() - pl:GetPos() ):Angle().y )

			-- Calculate Player-Cursor-Positions
			local posx = -sin( rad( ang + 180 ) ) * ( math.Clamp( dist, 0, bhud.mhud.rad * 10 ) * 0.1 )
			local posy = cos( rad( ang + 180 ) ) * ( math.Clamp( dist, 0, bhud.mhud.rad * 10 ) * 0.1 )

			-- Set correct Cursor-Picture
			if bhud.me:GetPos().z + bhud.mhud.tol < pl:GetPos().z then
				surface.SetMaterial( Material( "materials/bhud/cursor_up.png" ) )
			elseif bhud.me:GetPos().z - bhud.mhud.tol > pl:GetPos().z then
				surface.SetMaterial( Material( "materials/bhud/cursor_down.png" ) )
			else
				surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
			end

			-- Draw Player-Curosr
			local col, name = Color( 255, 255, 255 ), pl:GetClass()
			if pl:IsPlayer() then local col = team.GetColor( pl:Team() ) local name = pl:Nick() end
			surface.SetDrawColor( col )
			surface.DrawTexturedRectRotated( mx + posx, my + posy, 16, 16, -math.AngleDifference( bhud.me:EyeAngles().y, pl:EyeAngles().y ) )

			-- Draw Name and Distance
			draw.SimpleText( name, bhud.font( "roboto", 14 ), mx + posx - 8, my + posy + 10, Color( 255, 255, 255 ) )
			draw.SimpleText( math.Round( ( bhud.me:GetPos():Distance( pl:GetPos() ) * 0.75 ) * 0.0254, 0 ) .. " m", bhud.font( "roboto", 14 ), mx + posx - 8, my + posy + 20, Color( 255, 255, 255 ) )

		end )

	end

end
hook.Add( "HUDPaint", "bhud_drawhud", drawHUD )
