function cl_bHUD.addfrm( x, y, w, h )

	local frame = vgui.Create( "DFrame" )
	frame:SetPos( x, y )
	frame:SetSize( w, h )
	frame:SetTitle( "" )
	frame:SetVisible( true )
	frame:SetDraggable( false )
	frame:ShowCloseButton( false )
	frame:SetBackgroundBlur( true )
	frame:MakePopup()

	function frame:Paint()

		draw.RoundedBoxEx( 4, 0, 0, w, 25, Color( 255, 150, 0 ), true, true, false, false )
		draw.RoundedBoxEx( 4, 0, 25, w, h - 25, Color( 50, 50, 50 ), false, false, true, true )
		draw.SimpleText( "bHUD - Settings", "bhud_roboto_18_ns", 5, 3, Color( 50, 50, 50 ), 0, 0 )

		draw.RoundedBox( 2, 5, 30, ( w / 2 ) - 5, h - 35, Color( 60, 60, 60 ) )
		draw.RoundedBox( 2, ( w / 2 ) + 5, 30, ( w / 2 ) - 9, h - 35, Color( 60, 60, 60 ) )

	end

	local close_button = vgui.Create( "DButton", frame )
	close_button:Center()
	close_button:SetFont( "bhud_roboto_18_ns" )
	close_button:SetTextColor( Color( 255, 255, 255 ) )
	close_button:SetText( "x" )
	close_button:SetPos( w - 50, 0 )
	close_button:SetSize( 45, 20 )
	close_button:SetDark( false )

	function close_button:Paint()

		if close_button:IsHovered() then
			draw.RoundedBox( 0, 0, 0, close_button:GetWide(), close_button:GetTall(), Color( 224, 67, 67 ) )
		else
			draw.RoundedBox( 0, 0, 0, close_button:GetWide(), close_button:GetTall(), Color( 200, 80, 80 ) )
		end

	end

	close_button.DoClick = function()

		frame:Close()
		bhud_panel_open = false

	end

	return frame

end

function cl_bHUD.addlbl( derma, text, x, y )

	local lbl = vgui.Create( "DLabel", derma )
	lbl:SetPos( x, y )
	lbl:SetColor( Color( 255, 255, 255 ) )
	lbl:SetFont( "bhud_roboto_16" )
	lbl:SetText( text )
	lbl:SetDark( false )
	lbl:SizeToContents()

end

function cl_bHUD.addchk( derma, text, x, y, setting )

	local chk = vgui.Create( "DCheckBoxLabel", derma )
	chk:SetPos( x, y )
	chk:SetText( "" )
	chk:SetChecked( cl_bHUD_Settings[setting] )
	chk:SizeToContents()

	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 100, 100, 100 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 255, 150, 0 ) )

	end

	function chk:OnChange()

		local IsChecked = chk:GetChecked() and "1" or "0"
		sql.Query( "UPDATE bhud_settings SET value = " .. IsChecked .. " WHERE setting = '" .. setting .. "'" )
		cl_bHUD_Settings[setting] = chk:GetChecked() and true or false

	end

	local lbl = vgui.Create( "DLabel", derma )
	lbl:SetPos( x + 20, y )
	lbl:SetColor( Color( 255, 255, 255 ) )
	lbl:SetFont( "bhud_roboto_16" )
	lbl:SetText( text )
	lbl:SetDark( false )
	lbl:SizeToContents()

end

function cl_bHUD.addsld( derma, text, x, y, w, min, max, value, variable )

	local sld = vgui.Create( "DNumSlider", derma )
	sld:SetPos( x + 70, y - 6 )
	sld:SetWide( w )
	sld:SetMin( min )
	sld:SetMax( max )
	sld:SetDecimals( 0 )
	sld:SetText( "test" )
	sld:SetDark( false )
	sld:SetValue( value )
	sld.Scratch:SetVisible( false )
	sld.Label:SetVisible( false )
	

	local lbl = vgui.Create( "DLabel", derma )
	lbl:SetPos( x, y + 4 )
	lbl:SetColor( Color( 255, 255, 255 ) )
	lbl:SetFont( "bhud_roboto_16" )
	lbl:SetText( text )
	lbl:SetDark( false )
	lbl:SizeToContents()

	local lbl2 = vgui.Create( "DLabel", derma )
	lbl2:SetPos( x + w + 30, y + 4 )
	lbl2:SetColor( Color( 255, 255, 255 ) )
	lbl2:SetFont( "bhud_roboto_16" )
	lbl2:SetText( tostring( value ) )
	lbl2:SetDark( false )
	lbl2:SizeToContents()

	local posx = value

	sld.ValueChanged = function( self, number )
		
		if variable == "radius" then
			bhud_map["radius"] = math.floor( number )
		end
		if variable == "left" then
			bhud_map["left"] = math.floor( number )
		end
		if variable == "top" then
			bhud_map["top"] = math.floor( number )
		end
		if variable == "border" then
			bhud_map["border"] = math.floor( number )
		end

		sql.Query( "UPDATE bhud_settings SET value = " .. math.floor( number ) .. " WHERE setting = 'minimap_" .. variable .. "'" )
		
		lbl2:SetText( tostring( math.floor( number ) ) )
		lbl2:SizeToContents()
		posx = math.floor( number )

	end

	function sld:PaintOver()

		draw.RoundedBox( 2, w - 44, 10, 40, 17, Color( 100, 100, 100 ) )

	end

end
