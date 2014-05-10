--[[
function setJoinTime(ply)
	ply:SetbHUDJoinTime( CurTime() )
end	
hook.Add("PlayerInitialSpawn", "SetJoinTime", setJoinTime)
]]