bhud_init3 = false
local health = 100
local armor = 0
local clip1 = 0
local clip2 = 0
local clip_max_1 = {}
local clip_max_2 = {}
local ammotext = ""
local top = surface.ScreenHeight() - 114
local w_t = top
local height = 63
local w_h = height

function cl_bHUD.design_3()

	local ply = LocalPlayer()

	if !bhud_init3 then

		--Frame
		bhud_avatar_f = vgui.Create( "DFrame" )
		bhud_avatar_f:SetPos( 20, surface.ScreenHeight() - 94 )
		bhud_avatar_f:SetSize( 229, 74 )
		bhud_avatar_f:SetVisible( true )
		bhud_avatar_f:SetTitle( "" )
		bhud_avatar_f:ShowCloseButton( false )
		bhud_avatar_f:SetSizable( false )
		bhud_avatar_f:SetDraggable( false )
		function bhud_avatar_f:Paint() draw.RoundedBox( 4, 0, 0, 229, 74, Color( 0, 0, 0, 0 ) ) end

		--Avatar
		local a = vgui.Create( "AvatarImage", bhud_avatar_f )
		a:SetPos( 5, 5 )
		a:SetSize( 64, 64 )
		a:SetPlayer( ply, 64 )

		bhud_init3 = true

	end

	local player = { name = ply:Nick(), health = ply:Health(), armor = ply:Armor() }
	if LocalPlayer():GetActiveWeapon():IsValid() then
		player.weapon = ply:GetActiveWeapon():GetPrintName()
		player.class = ply:GetActiveWeapon():GetClass()
		player.ammo1 = ply:GetActiveWeapon():Clip1()
		player.ammo1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() )
		player.ammo2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )
	end

	-- Background
	draw.RoundedBox( 4, 20, surface.ScreenHeight() - 94, 229, 74, Color( 0, 0, 0, 230 ) )

	-- Health
	health = cl_bHUD.Animation( health, player.health, 0.5 )
	draw.RoundedBox( 4, 94, surface.ScreenHeight() - 85, math.Clamp( health * 1.5, 6, 149 ), 26, Color( 255, 25, 0 ) )
	if health >= 20 then
		draw.SimpleText( tostring( math.Round( health ) ), "bhud_roboto_22", 97, surface.ScreenHeight() - 83, Color( 255, 255, 255 ), 0, 0 )
	else
		draw.SimpleText( tostring( math.Round( health ) ), "bhud_roboto_22", 99 + math.Clamp( health * 1.5, 6, 149 ), surface.ScreenHeight() - 83, Color( 255, 255, 255 ), 0, 0 )
	end

	-- Armor
	if player.armor > 0 then
		armor = cl_bHUD.Animation( armor, player.armor, 0.5 )
		draw.RoundedBox( 4, 94, surface.ScreenHeight() - 54, math.Clamp( armor * 1.5, 6, 149 ), 26, Color( 0, 161, 222 ) )
		if armor >= 20 then
			draw.SimpleText( tostring( math.Round( armor ) ), "bhud_roboto_22", 97, surface.ScreenHeight() - 52, Color( 255, 255, 255 ), 0, 0 )
		else
			draw.SimpleText( tostring( math.Round( armor ) ), "bhud_roboto_22", 99 + math.Clamp( armor * 1.5, 6, 149 ), surface.ScreenHeight() - 52, Color( 255, 255, 255 ), 0, 0 )
		end
	end


	-- Weapon Background
	if !LocalPlayer():GetActiveWeapon():IsValid() then return end
	if player.ammo1 == -1 and player.ammo1_max <= 0 then return end
	if player.ammo1 == -1 then
		player.ammo1 = player.ammo1_max
		player.ammo1_max = ""
	end
	if player.ammo2_max > 0 then
		top = surface.ScreenHeight() - 114
		height = 94
	else
		top = surface.ScreenHeight() - 83
		height = 63
	end
	w_t = cl_bHUD.Animation( w_t, top, 0.25 )
	w_h = cl_bHUD.Animation( w_h, height, 0.25 )
	draw.RoundedBox( 4, surface.ScreenWidth() - 180, w_t, 160, w_h, Color( 0, 0, 0, 230 ) )

	-- Weapon Name
	draw.SimpleText( player.weapon, "bhud_roboto_22", surface.ScreenWidth() - 175, w_t + 5, Color( 255, 255, 255 ), 0, 0 )

	-- Weapon Clip1
	if !clip_max_1[ player.class ] or player.ammo1 > clip_max_1[ player.class ] then clip_max_1[ player.class ] = player.ammo1 end
	clip1 = cl_bHUD.Animation( clip1, player.ammo1, 0.25 )
	local c1_w = math.Clamp( ( 150 / clip_max_1[ player.class ] ) * clip1, 6, 150 )
	if player.ammo1_max == "" then ammotext = tostring( player.ammo1 ) else ammotext = tostring( player.ammo1 ) .. " / " .. tostring( player.ammo1_max ) end
	draw.RoundedBox( 4, surface.ScreenWidth() - 175, w_t + 32, c1_w, 26, Color( 255, 150, 0 ) )
	draw.SimpleText( ammotext, "bhud_roboto_22", surface.ScreenWidth() - 170, w_t + 34, Color( 255, 255, 255 ), 0, 0 )

	-- Weapon Clip2
	if player.ammo2_max <= 0 then return end
	if !clip_max_2[ player.class ] or player.ammo2_max > clip_max_2[ player.class ] then clip_max_2[ player.class ] = player.ammo2_max end
	clip2 = cl_bHUD.Animation( clip2, player.ammo2_max, 0.25 )
	local c2_w = math.Clamp( ( 150 / clip_max_2[ player.class ] ) * clip2, 6, 150 )
	draw.RoundedBox( 4, surface.ScreenWidth() - 175, w_t + 63, c2_w, 26, Color( 255, 150, 0 ) )
	draw.SimpleText( tostring( math.Round( clip2 ) ), "bhud_roboto_22", surface.ScreenWidth() - 170, w_t + 65, Color( 255, 255, 255 ), 0, 0 )

end
