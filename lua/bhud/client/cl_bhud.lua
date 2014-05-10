-------------
--  FONTS  --
-------------

surface.CreateFont( "bHUD_s", {
 	font = "coolvetica",
 	size = 20,
 	weight = 500,
	antialias = true,
	outline = false
} )

surface.CreateFont( "bHUD_w", {
 	font = "coolvetica",
 	size = 50,
	weight = 500,
 	antialias = true,
} )

surface.CreateFont( "bHUD_w_name", {
 	font = "coolvetica",
 	size = 25,
 	weight = 300,
	antialias = true,
	outline = false
} )

surface.CreateFont( "bHUD_w_ammo", {
 	font = "Lucida Console",
 	size = 50,
 	weight = 300,
	antialias = true,
	outline = false
} )

surface.CreateFont( "bHUD_w_ammo_small", {
	font = "Lucida Console",
	size = 20,
	weight = 300,
	antialias = true,
	outline = false
} )

local drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )
function cl_bHUD.setDrawHUD( ply, cmd, args )

	drawHUD = tobool( GetConVarNumber( "cl_drawhud" ) )

end
concommand.Add( "cl_drawhud", cl_bHUD.setDrawHUD )

function cl_bHUD.drawHUD( HUDName )

	-- Disable Defualt HUD
	if HUDName == "CHudHealth" or HUDName == "CHudBattery" or HUDName == "CHudAmmo" or HUDName == "CHudSecondaryAmmo" then return false end
	
end
hook.Add( "HUDShouldDraw", "bhud_drawHUD", cl_bHUD.drawHUD )


--local bigtimemenu = false

function cl_bHUD.showHUD()

	-- Don't draw the HUD if the cvar cl_drawhud is set to 0
	if !drawHUD then return end

	local ply = LocalPlayer()
	if !ply:Alive() or !ply:IsValid() then return end

	local player = {

		name = ply:Nick(),
		team = team.GetName( ply:Team() ),
		weapon = ply:GetActiveWeapon(),
		health = ply:Health(),
		armor = ply:Armor(),

		wep = ply:GetActiveWeapon(),
		wep_name = ply:GetActiveWeapon():GetPrintName(),
		wep_ammo_1 = ply:GetActiveWeapon():Clip1(),
		wep_ammo_2 = ply:GetActiveWeapon():Clip2(),
		wep_ammo_1_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ),
		wep_ammo_2_max = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )

	}

	-- If the Weapon is not here or the camera
	if player["weapon"] == nil or player["weapon"] == "Camera" then return end

	-- Check the player's Team
	if player["team"] != "" and player["team"] != "Unassigned" then
		player["name"] = "[" .. player["team"] .. "] " .. ply:Nick()
	end

	-- Check length of the name
	if string.len( player["name"] ) > 22 then
		player["name"] = string.Left( player["name"], 19 ) .. "..."
	end


	-- PANEL

	local width = 195
	local height

	if player["armor"] > 0 then
		height = 88
	else
		height = 63
	end

	local left = 20
	local bottom = ScrH() - height - 20

	-- Background
	draw.RoundedBox( 4, left, bottom, width, height, Color( 80, 160, 222, 150 ) )

	-- Name
	surface.SetMaterial( Material( "icon16/user.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, bottom + 10, 16, 16 )
	draw.SimpleTextOutlined( player["name"], "bHUD_s", left + 38, bottom + 10, team.GetColor( ply:Team() ), 0, 0, 1, Color( 50, 50, 50 ) )

	surface.SetFont( "bHUD_s" )

	-- Health
	surface.SetMaterial( Material( "icon16/heart.png" ) )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( left + 10, bottom + 35, 16, 16 )
	draw.RoundedBox( 1, left + 35, bottom + 33, player["health"] * 1.5, 20, Color( 255, 50, 0, 220 ) )
	draw.SimpleText( tostring( player["health"] ) .. "%", "bHUD_s", left + 35 + ( ( player["health"] * 1.5 ) / 2 ) - ( surface.GetTextSize( tostring( player["health"] ) .. "%" ) / 2 ), bottom + 35, Color( 255, 255, 255 ), 0 , 0 )

	if player["armor"] > 0 then

		-- Armor
		surface.SetMaterial( Material( "icon16/shield.png" ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( left + 10, bottom + 60, 16, 16 )
		draw.RoundedBox( 1, left + 35, bottom + 58, player["armor"] * 1.5, 20, Color( 200, 200, 200, 220 ) )
		draw.SimpleText( tostring( player["armor"] ) .. "%", "bHUD_s", left + 35 + ( ( player["armor"] * 1.5 ) / 2 ) - ( surface.GetTextSize( tostring( player["armor"] ) .. "%" ) / 2 ), bottom + 60, Color( 255, 255, 255 ), 0 , 0 )

	end

	-- WEAPONS

	if player["wep_ammo_1"] == -1 and player["wep_ammo_1_max"] == 0 then return end

	local wep_width = 200
	local wep_height = 100
	local wep_left = ScrW() - wep_width - 20
	local wep_bottom = ScrH() - wep_height - 20

	draw.RoundedBox( 4, wep_left, wep_bottom, wep_width, wep_height, Color( 50, 50, 50, 150 ) )

	if player["wep_ammo_1"] == -1 and player["wep_ammo_1_max"] == 0 then return end
	if player["wep_ammo_1"] == -1 then
		player["wep_ammo_1"] = 1
		
	end

	if player["wep_ammo_1"] < 10 then
		player["wep_ammo_1"] = "00" .. tostring( player["wep_ammo_1"] )
	elseif player["wep_ammo_1"] < 100 then
		player["wep_ammo_1"] = "0" .. tostring( player["wep_ammo_1"] )
	end

	surface.SetFont( "bHUD_w_ammo" )
	local w_1_w, w_1_h = surface.GetTextSize( player["wep_ammo_1"] )

	--if string.match( player["wep_ammo_1"], "005" ) then
		draw.SimpleText( player["wep_ammo_1"], "bHUD_w_ammo", wep_left + 10, wep_bottom + 10, Color( 255, 50, 0 ), 0 , 0 )
	--else
		--draw.SimpleText( player["wep_ammo_1"], "bHUD_w_ammo", wep_left + 10, wep_bottom + 10, Color( 255, 255, 255 ), 0 , 0 )
	--end

	draw.SimpleText( "/ " .. player["wep_ammo_1_max"], "bHUD_w_ammo_small", wep_left + w_1_w + 20, wep_bottom + 10, Color( 255, 255, 255 ), 0 , 0 )
	--if player["wep_ammo_2_max"] <= 0 then return end
	if player["wep_ammo_2_max"] < 10 then player["wep_ammo_2_max"] = "0" .. tostring( player["wep_ammo_2_max"] ) end
	draw.SimpleText( "   " .. player["wep_ammo_2_max"], "bHUD_w_ammo_small", wep_left + w_1_w + 20, wep_bottom + 33, Color( 220, 220, 220 ), 0 , 0 )

	--if player["wep_ammo_2"] == -1 and player["wep_ammo_2_max"] == 0 then return end
	--draw.SimpleText( player["wep_ammo_2"] .. " | " .. player["wep_ammo_2_max"], "bHUD_w_ammo_small", wep_left + wep_width - 60, wep_bottom + 10, Color( 255, 255, 0 ), 0 , 0 )

end
hook.Add( "HUDPaint", "bhud_showHUD", cl_bHUD.showHUD )

--[[

local function ShowTimeHUD()
	local w_w = 150
	local w_h = 70
	local w_x = ScrW() - w_w - 15
	local w_y

	local totaltime = 0
	local addon

	if exsto then
		totaltime = LocalPlayer():GetNetworkedInt("Time_Fixed") + LocalPlayer():GetbHUDSessionTime()
		addon = "EXSTO"
	elseif sql.TableExists("utime") then
		totaltime = LocalPlayer():GetNWInt( "TotalUTime" ) + CurTime() - LocalPlayer():GetNWInt( "UTimeStart" )
		addon = "UTIME"
	elseif evolve then
		totaltime = evolve:Time() - LocalPlayer:GetNWInt( "EV_JoinTime" ) + LocalPlayer():GetNWInt( "EV_PlayTime" )
		addon = "EVOLVE"
	else
		totaltime = 0
		addon = "NONE"
	end

	if bigtimemenu then
		w_y = 45
		addon = "(" .. addon .. ")"
	else
		w_y = 15
		addon = ""
	end

	--Background
	--Header
	draw.RoundedBoxEx(4, w_x, w_y, w_w, 25, Color(0,102,204,180), true, true, false, false)
	draw.SimpleText("Time" .. " " .. addon, "bHUD_t", w_x + 5, w_y + 5, Color(220, 220, 220 ,255), 0 , 0)
	draw.SimpleText(os.date("%H:%M"), "bHUD_t", w_x + w_w - 5, w_y + 5, Color(220, 220, 220 ,255), TEXT_ALIGN_RIGHT)

	if bigtimemenu then
		--Box
		draw.RoundedBoxEx(4, w_x, w_y + 25, w_w, w_h, Color(81,144,222,180), false, false, true, true)
		--Lines
		surface.SetDrawColor( 220, 220, 220, 180 )
		surface.DrawLine( w_x + (w_w/2), w_y + 25 + 5, w_x + (w_w/2), w_y + 25 + w_h - 5)

		--TotalTime
		draw.SimpleText("Total", "bHUD_t", w_x + (w_w/4), w_y + 25 + 5, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER)

		
		--draw.SimpleText(toSingleTimeString(totaltime, "w"), "bHUD_t_small", w_x + (w_w/4), w_y + 55, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		--draw.SimpleText(toSingleTimeString(totaltime, "d"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*1, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		--draw.SimpleText(toSingleTimeString(totaltime, "h"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*2, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		--draw.SimpleText(toSingleTimeString(totaltime, "m"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*3, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		

		draw.SimpleText(toDayString(totaltime), "bHUD_t_small", w_x + (w_w/4), w_y + 25 + w_h - 20 - 10 - 5, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(toTimeString(totaltime), "bHUD_t_big", w_x + w_w/4, w_y + 25 + w_h - 20, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


		draw.SimpleText("Session", "bHUD_t", w_x + w_w - (w_w/4), w_y + 25 + 5, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER)
		draw.SimpleText(toTimeString(LocalPlayer():GetbHUDSessionTime()), "bHUD_t_big", w_x + w_w - (w_w/4), w_y + 25 + w_h - 20, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
hook.Add("HUDPaint", "ShowTimeHUD", ShowTimeHUD)

local tohide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}

hook.Add( "OnContextMenuOpen", "ContextOpen", bigtimemenu = true )
hook.Add( "OnContextMenuClose", "ContextClose", bigtimemenu = false )

]]