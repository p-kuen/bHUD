-- FRAME
function cl_bHUD.addfrm( x, y, w, h )

	-- Frame
	local frame = vgui.Create( "DFrame" )
	frame:SetPos( x, y )
	frame:SetSize( w, h )
	frame:SetTitle( "" )
	frame:SetVisible( true )
	frame:SetDraggable( false )
	frame:ShowCloseButton( false )
	frame:SetBackgroundBlur( true )
	frame:MakePopup()

	-- Close Button
	local close_button = vgui.Create( "DButton", frame )
	close_button:Center()
	close_button:SetFont( "bhud_marlett_12" )
	close_button:SetTextColor( Color( 255, 255, 255 ) )
	close_button:SetText( "r" )
	close_button:SetPos( w - 50, 0 )
	close_button:SetSize( 45, 20 )
	close_button:SetDark( false )

	-- Actions
	close_button.DoClick = function()

		frame:Close()
		bhud_panel_open = false

	end

	-- Painting
	function frame:Paint()

		draw.RoundedBoxEx( 4, 0, 0, w, 25, Color( 255, 150, 0 ), true, true, false, false )
		draw.RoundedBoxEx( 4, 0, 25, w, h - 25, Color( 50, 50, 50 ), false, false, true, true )
		draw.SimpleText( "bHUD - Settings", "bhud_roboto_18", 5, 3, Color( 50, 50, 50 ), 0, 0 )

		draw.RoundedBox( 4, 5, 30, ( w / 2 ) - 10, h - 35, Color( 60, 60, 60 ) )
		draw.RoundedBox( 4, ( w / 2 ) + 5, 30, ( w / 2 ) - 10, h - 35, Color( 60, 60, 60 ) )

	end

	function close_button:Paint()

		if close_button:IsHovered() then
			draw.RoundedBox( 0, 0, 0, close_button:GetWide(), close_button:GetTall(), Color( 224, 67, 67 ) )
		else
			draw.RoundedBox( 0, 0, 0, close_button:GetWide(), close_button:GetTall(), Color( 200, 80, 80 ) )
		end

	end

	return frame

end

-- LABEL
function cl_bHUD.addlbl( derma, text, x, y )

	local lbl = vgui.Create( "DLabel", derma )
	lbl:SetPos( x, y )
	lbl:SetColor( Color( 255, 255, 255 ) )
	lbl:SetFont( "bhud_roboto_18" )
	lbl:SetText( text )
	lbl:SetDark( false )
	lbl:SizeToContents()

end

-- CHECKBOX
function cl_bHUD.addchk( derma, text, x, y, setting )

	-- Checkbox
	local chk = vgui.Create( "DCheckBoxLabel", derma )
	chk:SetPos( x, y )
	chk:SetText( text )
	chk:SetChecked( cl_bHUD.Settings[setting] )
	chk.Label:SetColor( Color( 255, 255, 255 ) )
	chk.Label:SetFont( "bhud_roboto_14" )
	chk:SizeToContents()

	-- Actions
	function chk:OnChange()

		local IsChecked = chk:GetChecked() and "true" or "false"
		sql.Query( "UPDATE bhud_settings SET value = '" .. IsChecked .. "' WHERE setting = '" .. setting .. "'" )
		cl_bHUD.Settings[setting] = chk:GetChecked() and true or false

	end

	-- Painting
	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 100, 100, 100 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 255, 150, 0 ) )

	end

end

-- SLIDER
function cl_bHUD.addsld( derma, text, x, y, w, min, max, value, variable )

	-- Slider
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

	-- Slider Name
	local lbl = vgui.Create( "DLabel", derma )
	lbl:SetPos( x, y + 4 )
	lbl:SetColor( Color( 255, 255, 255 ) )
	lbl:SetFont( "bhud_roboto_14" )
	lbl:SetText( text )
	lbl:SetDark( false )
	lbl:SizeToContents()

	-- Slider Value
	local lbl2 = vgui.Create( "DLabel", derma )
	lbl2:SetPos( x + w + 34, y + 4 )
	lbl2:SetColor( Color( 255, 255, 255 ) )
	lbl2:SetFont( "bhud_roboto_16" )
	lbl2:SetText( tostring( value ) )
	lbl2:SetDark( false )
	lbl2:SizeToContents()

	local posx = value

	-- Actions
	sld.ValueChanged = function( self, number )

		cl_bHUD.Settings[variable] = math.floor( number )

		sql.Query( "UPDATE bhud_settings SET value = '" .. tostring( math.floor( number ) ) .. "' WHERE setting = '" .. variable .. "'" )
		
		lbl2:SetText( tostring( math.floor( number ) ) )
		lbl2:SizeToContents()
		posx = math.floor( number )

	end

	-- Painting
	function sld:PaintOver()

		draw.RoundedBox( 2, w - 40, 10, 40, 17, Color( 100, 100, 100 ) )

	end

end
