----------------------
--  DEFAULT VALUES  --
----------------------

-- bHUD
bhud.defs.draw = true
bhud.defs.version = 1.5
bhud.defs.cdes = 1

-- HoverHUD
bhud.defs.hhud = { draw = true }

-- PlayerHUD
bhud.defs.phud = { draw = true, design = 1, name = true, x = 20, y = ScrH() - 90, w = 200, h = 70 }

-- WeaponHUD
bhud.defs.whud = { x = 230, y = ScrH() - 90, w = 200, h = 70 }

-- TimeHUD
bhud.defs.thud = { draw = true, day = false }

-- MapHUD
bhud.defs.mhud = { draw = true, npc = false, x = ScrW() - 206 - 10, y = ScrH() - 206 - 10, rad = 100, bor = 3, tol = 200 }
bhud.defs.mhud.w = bhud.defs.mhud.rad * 2 + bhud.defs.mhud.bor * 2
bhud.defs.mhud.h = bhud.defs.mhud.w



----------------------------
--  SAVE / LOAD SETTINGS  --
----------------------------

-- Reset Settings
function bhud.reset( notify )

	file.Write( "bhud_settings.txt", util.TableToJSON( bhud.defs ) )

	table.foreach( bhud.defs, function( k, v )
		bhud[ k ] = v
	end )

	if notify then chat.AddText( Color( 255, 0, 0 ), "[bHUD - Reset] Please reconnect to fully reset bHUD. Thanks!" ) end

end

-- Load Settings
function bhud.load()

	local s = util.JSONToTable( file.Read( "bhud_settings.txt", "DATA" ) )
	if !s.version or s.version < bhud.defs.version then bhud.reset() return end
	table.foreach( s, function( k, v )
		bhud[ k ] = v
	end )

end

-- Save Settings
function bhud.save()

	local s = {}
	table.foreach( bhud.defs, function( k, v )
		if !s[ k ] then s[ k ] = {} end
		if istable( bhud[ k ] ) then
			s[ k ] = {}
			table.foreach( bhud.defs[ k ], function( key, val )
				s[ k ][ key ] = bhud[ k ][ key ]
			end )
		else
			s[ k ] = bhud[ k ]
		end
	end )

	file.Write( "bhud_settings.txt", util.TableToJSON( s ) )

end
concommand.Add( "bhud_reset", function() bhud.reset( true ) end )
if file.Exists( "bhud_settings.txt", "DATA" ) then bhud.load() else bhud.reset() end



----------------------
--  SETTINGS PANEL  --
----------------------

function bhud.spanel()

	local frm = bhud.addfrm( 250, 400, "Settings:" )

	bhud.addlbl( frm, "General:", true )
	bhud.addchk( frm, 230, "Enable bHUD", bhud.draw, function( c ) bhud.draw = c end )

	bhud.addlbl( frm, "HUDs:", true, true )
	bhud.addchk( frm, 230, "Draw PlayerHUD", bhud.phud.draw, function( c ) bhud.phud.draw = c end )
	bhud.addchk( frm, 230, "Draw TimeHUD", bhud.thud.draw, function( c ) bhud.thud.draw = c end )
	bhud.addchk( frm, 230, "Draw Minimap", bhud.mhud.draw, function( c ) bhud.mhud.draw = c end )
	bhud.addchk( frm, 230, "Draw Hovernames", bhud.hhud.draw, function( c ) bhud.hhud.draw = c end )

	bhud.addlbl( frm, "PlayerHUD:", true, true )
	bhud.addchk( frm, 230, "Draw player-name", bhud.phud.name, function( c ) bhud.phud.name = c end )
	bhud.addsld( frm, 230, "Design", bhud.phud.design, 1, bhud.designs, function( v ) bhud.phud.design = v end )

	bhud.addlbl( frm, "TimeHUD:", true, true )
	bhud.addchk( frm, 230, "Draw date", bhud.thud.day, function( c ) bhud.thud.day = c end )

	bhud.addlbl( frm, "Minimap:", true, true )
	bhud.addchk( frm, 230, "Draw NPCs", bhud.mhud.npc, function( c ) bhud.mhud.npc = c end )
	bhud.addsld( frm, 230, "Radius", bhud.mhud.rad, 50, 150, function( v ) bhud.mhud.rad = v end )
	bhud.addsld( frm, 230, "Border", bhud.mhud.bor, 0, 5, function( v ) bhud.mhud.bor = v end )
	bhud.addsld( frm, 230, "X-Pos", bhud.mhud.left, 20 + bhud.mhud.bor + bhud.mhud.rad, ScrW() - bhud.mhud.rad - bhud.mhud.bor - 20, function( v ) bhud.mhud.left = v end )
	bhud.addsld( frm, 230, "Y-Pos", bhud.mhud.top, 20 + bhud.mhud.bor + bhud.mhud.rad, ScrH() - bhud.mhud.rad - bhud.mhud.bor - 20, function( v ) bhud.mhud.top = v end )

end

-- BHUD-SETTINGS INFORMATION
chat.AddText( Color( 255, 50, 0 ), "[bHUD - Settings]", Color( 255, 255, 255 ), " Hold '", Color( 255, 150, 0 ), "C", Color( 255, 255, 255 ), "' and click on the ", Color( 255, 150, 0 ), "orange symbol", Color( 255, 255, 255 ), " in the right bottom corner to open the settings!" )
