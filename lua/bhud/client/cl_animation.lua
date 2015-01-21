function cl_bHUD.Animation( start, goal, dur )
	
	local fps = 1 / RealFrameTime()
	local diff = math.abs( goal - start )
	local st = ( diff / fps ) / dur

	return start + math.Clamp( goal - start, -st, st )

end
