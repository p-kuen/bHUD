local health = 0
local armor = 0
local way = false
local h_pulse = 230

function cl_bHUD.Design1()

	-- PLAYER DATA
	local ply = LocalPlayer()
	local player = {

		name = ply:Nick(),
		health = ply:Health(),
		armor = ply:Armor(),

		weapon = ply:GetActiveWeapon():GetPrintName(),
		ammo1 = ply:GetActiveWeapon():Clip1(),
		ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}

	-- HUD SIZES
	local width = 195
	local height
	if player["armor"] > 0 then height = 90 else height = 65 end
	local left = 20
	local top = ScrH() - height - 20

	local wep_width = 200
	local wep_height
	if player["ammo2_max"] != 0 then wep_height = 90 else wep_height = 65 end
	local wep_top = ScrH() - wep_height - 20
	local wep_left = 230

	-- BACKGROUND
	draw.RoundedBox( 4, left, top, width, height, Color( 50, 50, 50, 230 ) )

	-- PLAYER NAME
	surface.SetFont( "bhud_roboto_20" )
	if surface.GetTextSize( player["name"] ) > ( width - 38 - 10 ) then
		while surface.GetTextSize( player["name"] ) > ( width - 38 - 15 ) do
			player["name"] = string.Left( player["name"], string.len( player["name"] ) -1 )
		end
		player["name"] = player["name"] .. "..."
	end

	surface.SetMaterial( Material( "materials/bhud/player.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 12, 16, 16 )

	draw.SimpleText( player["name"], "bhud_roboto_20", left + 38, top + 10, team.GetColor( ply:Team() ), 0, 0 )

	-- PLAYER HEALTH
	health = cl_bHUD.Animation( health, player["health"], 1 )

	surface.SetFont( "bhud_roboto_18" )
	surface.SetMaterial( Material( "materials/bhud/heart.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, top + 37, 16, 16 )

	if player["health"] <= 20 then
		if h_pulse >= 230 then way = false elseif h_pulse <= 100 then way = true end
		if way then h_pulse = h_pulse + 2.5 else h_pulse = h_pulse - 2.5 end
	else h_pulse = 230 end
	draw.RoundedBox( 1, left + 35, top + 35, math.Clamp( health * 1.5, 0, 150 ), 20, Color( 255, 50 + ( 230 - h_pulse ), 0, 230 ) )

	if 10 + surface.GetTextSize( tostring( player["health"] ) ) < health * 1.5 then
		draw.SimpleText( tostring( math.Round( health, 0 ) ), "bhud_roboto_18", left + 30 + ( math.Clamp( health * 1.5, 0, 150 ) ) - surface.GetTextSize( tostring( player["health"] ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	else
		draw.SimpleText( tostring( math.Round( health, 0 ) ), "bhud_roboto_18", left + 40 + ( math.Clamp( health * 1.5, 0, 150 ) ), top + 37, Color( 255, 255, 255 ), 0 , 0 )
	end

	-- PLAYER ARMOR
	if player["armor"] > 0 then

		armor = cl_bHUD.Animation( armor, player["armor"], 1 )

		surface.SetMaterial( Material( "materials/bhud/shield.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( left + 10, top + 62, 16, 16 )

		draw.RoundedBox( 1, left + 35, top + 60, math.Clamp( armor * 1.5, 0, 150 ), 20, Color( 0, 161, 222, 230 ) )

		if 10 + surface.GetTextSize( tostring( player["armor"] ) ) < armor * 1.5 then
			draw.SimpleText( tostring( math.Round( armor, 0 ) ), "bhud_roboto_18", left + 30 + ( math.Clamp( armor * 1.5, 0, 150 ) ) - surface.GetTextSize( tostring( player["armor"] ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		else
			draw.SimpleText( tostring( math.Round( armor, 0 ) ), "bhud_roboto_18", left + 40 + ( math.Clamp( armor * 1.5, 0, 150 ) ), top + 62, Color( 255, 255, 255 ), 0 , 0 )
		end

	end



	-- WEAPONS

	if player["ammo1"] == -1 and player["ammo1_max"] <= 0 then return end
	if player["ammo1"] == -1 then player["ammo1"] = "1" end

	-- BACKGROUND
	draw.RoundedBox( 4, wep_left, wep_top, wep_width, wep_height, Color( 50, 50, 50, 230 ) )

	-- WEAPON NAME
	surface.SetMaterial( Material( "materials/bhud/pistol.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 12, 16, 16 )

	draw.SimpleText( player["weapon"], "bhud_roboto_20", wep_left + 38, wep_top + 10, Color( 255, 255, 255 ), 0 , 0 )

	-- AMMO 1
	surface.SetMaterial( Material( "materials/bhud/ammo_1.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 37, 16, 16 )

	surface.SetFont( "bhud_roboto_20" )

	-- Color
	local ammocol = Color( 255, 255, 255 )
	-- Convert Ammo to a number if it is a string
	if type( player["ammo1"] ) == "string" then player["ammo1"] = tonumber( player["ammo1"] ) end
	if player["ammo1"] <= 5 and !string.find( player["weapon"], "Grenade" ) and !string.find( player["weapon"], "RPG" ) then
		ammocol = Color( 255, 0, 0 )
	end

	draw.SimpleText( player["ammo1"], "bhud_roboto_20", wep_left + 38, wep_top + 35, ammocol, 0 , 0 )
	draw.SimpleText( "| " .. player["ammo1_max"], "bhud_roboto_20", wep_left + 38 + surface.GetTextSize( player["ammo1"] ) + 6, wep_top + 35, Color( 200, 200, 200 ), 0 , 0 )

	if wep_height != 90 then return end

	-- AMMO 2
	surface.SetMaterial( Material( "materials/bhud/ammo_2.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( wep_left + 10, wep_top + 62, 16, 16 )

	draw.SimpleText( player["ammo2_max"], "bhud_roboto_20", wep_left + 38, wep_top + 60, Color( 255, 255, 255 ), 0 , 0 )

end
