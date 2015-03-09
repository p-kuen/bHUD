local health = 100
local armor = 0
local sa = ScrH()
local clip1 = 0
local clip2 = 0
local clip_max_1 = {}
local clip_max_2 = {}
local lw = ScrW() - 242 - 20
local saw = ScrH()
local ammotext = ""

local function MakeTriangle( x, y, size, col )

	local triangle = {
		{ x = x, y = y },
		{ x = x + ( size * 0.5 ), y = y + ( size / 2 ) },
		{ x = x, y = y + size }
	}

	if !col then surface.SetDrawColor( 50, 50, 50, 255 ) else surface.SetDrawColor( col ) end
	draw.NoTexture()
	surface.DrawPoly( triangle )

end

local function MakeBox( x, y, v, col, pic, piccol, v2 )

	piccol = piccol or Color( 255, 255, 255 )
	if isstring( v ) then
		v2 = v2 or v
		v = 100
	end

	draw.RoundedBox( 0, x, y, 242, 42, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, x + 42, y, 200 * ( math.Clamp( v, 0, 100 ) / 100 ), 42, col )
	MakeTriangle( x + 42, y + ( 42 / 2 ) - 7, 15 )

	surface.SetMaterial( Material( "materials/bhud/" .. pic ) )
	surface.SetDrawColor( piccol )
	surface.DrawTexturedRect( x + 5, y + 5, 32, 32 )

	if !v2 then
		draw.SimpleText( tostring( math.Round( v, 0 ) ), bhud.font( "roboto", 32 ), x + 42 + 10, y + 6, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( v2, bhud.font( "roboto", 32 ), x + 42 + 10, y + 6, Color( 255, 255, 255 ), 0, 0 )
	end

end

function bhud.design_2()

	local s = ScrH() - 20 - 42 - 42 - 20
	if bhud.ply.armor > 0 then s = s - 42 - 20 end

	sa = bhud.animate( sa, s, 0.1 )

	-- Name
	if bhud.phud.name then
		MakeBox( 20, sa, bhud.ply.name, Color( 100, 100, 100 ), "player32.png", team.GetColor( bhud.me:Team() ) )
	end

	-- Health
	health = bhud.animate( health, bhud.ply.health, 0.2 )
	MakeBox( 20, sa + 42 + 20, health, Color( 255, 25, 0 ), "heart32.png" )

	-- Armor
	armor = bhud.animate( armor, bhud.ply.armor, 0.2 )
	if bhud.ply.armor > 0 then
		MakeBox( 20, sa + 42 + 20 + 42 + 20, armor, Color( 0, 161, 222 ), "shield32.png" )
	end

	-- Weapon
	if !bhud.me:GetActiveWeapon():IsValid() then return end
	if bhud.ply.ammo1 == -1 then
		if bhud.ply.ammo1_max <= 0 then return end
		bhud.ply.ammo1 = bhud.ply.ammo1_max
		bhud.ply.ammo1_max = ""
	end
	if bhud.ply.ammo1 == 0 and bhud.ply.ammo1_max == 0 then return end

	local sw = ScrH() - 20 - 42
	if bhud.ply.ammo2_max > 0 then sw = sw - 42 - 20 end

	saw = bhud.animate( saw, sw, 0.1 )

	-- Ammo 1
	if !clip_max_1[ bhud.ply.class ] or bhud.ply.ammo1 > clip_max_1[ bhud.ply.class ] then clip_max_1[ bhud.ply.class ] = bhud.ply.ammo1 end
	clip1 = bhud.animate( clip1, bhud.ply.ammo1, 0.05 )
	if bhud.ply.ammo1_max == "" then ammotext = tostring( bhud.ply.ammo1 ) else ammotext = tostring( bhud.ply.ammo1 ) .. " / " .. tostring( bhud.ply.ammo1_max ) end
	MakeBox( lw, saw, ( 100 / clip_max_1[ bhud.ply.class ] ) * clip1, Color( 255, 150, 0 ), "ammo_132.png", nil, ammotext )

	if bhud.ply.ammo2_max == 0 then return end

	-- Ammo 2
	if !clip_max_2[ bhud.ply.class ] or bhud.ply.ammo2_max > clip_max_2[ bhud.ply.class ] then clip_max_2[ bhud.ply.class ] = bhud.ply.ammo2_max end
	if bhud.ply.ammo2_max != 0 then
		clip2 = bhud.animate( clip2, bhud.ply.ammo2_max, 0.05 )
		MakeBox( lw, saw + 42 + 20, ( 100 / clip_max_2[ bhud.ply.class ] ) * clip2, Color( 255, 150, 0 ), "ammo_232.png", nil, tostring( bhud.ply.ammo2_max ) )
	end

end
