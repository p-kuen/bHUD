local health = 100
local armor = 0
local width = 196
local height = 70
local heighta = 70
local top = ScrH() - height - 20
local topa = ScrH() - height - 20
local t = 0

local heightw = 65
local heightaw = 65
local topw = ScrH() - heightw - 20
local topaw = ScrH() - heightw - 20

local function MakeImage( l, t, p, c )

	surface.SetMaterial( Material( "materials/bhud/" .. p ) )
	surface.SetDrawColor( c )
	surface.DrawTexturedRect( l, t, 16, 16 )

end

function cl_bHUD.design_1()

	-- PLAYER DATA
	local ply = LocalPlayer()
	local pn = 0
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


	if player.armor > 0 then height = 100 else height = 70 end
	if !cl_bHUD.Settings["player_name"] then
		height = height - 30
		pn = 30
	end
	top = ScrH() - height - 20
	topa = cl_bHUD.Animation( topa, top, 0.3 )
	heighta = cl_bHUD.Animation( heighta, height, 0.3 )
	health = cl_bHUD.Animation( health, player.health, 0.5 )
	armor = cl_bHUD.Animation( armor, player.armor, 0.5 )

	if player.ammo2_max != 0 then heightw = 100 else heightw = 70 end
	topw = ScrH() - heightw - 20
	topaw = cl_bHUD.Animation( topaw, topw, 0.3 )
	heightaw = cl_bHUD.Animation( heightaw, heightw, 0.3 )


	-- BACKGROUND
	draw.RoundedBox( 4, 20, topa, width, heighta, Color( 0, 0, 0, 230 ) )

	-- NAME
	if cl_bHUD.Settings["player_name"] then
	MakeImage( 30, topa + 12, "player16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( player.name, "bhud_roboto_20", 56, topa + 10, team.GetColor( ply:Team() ), 0, 0 )
	end

	-- HEALTH
	MakeImage( 30, topa + 42 - pn, "heart16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, 56, topa + 40 - pn, math.Clamp( health * 1.5, 0, 150 ), 20, Color( 255, 25, 0 ) )
	draw.SimpleText( tostring( math.Round( health ) ), "bhud_roboto_18", 60, topa + 41 - pn, Color( 255, 255, 255 ), 0, 0 )

	-- ARMOR
	if player.armor > 0 then
	MakeImage( 30, topa + 72 - pn, "shield16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, 56, topa + 70 - pn, math.Clamp( armor * 1.5, 0, 150 ), 20, Color( 0, 161, 222 ) )
	draw.SimpleText( tostring( math.Round( armor ) ), "bhud_roboto_18", 60, topa + 71 - pn, Color( 255, 255, 255 ), 0, 0 )
	end

	if !LocalPlayer():GetActiveWeapon():IsValid() then return end
	-- WEAPON-BACKGROUND
	if player.ammo1 == -1 and player.ammo1_max <= 0 then return end
	draw.RoundedBox( 4, 20 + width + 20, topaw, width, heightaw, Color( 0, 0, 0, 230 ) )

	-- WEAPON-NAME
	MakeImage( width + 50, topaw + 12, "pistol16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( player.weapon, "bhud_roboto_20", width + 76, topaw + 10, Color( 255, 255, 255 ), 0, 0 )

	-- WEAPON-AMMO1
	MakeImage( width + 50, topaw + 42, "ammo_116.png", Color( 255, 255, 255 ) )
	if player.ammo1 != -1 then
		draw.SimpleText( tostring( player.ammo1 ) .. " / " .. tostring( player.ammo1_max ), "bhud_roboto_20", width + 76, topaw + 40, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( tostring( player.ammo1_max ), "bhud_roboto_20", width + 76, topaw + 40, Color( 255, 255, 255 ), 0, 0 )
	end

	-- WEAPON-AMMO2
	if player.ammo2_max != 0 then
	MakeImage( width + 50, topaw + 72, "ammo_216.png", Color( 255, 255, 255 ) )
	draw.SimpleText( tostring( player.ammo2_max ), "bhud_roboto_20", width + 76, topaw + 70, Color( 255, 255, 255 ), 0, 0 )
	end

end
