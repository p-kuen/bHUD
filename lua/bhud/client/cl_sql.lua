----------------------
--  SQL - SETTINGS  --
----------------------

-- CREATE SQL TABLE
if sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = 'drawHUD'" ) == "1" then
	sql.Query( "DROP TABLE bhud_settings" )
end
sql.Query( "CREATE TABLE IF NOT EXISTS bhud_settings( 'setting' TEXT, value TEXT )" )

-- SET DEFAULT SQL-SETTINGS
local check_sql = {}
check_sql["drawHUD"] = true
check_sql["drawPlayerHUD"] = true
check_sql["player_name"] = false
check_sql["drawHoverNames"] = true
check_sql["drawTimeHUD"] = true
check_sql["showday"] = false
check_sql["drawMapHUD"] = true
check_sql["design"] = 1
check_sql["map_radius"] = 100
check_sql["map_border"] = 3
check_sql["map_left"] = ScrW() - check_sql["map_radius"] - check_sql["map_border"] - 10
check_sql["map_top"] = ScrH() - check_sql["map_radius"] - check_sql["map_border"] - 10
check_sql["map_tolerance"] = 200

-- LOAD CUSTOM SQL-SETTINGS
table.foreach( check_sql, function( setting, value )

	if !sql.Query( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" ) then
		sql.Query( "INSERT INTO bhud_settings ( setting, value ) VALUES( '" .. setting .. "', '" .. tostring( value ) .. "' )" )
	end

	local val = sql.QueryValue( "SELECT value FROM bhud_settings WHERE setting = '" .. setting .. "'" )
	if val == "true" or val == "false" then
		cl_bHUD.Settings[setting] = tobool( val )
	else
		cl_bHUD.Settings[setting] = tonumber( val )
	end

end )

-- PANEL
function cl_bHUD.SettingsPanel()

	local pw = 500
	local ph = 285
	local px = ScrW() / 2 - ( pw / 2 )
	local py = ScrH() / 2 - ( ph / 2 )

	local frm = cl_bHUD.addfrm( px, py, pw, ph )
	local ch = 35
	cl_bHUD.addlbl( frm, "General:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Enable bHUD", 10, ch, "drawHUD" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Player:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Enable Player-HUD", 10, ch, "drawPlayerHUD" )
	ch = ch + 20
	cl_bHUD.addsld( frm, "Design", 10, ch, 155, 1, cl_bHUD.Settings["designs"], cl_bHUD.Settings["design"], "design" )
	ch = ch + 29
	cl_bHUD.addchk( frm, "Show Player Name", 10, ch, "player_name" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show names over players", 10, ch, "drawHoverNames" )
	ch = ch + 30

	cl_bHUD.addlbl( frm, "Time:", 10, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Time-HUD", 10, ch, "drawTimeHUD" )
	ch = ch + 20
	cl_bHUD.addchk( frm, "Show Time and Date", 10, ch, "showday" )
	ch = 35

	cl_bHUD.addlbl( frm, "Minimap:", pw / 2 + 13, ch )
	ch = ch + 25
	cl_bHUD.addchk( frm, "Show Minimap", pw / 2 + 13, ch, "drawMapHUD" )
	ch = ch + 25
	cl_bHUD.addsld( frm, "Radius", pw / 2 + 13, ch, 155, 50, 150, cl_bHUD.Settings["map_radius"], "map_radius" )
	ch = ch + 25
	cl_bHUD.addsld( frm, "Border", pw / 2 + 13, ch, 155, 0, 15, cl_bHUD.Settings["map_border"], "map_border" )
	ch = ch + 25
	cl_bHUD.addsld( frm, "X-Position", pw / 2 + 13, ch, 155, 10 + cl_bHUD.Settings["map_radius"] + cl_bHUD.Settings["map_border"], ScrW() - cl_bHUD.Settings["map_radius"] - 10 - cl_bHUD.Settings["map_border"], cl_bHUD.Settings["map_left"], "map_left" )
	ch = ch + 25
	cl_bHUD.addsld( frm, "Y-Position", pw / 2 + 13, ch, 155, 10 + cl_bHUD.Settings["map_radius"] + cl_bHUD.Settings["map_border"], ScrH() - cl_bHUD.Settings["map_radius"] - 10 - cl_bHUD.Settings["map_border"], cl_bHUD.Settings["map_top"], "map_top" )

end

-- BHUD-SETTINGS INFORMATION
chat.AddText( Color( 255, 50, 0 ), "[bHUD - Settings]", Color( 255, 255, 255 ), " Hold '", Color( 255, 150, 0 ), "C", Color( 255, 255, 255 ), "' and click on the ", Color( 255, 150, 0 ), "orange symbol", Color( 255, 255, 255 ), " in the right bottom corner to open the settings!" )
