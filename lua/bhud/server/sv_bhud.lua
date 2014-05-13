resource.AddFile( "img/player.png" )
resource.AddFile( "img/heart.png" )
resource.AddFile( "img/shield.png" )

--[[
function setJoinTime(ply)
	ply:SetbHUDJoinTime( CurTime() )
end	
hook.Add("PlayerInitialSpawn", "SetJoinTime", setJoinTime)
]]