function cl_bHUD.Animation( start, goal, duration )
	
	local frames = 1 / FrameTime()
	local diff = math.abs( start - goal )
	local step = diff / ( duration * frames ) * 4

	return math.Approach( start, goal, step )

end
