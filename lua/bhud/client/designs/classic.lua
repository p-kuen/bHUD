bhud.des1 = {}

-- Default Size and Position
bhud.des1.data = { x = 20, y = ScrH() - 90, w = 200, h = 70 }
bhud.des1.wdata = { x = 230, y = ScrH() - 90, w = 200, h = 70 }

local name = bhud.phud.name
local pn = 0
local health = 100
local armor = 0

local function MakeImage( l, t, p, c )

	surface.SetMaterial( Material( "materials/bhud/" .. p ) )
	surface.SetDrawColor( c )
	surface.DrawTexturedRect( l, t, 16, 16 )

end

function bhud.des1.draw()

	if bhud.phud.h == 70 and !bhud.phud.name and bhud.ply.armor == 0 then
		pn = 30
		bhud.phud.h = bhud.phud.h - 30
		bhud.phud.y = bhud.phud.y - 30
	end
	if bhud.phud.name != name then
		if bhud.phud.name then
			pn = 0
			bhud.phud.h = bhud.phud.h + 30
			bhud.phud.y = bhud.phud.y - 30
		else
			pn = 30
			bhud.phud.h = bhud.phud.h - 30
			bhud.phud.y = bhud.phud.y + 30
		end
		name = bhud.phud.name
	end

	if bhud.ply.armor > 0 and bhud.phud.h != 100 - pn then
		bhud.phud.h = 100 - pn
		bhud.phud.y = bhud.phud.y - 30
	end
	if bhud.ply.armor == 0 and bhud.phud.h != 70 - pn then
		bhud.phud.h = 70 - pn
		bhud.phud.y = bhud.phud.y + 30
	end

	health = bhud.animate( health, bhud.ply.health, 0.1 )
	armor = bhud.animate( armor, bhud.ply.armor, 0.1 )

	-- BACKGROUND
	draw.RoundedBox( 4, bhud.phud.x, bhud.phud.y, bhud.phud.w, bhud.phud.h, Color( 0, 0, 0, 230 ) )

	-- NAME
	if bhud.phud.name then
	MakeImage( bhud.phud.x + 11, bhud.phud.y + 12, "player16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( bhud.short( bhud.ply.name, 150, bhud.font( "roboto", 20 ) ), bhud.font( "roboto", 20 ), bhud.phud.x + 42, bhud.phud.y + 10, team.GetColor( bhud.me:Team() ), 0, 0 )
	end

	-- HEALTH
	MakeImage( bhud.phud.x + 11, bhud.phud.y + 42 - pn, "heart16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, bhud.phud.x + 38, bhud.phud.y + 40 - pn, math.Clamp( health * 1.5, 0, 150 ), 20, Color( 255, 25, 0 ) )
	draw.SimpleText( tostring( math.Round( health ) ), bhud.font( "roboto", 18, 0 ), bhud.phud.x + 42, math.Round( bhud.phud.y + 41 - pn ), Color( 255, 255, 255 ), 0, 0 )

	-- ARMOR
	if bhud.ply.armor > 0 then
	MakeImage( bhud.phud.x + 11, bhud.phud.y + 72 - pn, "shield16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, bhud.phud.x + 38, bhud.phud.y + 70 - pn, math.Clamp( armor * 1.5, 0, 150 ), 20, Color( 0, 161, 222 ) )
	draw.SimpleText( tostring( math.Round( armor ) ), bhud.font( "roboto", 18, 0 ), bhud.phud.x + 42, math.Round( bhud.phud.y + 71 - pn ), Color( 255, 255, 255 ), 0, 0 )
	end

	--------------
	--  WEAPON  --
	--------------

	if bhud.ply.ammo2_max > 0 and bhud.whud.h != 100 then
		bhud.whud.h = 100
		bhud.whud.y = bhud.whud.y - 30
	end
	if bhud.ply.ammo2_max == 0 and bhud.whud.h != 70 then
		bhud.whud.h = 70
		bhud.whud.y = bhud.whud.y + 30
	end

	if !LocalPlayer():GetActiveWeapon():IsValid() or bhud.ply.ammo1 == 0 and bhud.ply.ammo1_max == 0 or bhud.ply.ammo1 == -1 and bhud.ply.ammo1_max <= 0 and !bhud.cmenu then return end

	-- WEAPON-BACKGROUND
	draw.RoundedBox( 4, bhud.whud.x, bhud.whud.y, bhud.whud.w, bhud.whud.h, Color( 0, 0, 0, 230 ) )

	-- WEAPON-NAME
	MakeImage( bhud.whud.x + 10, bhud.whud.y + 12, "pistol16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( bhud.short( bhud.ply.weapon, 150, bhud.font( "roboto", 20 ) ), bhud.font( "roboto", 20 ), bhud.whud.x + 40, bhud.whud.y + 10, Color( 255, 255, 255 ), 0, 0 )

	-- WEAPON-AMMO1
	MakeImage( bhud.whud.x + 10, bhud.whud.y + 42, "ammo_116.png", Color( 255, 255, 255 ) )
	if bhud.ply.ammo1 != -1 then
		draw.SimpleText( tostring( bhud.ply.ammo1 ) .. " / " .. tostring( bhud.ply.ammo1_max ), bhud.font( "roboto", 20 ), bhud.whud.x + 40, bhud.whud.y + 41, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( tostring( bhud.ply.ammo1_max ), bhud.font( "roboto", 20 ), bhud.whud.x + 40, bhud.whud.y + 41, Color( 255, 255, 255 ), 0, 0 )
	end

	-- WEAPON-AMMO2
	if bhud.ply.ammo2_max == 0 then return end
	MakeImage( bhud.whud.x + 10, bhud.whud.y + 72, "ammo_216.png", Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( bhud.ply.ammo2_max ), bhud.font( "roboto", 20 ), bhud.whud.x + 40, bhud.whud.y + 71, Color( 255, 255, 255 ), 0, 0 )

end
