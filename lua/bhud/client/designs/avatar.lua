bhud_vis3 = false

local left = 20 + 10 + 64 + 10
local top = ScrH() - 20 - 10 - 64
local height = 70
local wtop = ScrH() - height - 20
local ah, awt = height, ScrH()

local health = 100
local armor = 0
local clip1 = 0
local clip2 = 0
local clip_max_1 = {}
local clip_max_2 = {}
local ammotext = ""

local function MakeImage( l, t, p, c )

	surface.SetMaterial( Material( "materials/bhud/" .. p ) )
	surface.SetDrawColor( c )
	surface.DrawTexturedRect( l, t, 16, 16 )

end

function bhud.design_3()


	if !bhud_vis3 then

		bhud.avatar = vgui.Create( "DPanel" )
		bhud.avatar:SetPos( 30, ScrH() - 64 - 30 )
		bhud.avatar:SetSize( 64, 64 )
		bhud.avatar:SetVisible( true )
		function bhud.avatar:Paint() end

		local a = vgui.Create( "AvatarImage", bhud.avatar )
		a:SetSize( 64, 64 )
		a:SetPlayer( bhud.me, 64 )

		bhud_vis3 = true

	end

	-- Background
	draw.RoundedBox( 4, 20, ScrH() - 64 - 20 - 20, 244, 64 + 20, Color( 0, 0, 0, 230 ) )

	-- Health
	health = bhud.animate( health, bhud.ply.health, 0.1 )
	MakeImage( left, top + 7 + 2, "heart16.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, left + 16 + 10, top + 7, math.Clamp( health * 1.25, 0, 125 ), 20, Color( 255, 25, 0 ) )
	draw.SimpleText( tostring( math.Round( health ) ), "bhud_roboto_18", left + 16 + 10 + 5, top + 7 + 2, Color( 255, 255, 255 ), 0, 0 )

	-- Armor
	armor = bhud.animate( armor, bhud.ply.armor, 0.1 )
	MakeImage( left, top + 20 + 10 + 7 + 2, "shield16.png", Color( 255, 255, 255 ) )
	if bhud.ply.armor > 0 then draw.RoundedBox( 4, left + 16 + 10, top + 20 + 10 + 7, math.Clamp( armor * 1.25, 8, 125 ), 20, Color( 0, 161, 222 ) ) end
	draw.SimpleText( tostring( math.Round( armor ) ), "bhud_roboto_18", left + 16 + 10 + 5, top + 20 + 10 + 7 + 2, Color( 255, 255, 255 ), 0, 0 )

	-- Weapon
	if !LocalPlayer():GetActiveWeapon():IsValid() or bhud.ply.ammo1 == 0 and bhud.ply.ammo1_max == 0 or bhud.ply.ammo1 == -1 and bhud.ply.ammo1_max <= 0 then return end
	if bhud.ply.ammo1 == -1 then bhud.ply.ammo1 = bhud.ply.ammo1_max bhud.ply.ammo1_max = "" end
	if bhud.ply.ammo2_max != 0 then height = 100 else height = 70 end
	ah = bhud.animate( ah, height, 0.1 )
	wtop = ScrH() - ah - 20

	-- Background
	draw.RoundedBox( 4, ScrW() - 216, wtop, 196, ah, Color( 0, 0, 0, 230 ) )

	-- Weapon Name
	MakeImage( ScrW() - 206, wtop + 12, "pistol16.png", Color( 255, 255, 255 ) )
	draw.SimpleText( bhud.sstring( bhud.ply.weapon, 150, "bhud_roboto_20" ), "bhud_roboto_20", ScrW() - 180, wtop + 10, Color( 255, 255, 255 ) )

	-- Ammo1
	if bhud.ply.ammo1_max == "" then ammotext = tostring( bhud.ply.ammo1 ) else ammotext = tostring( bhud.ply.ammo1 ) .. " / " .. tostring( bhud.ply.ammo1_max ) end
	clip1 = bhud.animate( clip1, bhud.ply.ammo1, 0.05 )
	if !clip_max_1[ bhud.ply.class ] or bhud.ply.ammo1 > clip_max_1[ bhud.ply.class ] then clip_max_1[ bhud.ply.class ] = bhud.ply.ammo1 end
	local c1_w = math.Clamp( ( 150 / clip_max_1[ bhud.ply.class ] ) * clip1, 8, 150 )
	MakeImage( ScrW() - 206, wtop + 42, "ammo_116.png", Color( 255, 255, 255 ) )
	draw.RoundedBox( 4, ScrW() - 180, wtop + 40, c1_w, 20, Color( 255, 150, 0 ) )
	draw.SimpleText( ammotext, "bhud_roboto_18", ScrW() - 175, math.Round( wtop + 42 ), Color( 255, 255, 255 ) )

	-- Ammo2
	if bhud.ply.ammo2_max != 0 then
		clip2 = bhud.animate( clip2, bhud.ply.ammo2_max, 0.05 )
		if !clip_max_2[ bhud.ply.class ] or bhud.ply.ammo2_max > clip_max_2[ bhud.ply.class ] then clip_max_2[ bhud.ply.class ] = bhud.ply.ammo2_max end
		local c2_w = math.Clamp( ( 150 / clip_max_2[ bhud.ply.class ] ) * clip2, 8, 150 )
		draw.RoundedBox( 4, ScrW() - 180, wtop + 70, c2_w, 20, Color( 255, 150, 0 ) )
		MakeImage( ScrW() - 206, wtop + 72, "ammo_216.png", Color( 255, 255, 255 ) )
		draw.SimpleText( tostring( bhud.ply.ammo2_max ), "bhud_roboto_18", ScrW() - 175, math.Round( wtop + 72 ), Color( 255, 255, 255 ) )
	end

end
