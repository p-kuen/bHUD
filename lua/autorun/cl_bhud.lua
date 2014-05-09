--module( "bHUD", package.seeall )
if not CLIENT then return end

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

surface.CreateFont( "bHUD_t", {
 	font = "DermaDefaultBold",
 	size = 15,
 	weight = 500,
	antialias = true,
	outline = false
} )

surface.CreateFont( "bHUD_t_big", {
 	font = "DermaDefaultBold",
 	size = 20,
 	weight = 1000,
	antialias = true,
	outline = false
} )

surface.CreateFont( "bHUD_t_small", {
 	font = "DermaDefaultBold",
 	size = 16,
 	weight = 1000,
	antialias = true,
	outline = false
} )

local bigtimemenu = false

function ShowUserHUD()
	local client = LocalPlayer()
	if client:IsValid() and !client:Alive() then
		return
	end
	if client:GetActiveWeapon() == nil or client:GetActiveWeapon() == NULL or client:GetActiveWeapon() == "Camera" then return end

	local t1

	if team.GetName(client:Team()) == "Unassigned" then
		t1 = client:GetName()
	else
		t1 = "[".. team.GetName(client:Team()) .. "] " .. client:GetName()
	end

	local text_Team
	local text_health = client:Health() .. "%"
	local text_armor = client:Armor() .. "%"

	if string.len(t1) > 22 then
		text_Team = string.Left(t1, 19) .. "..."
	else
		text_Team = t1
	end
	
	

	--///////////////////////////////////////////
	--PLAYER PANEL
	--///////////////////////////////////////////

	local p_w = 100 + 90
	local p_h

	if client:Armor() > 0 then
		hasarmor = true
		p_h = 74
	else
		hasarmor = false
		p_h = 51
	end

	local p_x = 20
	local p_y = ScrH() - p_h - 20

	--Background
	draw.RoundedBox(4, p_x, p_y, p_w, p_h, Color(81,144,222,180))

	--Player-Icon
	surface.SetMaterial( Material( "icon16/user.png" ) )
	surface.SetDrawColor( Color(255, 255, 255, 255) );
	surface.DrawTexturedRect( p_x + 5, p_y + 6, 16, 16 ) 

	--Player-Text
	draw.SimpleTextOutlined(text_Team, "bHUD_s", p_x + 25, p_y + 6, team.GetColor(client:Team()), 0 , 0, 1, Color(60,60,60,255))

	--Heart-Icon
	surface.SetMaterial( Material( "icon16/heart.png" ) )
	surface.SetDrawColor( Color(255, 255, 255, 255) );
	surface.DrawTexturedRect( p_x + 5, p_y + 29, 16, 16 ) 

	--Healthbar
	draw.RoundedBox(4, p_x + 25, p_y + 28, math.Clamp(client:Health()*1.2, 6, 120), 18, Color(255,0,0,150))
	
	--Health Text
	draw.SimpleText(text_health, "bHUD_s", p_x + 100 + 50, p_y + 29, Color(220, 220, 220 ,255), 0 , 0)


	if hasarmor then
		--Armor-Icon
		surface.SetMaterial( Material( "icon16/shield.png" ) )
		surface.SetDrawColor( Color(255, 255, 255, 255) );
		surface.DrawTexturedRect( p_x + 5, p_y + 52, 16, 16 )

		--Armorbar
		draw.RoundedBox(4, p_x + 25, p_y + 51, client:Armor()*1.2, 18, Color(255,255,0,150))

		--Armor Text
		draw.SimpleText(text_armor, "bHUD_s", p_x + 100 + 50, p_y + 52, Color(220, 220, 220 ,255), 0 , 0)
	end

	--local mag_left = :Clip2()
	--local mag_extra = client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType())
	--local secondary_ammo = client:GetAmmoCount(client:GetActiveWeapon():GetSecondaryAmmoType())
	--draw.SimpleText(mag_left, "bHUD_w", p_x + 100 + 100, p_y, Color(255, 255, 255 ,255), 0 , 0)
	--draw.SimpleText(mag_extra, "bHUD_s", p_x + 100 + 120, p_y + 52, Color(255, 255, 255 ,255), 0 , 0)
	--draw.SimpleText(secondary_ammo, "bHUD_s", p_x + 100 + 240, p_y + 52, Color(255, 255, 255 ,255), 0 , 0)
end
hook.Add("HUDPaint", "ShowUserHUD", ShowUserHUD)

local function ShowWeaponHUD()
	local client = LocalPlayer()
	--///////////////////////////////////////////
	--Weapon PANEL
	--///////////////////////////////////////////
	local currentweapon = client:GetActiveWeapon()
	if !client:Alive() or !currentweapon:IsWeapon() then return end

	local text_weaponname = currentweapon:GetPrintName()
	local tc1 = currentweapon:Clip1()
	local text_clip1
	local text_totalammo = client:GetAmmoCount(currentweapon:GetPrimaryAmmoType())
	local tc2 = client:GetAmmoCount(currentweapon:GetSecondaryAmmoType())
	local text_clip2

	if tc1 <= 0 and tc2 <= 0 and text_totalammo <= 0 then return end

	local w_w = 105
	local w_h = 74
	local w_x = 20 + 190 + 5
	local w_y = ScrH() - w_h - 20

	if tc1 == -1 then
		text_clip1 = text_totalammo
		text_totalammo = ""
	else
		text_clip1 = tc1 .. "/"
		text_totalammo = text_totalammo
	end

	if currentweapon:Clip2() == -1 and tc2 <= 0 then
		text_clip2 = ""
	else
		text_clip2 = tc2
	end

	

	--Background
	draw.RoundedBox(4, w_x, w_y, w_w, w_h, Color(150,150,150,180))

	--Name of Weapon
	draw.SimpleText(text_weaponname, "bHUD_s", w_x + 5, w_y + 5, Color(60, 60, 60 ,255), 0 , 0)

	--Clip1
	draw.SimpleText(text_clip1, "bHUD_w", w_x + 5, w_y + 30, Color(220, 220, 220 ,255), 0 , 0)

	--Total Ammo
	surface.SetFont("bHUD_w")
	local a_x = surface.GetTextSize(text_clip1)
	draw.SimpleText(text_totalammo, "bHUD_s", w_x + 5 + a_x + 5, w_y + 35, Color(220, 220, 220 ,255), 0 , 0)

	--Secondary
	draw.SimpleText(text_clip2, "bHUD_s", w_x + 5 + a_x + 5, w_y + 54, Color(220, 220, 220 ,255), 0 , 0)

end
hook.Add("HUDPaint", "ShowWeaponHUD", ShowWeaponHUD)

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

		--[[
		draw.SimpleText(toSingleTimeString(totaltime, "w"), "bHUD_t_small", w_x + (w_w/4), w_y + 55, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(toSingleTimeString(totaltime, "d"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*1, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(toSingleTimeString(totaltime, "h"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*2, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(toSingleTimeString(totaltime, "m"), "bHUD_t_small", w_x + (w_w/4), w_y + 55 + 16*3, Color(220, 220, 220 ,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		]]

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

local function HideHUD(name)
	if (tohide[name]) or GetConVarNumber("cl_drawhud") == 0 then
		return false
	end
end
hook.Add("HUDShouldDraw", "HideOldHud", HideHUD)

function cOpen()
	bigtimemenu = true
end
hook.Add("OnContextMenuOpen", "ContextOpen", cOpen)

function cClose()
	bigtimemenu = false
end
hook.Add("OnContextMenuClose", "ContextClose", cClose)