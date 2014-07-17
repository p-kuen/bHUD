----------------------
--  SQL - SETTINGS  --
----------------------

-- CREATE SQL TABLE
sql.Query( "CREATE TABLE IF NOT EXISTS bhud_settings( 'setting' TEXT, value INTEGER );" )

-- LOAD EXISTING SQL-SETTINGS
local check_sql = { "drawHUD", "drawPlayerHUD", "drawHoverNames", "drawTimeHUD", "drawMapHUD", "showday", "design" }
table.foreach( check_sql, function( index, setting )

	if !sql.Query( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) then
		sql.Query( "INSERT INTO bhud_settings ( setting, value ) VALUES( '" .. setting .. "', 1 )" )
		cl_bHUD_Settings[setting] = tobool( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) )
	else
		cl_bHUD_Settings[setting] = tobool( sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) )
	end

end )

-- PANEL
function cl_bHUD_SettingsPanel()

	local pw = ScrW() / 4
	local ph = ScrH() / 4
	if pw < 480 then pw = 480 end
	if ph < 270 then ph = 270 end
	local px = ScrW() / 2 - ( pw / 2 )
	local py = ScrH() / 2 - ( ph / 2 )

	local frm = cl_bHUD.addfrm( px, py, pw, ph )
	local ch = 35
	cl_bHUD.addchk( frm, "Enable bHUD", 10, ch, "drawHUD" )
	cl_bHUD.addchk( frm, "Old design", 135, ch, "design" )
	ch = ch + 35

	cl_bHUD.addlbl( frm, "Player HUD:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Player-HUD", 10, ch, "drawPlayerHUD" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show names over players", 10, ch, "drawHoverNames" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Time HUD:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Time-HUD", 10, ch, "drawTimeHUD" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show Time and Date", 10, ch, "showday" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Minimap:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Minimap", 10, ch, "drawMapHUD" )

	cl_bHUD.addlbl( frm, "Minimap Settings:", pw / 2 + 10, 35 )
	cl_bHUD.addsld( frm, "Radius", pw / 2 + 10, 55, 155, 50, 150, bhud_map["radius"], "radius" )
	cl_bHUD.addsld( frm, "Border", pw / 2 + 10, 75, 155, 0, 15, bhud_map["border"], "border" )
	cl_bHUD.addsld( frm, "X-Position", pw / 2 + 10, 95, 155, 10 + bhud_map["radius"] + bhud_map["border"], ScrW() - bhud_map["radius"] - 10 - bhud_map["border"], bhud_map["left"], "left" )
	cl_bHUD.addsld( frm, "Y-Position", pw / 2 + 10, 115, 155, 10 + bhud_map["radius"] + bhud_map["border"], ScrH() - bhud_map["radius"] - 10 - bhud_map["border"], bhud_map["top"], "top" )

end

-- BHUD-SETTINGS INFORMATION
chat.AddText( Color( 255, 50, 0 ), "[bHUD - Settings]", Color( 255, 255, 255 ), " Hold '", Color( 255, 150, 0 ), "C", Color( 255, 255, 255 ), "' and click on the ", Color( 255, 150, 0 ), "orange symbol", Color( 255, 255, 255 ), " in the right bottom corner to open the settings!" )
