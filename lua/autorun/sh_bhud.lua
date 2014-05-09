AddCSLuaFile("autorun/sh_bhud.lua")
AddCSLuaFile("autorun/cl_bhud.lua")

--module("bHUD", package.seeall )

local meta = FindMetaTable("Player")
if not meta then return end

function meta:GetbHUDJoinTime()
	return self:GetNWInt( "bhud_JoinTime" )
end

function meta:SetbHUDJoinTime(time)
	self:SetNWInt( "bhud_JoinTime", time)
end

function meta:GetbHUDSessionTime()
	return CurTime() - self:GetbHUDJoinTime()
end

function toTimeString( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24

	return string.format( "%02i:%02i", h, m )
end

function toDayString( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	return string.format( "%iw / %id", w, d )
end

function toSingleTimeString( time, format)
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	local number
	local text
	local addition
	
	if format == "s" then
		text = "second"
		number = s
	elseif format == "m" then
		text = "minute"
		number = m
	elseif format == "h" then
		text = "hour"
		number = h
	elseif format == "d" then
		text = "day"
		number = d
	elseif format == "w" then
		text = "week"
		number = w
	end
	if number >= 2 or number == 0 then addition = "s" else addition = "" end
	text = text .. addition
	return string.format( "%i ".. text, number )
end

function menuBar(pnl)
	print("MENU BAR!")
end
hook.Add("ContextMenuOpen", "MenuBar", menuBar)