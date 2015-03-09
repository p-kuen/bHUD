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

function bhud.sstring( s, w, f )

	surface.SetFont( f )
	if surface.GetTextSize( s ) <= w then return s end
	local cw = surface.GetTextSize( s )
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
	bhud.cl_drawhud = tobool( new )
end )

-- Block Vanilla-HUD
local function block_vhud( name )
	if !bhud.cl_drawhud then return end
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then return false end
end
hook.Add( "HUDShouldDraw", "bhud_block_vhud", block_vhud )

-- Receive restricted bHUD-Features
net.Receive( "bhud_authed", function( len )
	bhud.res = net.ReadTable()
end )



------------------------
--  PRESET VARIABLES  --
------------------------

-- C-Menu
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



----------------
--  DRAW HUD  --
----------------

local al, at, aw = ScrW(), 0, 10
local function draw_hud()

	-- Check LocalPlayer
	if !bhud.me or !bhud.me:IsPlayer() or bhud.ply.name == "unconnected" then bhud.me = LocalPlayer() bhud.ply.name = LocalPlayer():Nick() return end

	-- Settings Icon
	if bhud.cmenu then

		-- If Gamemode is Prop Hunt open the settings panel immediatly
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

	-- General HUD-Check
	if !bhud.cl_drawhud or !bhud.drawhud or !bhud.me:Alive() then return end

	-- Player Data
	bhud.ply.health = bhud.me:Health()
	bhud.ply.armor = bhud.me:Armor()
	if bhud.me:GetActiveWeapon():IsValid() then
		bhud.ply.weapon = bhud.me:GetActiveWeapon():GetPrintName()
		bhud.ply.class = bhud.me:GetActiveWeapon():GetClass()
		bhud.ply.ammo1 = bhud.me:GetActiveWeapon():Clip1()
		bhud.ply.ammo1_max = bhud.me:GetAmmoCount( bhud.me:GetActiveWeapon():GetPrimaryAmmoType() )
		bhud.ply.ammo2_max = bhud.me:GetAmmoCount( bhud.me:GetActiveWeapon():GetSecondaryAmmoType() )
	end

	-- PlayerHUD
	if bhud.phud.draw then

		bhud[ "design_" .. tostring( bhud.phud.design ) ]()

		-- Necessary to recreate full HUD when changed back to Design 3 (avatar)
		if bhud.phud.design != 3 and bhud_vis3 == true then bhud.avatar:Remove() bhud_vis3 = false end

	end

	-- HoverHUD
	if bhud.hhud.draw and bhud.res.hovername != true then

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
		if bhud.cmenu then
			bhud.thud.width = math.Clamp( bhud.thud.width, 130, 300 )
			bhud.thud.top = 50
		else
			bhud.thud.top = 20
		end
		bhud.thud.left = ScrW() - 20 - bhud.thud.width

		aw = bhud.animate( aw, bhud.thud.width, 0.1 )
		al = bhud.animate( al, bhud.thud.left, 0.1 )
		at = bhud.animate( at, bhud.thud.top, 0.1 )

		-- Background
		draw.RoundedBoxEx( 4, al, at, aw, 22, Color( 0, 0, 0, 230 ), true, true, !bhud.cmenu, !bhud.cmenu )

		-- Time
		draw.SimpleText( bhud.thud.ptime, bhud.font( "roboto", 16, 750 ), ScrW() - 25, math.Round( at + 3 ), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

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
		
		-- CIRCLE BORDER
		draw_circle( "minimap_border", 60, bhud.mhud.left, bhud.mhud.top, bhud.mhud.rad + bhud.mhud.bor, Color( 255, 150, 0 ) )

		-- CIRCLE BACKGROUND
		draw_circle( "minimap_background", 60, bhud.mhud.left, bhud.mhud.top, bhud.mhud.rad, Color( 50, 50, 50 ) )

		-- MIDDLE CURSOR
		surface.SetMaterial( Material( "materials/bhud/cursor.png" ) )
		surface.SetDrawColor( team.GetColor( bhud.me:Team() ) )
		surface.DrawTexturedRect( bhud.mhud.left - 8, bhud.mhud.top - 8, 16, 16 )

		-- NORTH
		local north = math.AngleDifference( bhud.me:EyeAngles().y, 0 )
		surface.SetMaterial( Material( "materials/bhud/north.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255 ) )
		surface.DrawTexturedRect( bhud.mhud.left + ( -sin( rad( north ) ) * bhud.mhud.rad ) - 8, bhud.mhud.top + ( cos( rad( north ) ) * bhud.mhud.rad ) - 8, 16, 16 )

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
			surface.DrawTexturedRectRotated( bhud.mhud.left + posx, bhud.mhud.top + posy, 16, 16, -math.AngleDifference( bhud.me:EyeAngles().y, pl:EyeAngles().y ) )

			-- Draw Name and Distance
			draw.SimpleText( name, bhud.font( "roboto", 14 ), bhud.mhud.left + posx - 8, bhud.mhud.top + posy + 10, Color( 255, 255, 255 ) )
			draw.SimpleText( math.Round( ( bhud.me:GetPos():Distance( pl:GetPos() ) * 0.75 ) * 0.0254, 0 ) .. " m", bhud.font( "roboto", 14 ), bhud.mhud.left + posx - 8, bhud.mhud.top + posy + 20, Color( 255, 255, 255 ) )

		end )

	end

end
hook.Add( "HUDPaint", "bhud_drawhud", draw_hud )
