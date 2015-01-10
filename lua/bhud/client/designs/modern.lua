local topa = 0
local topwa = 0
local logo_size = 42
local bar_size = 200
local width = bar_size + logo_size
local left = 20
local leftw = ScrW() - width - 20

local health = 100
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
		draw.SimpleText( tostring( math.Round( v, 0 ) ), "bhud_roboto_32", l + logo_size + 10, t + 6, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( v2, "bhud_roboto_32", l + logo_size + 10, t + 6, Color( 255, 255, 255 ), 0, 0 )
	end

end

function cl_bHUD.design_2()

	-- PLAYER DATA
	local ply = LocalPlayer()
	local player = {

		name = ply:Nick(),
		health = ply:Health(),
		armor = ply:Armor()

	}

	if LocalPlayer():GetActiveWeapon():IsValid() then
		player.weapon = ply:GetActiveWeapon():GetPrintName()
		player.class = ply:GetActiveWeapon():GetClass()
		player.ammo1 = ply:GetActiveWeapon():Clip1()
		player.ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() )
		player.ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )
	end


	local top = ScrH() - left - ( logo_size * 2 ) - 10
	if player["armor"] > 0 then top = top - ( logo_size + 10 ) end
	topa = cl_bHUD.Animation( topa, top, 0.5 )

	local topw = ScrH() - left - ( logo_size * 2 ) - 10
	if player["ammo2_max"] != 0 then topw = topw - ( logo_size + 10 ) end
	topwa = cl_bHUD.Animation( topwa, topw, 0.5 )


	-- NAME
	if cl_bHUD.Settings["player_name"] then
	MakeBox( left, topa, player["name"], Color( 100, 100, 100 ), "player32.png", team.GetColor( ply:Team() ) )
	end

	-- HEALTH
	health = cl_bHUD.Animation( health, player["health"], 1 )
	MakeBox( left, topa + 52, health, Color( 255, 25, 0 ), "heart32.png" )
	
	-- ARMOR
	armor = cl_bHUD.Animation( armor, player["armor"], 1 )
	if player["armor"] > 0 then
		MakeBox( left, topa + 104, armor, Color( 0, 161, 222 ), "shield32.png" )
	end

	if !LocalPlayer():GetActiveWeapon():IsValid() then return end
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
