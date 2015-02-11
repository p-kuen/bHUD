local health = 100
local armor = 0
local width = 196
local height = 70
local heighta = 70
local top = ScrH() - height - 20
local t = 0

local heightw = 65
local heightaw = 65
local topw = ScrH() - heightw - 20

local function MakeImage( l, t, p, c )

	surface.SetMaterial( Material( "materials/bhud/" .. p ) )
	surface.SetDrawColor( c )
	surface.DrawTexturedRect( l, t, 16, 16 )

end

function bhud.design_1()

	local pn = 0

	if bhud.ply.armor > 0 then height = 100 else height = 70 end
	if !bhud.phud.name then
		height = height - 30
		pn = 30
	end
	heighta = bhud.animate( heighta, height, 0.1 )
	top = ScrH() - heighta - 20

	health = bhud.animate( health, bhud.ply.health, 0.1 )
	armor = bhud.animate( armor, bhud.ply.armor, 0.1 )

	if bhud.ply.ammo2_max != 0 then heightw = 100 else heightw = 70 end
	heightaw = bhud.animate( heightaw, heightw, 0.1 )
	topw = ScrH() - heightaw - 20

	-- BACKGROUND
	draw.RoundedBox( 4, 20, top, width, heighta, Color( 0, 0, 0, 230 ) )

	-- NAME
	if bhud.phud.name then
	MakeImage( 30, top + 12, "player16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( bhud.sstring( bhud.ply.name, 150, "bhud_roboto_20" ), "bhud_roboto_20", 60, math.Round( top + 10 ), team.GetColor( bhud.me:Team() ), 0, 0 )
	end

	-- HEALTH
	MakeImage( 30, top + 42 - pn, "heart16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, 56, top + 40 - pn, math.Clamp( health * 1.5, 0, 150 ), 20, Color( 255, 25, 0 ) )
	draw.SimpleText( tostring( math.Round( health ) ), "bhud_roboto_18", 60, math.Round( top + 41 - pn ), Color( 255, 255, 255 ), 0, 0 )

	-- ARMOR
	if bhud.ply.armor > 0 then
	MakeImage( 30, top + 72 - pn, "shield16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, 56, top + 70 - pn, math.Clamp( armor * 1.5, 0, 150 ), 20, Color( 0, 161, 222 ) )
	draw.SimpleText( tostring( math.Round( armor ) ), "bhud_roboto_18", 60, math.Round( top + 71 - pn ), Color( 255, 255, 255 ), 0, 0 )
	end

	if !LocalPlayer():GetActiveWeapon():IsValid() or bhud.ply.ammo1 == 0 and bhud.ply.ammo1_max == 0 or bhud.ply.ammo1 == -1 and bhud.ply.ammo1_max <= 0 then return end
	-- WEAPON-BACKGROUND
	draw.RoundedBox( 4, 20 + width + 20, topw, width, heightaw, Color( 0, 0, 0, 230 ) )

	-- WEAPON-NAME
	MakeImage( width + 50, topw + 12, "pistol16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( bhud.sstring( bhud.ply.weapon, 150, "bhud_roboto_20" ), "bhud_roboto_20", width + 76, topw + 10, Color( 255, 255, 255 ), 0, 0 )

	-- WEAPON-AMMO1
	MakeImage( width + 50, topw + 42, "ammo_116.png", Color( 255, 255, 255 ) )
	if bhud.ply.ammo1 != -1 then
		draw.SimpleText( tostring( bhud.ply.ammo1 ) .. " / " .. tostring( bhud.ply.ammo1_max ), "bhud_roboto_20", width + 76, topw + 40, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( tostring( bhud.ply.ammo1_max ), "bhud_roboto_20", width + 76, topw + 40, Color( 255, 255, 255 ), 0, 0 )
	end

	-- WEAPON-AMMO2
	if bhud.ply.ammo2_max != 0 then
	MakeImage( width + 50, topw + 72, "ammo_216.png", Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( bhud.ply.ammo2_max ), "bhud_roboto_20", width + 76, topw + 70, Color( 255, 255, 255 ), 0, 0 )
	end

end
