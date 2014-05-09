--module("bHUD", package.seeall )
if not SERVER then return end

function setJoinTime(ply)
	ply:SetbHUDJoinTime( CurTime() )
end	
hook.Add("PlayerInitialSpawn", "SetJoinTime", setJoinTime)