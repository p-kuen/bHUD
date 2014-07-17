local health = 0
local armor = 0
local topa = 0
local topwa = 0
local clip_max_1 = {}
local clip_max_2 = {}
local clip1 = 0
local clip2 = 0

local function MakeTriangle( xpos, ypos, size )

	local triangle = {
		{ x = xpos, y = ypos },
		{ x = xpos + ( size * 0.5 ), y = ypos + ( size / 2 ) },
		{ x = xpos, y = ypos + size }
	}

	surface.SetDrawColor( 50, 50, 50, 255 )
	draw.NoTexture()
	surface.DrawPoly( triangle )

end

local function MakeIcon( pic, xpos, ypos, col )

	surface.SetMaterial( Material( pic ) )
	surface.SetDrawColor( col )
	surface.DrawTexturedRect( xpos, ypos, 32, 32 )

end

function cl_bHUD.Design2()

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

	local logo_size = 42
	local bar_size = 200
	local width = bar_size + logo_size
	local left = 20
	local top = ScrH() - left - ( logo_size * 2 ) - 10
	if player["armor"] > 0 then top = top - ( logo_size + 10 ) end
	topa = cl_bHUD.Animation( topa, top, 0.5 )

	local leftw = ScrW() - width - 20
	local topw = ScrH() - left - ( logo_size * 2 ) - 10
	if player["ammo2_max"] != 0 then topw = topw - ( logo_size + 10 ) end
	topwa = cl_bHUD.Animation( topwa, topw, 0.5 )


	-- NAME

	-- Box
	draw.RoundedBox( 0, left, topa, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, left + logo_size, topa, bar_size, logo_size, Color( 100, 100, 100 ) )
	MakeTriangle( left + logo_size, topa + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/player32.png", left + 5, topa + 5, team.GetColor( ply:Team() ) )
	draw.SimpleText( player["name"], "bhud_roboto_32", left + logo_size + 10, topa + 2, Color( 255, 255, 255 ), 0, 0 )
	draw.SimpleText( team.GetName( ply:Team() ), "bhud_default_12_ns", left + logo_size + 4, topa + 28, Color( 255, 255, 255 ), 0, 0 )


	-- HEALTH
	health = cl_bHUD.Animation( health, player["health"], 1 )

	-- Box
	draw.RoundedBox( 0, left, topa + 52, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, left + logo_size, topa + 52, bar_size * ( math.Clamp( health, 0, 100 ) / 100 ), logo_size, Color( 255, 50, 0 ) )
	MakeTriangle( left + logo_size, topa + 52 + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/heart32.png", left + 5, topa + 52 + 6, Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( math.Round( health, 0 ) ), "bhud_roboto_32", left + logo_size + 10, topa + 52 + 6, Color( 255, 255, 255 ), 0, 0 )


	-- ARMOR
	armor = cl_bHUD.Animation( armor, player["armor"], 1 )
	if player["armor"] > 0 then

	-- Box
	draw.RoundedBox( 0, left, top + 104, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, left + logo_size, top + 104, bar_size * ( math.Clamp( armor, 0, 100 ) / 100 ), logo_size, Color( 0, 161, 222 ) )
	MakeTriangle( left + logo_size, top + 104 + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/shield32.png", left + 5, top + 104 + 5, Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( math.Round( armor, 0 ) ), "bhud_roboto_32", left + logo_size + 10, top + 104 + 6, Color( 255, 255, 255 ), 0, 0 )
	end


	-- WEAPON
	if player["ammo1"] == -1 and player["ammo1_max"] <= 0 then
		clip_max_1 = {}
		clip_max_2 = {}
		return
	end
	if player["ammo1"] == -1 then player["ammo1"] = "1" end

	-- Box
	draw.RoundedBox( 0, leftw, topwa, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, leftw + logo_size, topwa, bar_size, logo_size, Color( 100, 100, 100 ) )
	MakeTriangle( leftw + logo_size, topwa + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/pistol32.png", leftw + 5, topwa + 5, Color( 255, 255, 255 ) )
	draw.SimpleText( player["weapon"], "bhud_roboto_32", leftw + logo_size + 10, topwa + 6, Color( 255, 255, 255 ), 0, 0 )


	-- AMMO 1
	if !clip_max_1[ player["class"] ] or player["ammo1"] > clip_max_1[ player["class"] ] then clip_max_1[ player["class"] ] = player["ammo1"] end

	-- Box
	draw.RoundedBox( 0, leftw, topwa + 52, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, leftw + logo_size, topwa + 52, ( 100 / clip_max_1[ player["class"] ] * player["ammo1"] ) * 2, logo_size, Color( 255, 150, 0 ) )
	MakeTriangle( leftw + logo_size, topwa + 52 + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/ammo_132.png", leftw + 5, topwa + 52 + 5, Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( player["ammo1"] ) .. " / " .. tostring( player["ammo1_max"] ), "bhud_roboto_32", leftw + logo_size + 10, topwa + 52 + 6, Color( 255, 255, 255 ), 0, 0 )


	-- AMMO 2
	if !clip_max_2[ player["class"] ] or player["ammo2_max"] > clip_max_2[ player["class"] ] then clip_max_2[ player["class"] ] = player["ammo2_max"] end
	if player["ammo2_max"] != 0 then

	-- Box
	draw.RoundedBox( 0, leftw, topwa + 104, width, logo_size, Color( 50, 50, 50 ) )
	draw.RoundedBox( 0, leftw + logo_size, topwa + 104, ( 100 / clip_max_2[ player["class"] ] * player["ammo2_max"] ) * 2, logo_size, Color( 255, 150, 0 ) )
	MakeTriangle( leftw + logo_size, topwa + 104 + ( logo_size / 2 ) - 7, 15 )

	-- Icon & Text
	MakeIcon( "materials/bhud/ammo_232.png", leftw + 5, topwa + 104 + 5, Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( player["ammo2_max"] ), "bhud_roboto_32", leftw + logo_size + 10, topwa + 104 + 6, Color( 255, 255, 255 ), 0, 0 )
	end

end
