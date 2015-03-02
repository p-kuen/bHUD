-- FRAME
function bhud.addfrm( w, h, title )

	-- Frame
	local frm = vgui.Create( "DPanel" )
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:MakePopup()

	function frm:Paint( w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 127.5 ) )
		draw.RoundedBox( 4, 1, 1, w - 2, h - 2, Color( 255, 150, 30 ) )
		draw.RoundedBoxEx( 4, 1, 50, w - 2, h - 51, Color( 255, 255, 255 ), false, false, true, true )
	end

	-- Title
	frm.title = vgui.Create( "DLabel", frm )
	frm.title:SetText( title )
	frm.title:SetPos( 15, 12.5 )
	frm.title:SetFont( "bhud_roboto_25" )
	frm.title:SetColor( Color( 0, 0, 0, 191.25 ) )
	frm.title:SizeToContents()

	-- Close-Button
	frm.close = vgui.Create( "DButton", frm )
	frm.close:SetPos( w - 40, 10 )
	frm.close:SetSize( 30, 30 )
	frm.close:SetText( "" )
	function frm.close.DoClick() bhud.popen = false bhud.save() frm:Remove() end

	function frm.close:Paint()

		if self.Depressed then draw.RoundedBox( 4, 0, 0, 30, 30, Color( 135, 50, 50 ) )
		elseif self.Hovered then draw.RoundedBox( 4, 0, 0, 30, 30, Color( 200, 60, 60 ) )
		else draw.RoundedBox( 4, 0, 0, 30, 30, Color( 200, 80, 80 ) )
		end
		draw.SimpleText( "r", "bhud_marlett_14", 9, 8, Color( 255, 255, 255 ) )

	end

	frm.list = vgui.Create( "DPanelList", frm )
	frm.list:SetPos( 10, 60 )
	frm.list:SetSize( w - 20, h - 70 )
	frm.list:SetSpacing( 5 )
	frm.list:EnableHorizontal( false )
	frm.list:EnableVerticalScrollbar( true )
	frm.list.VBar.btnUp:SetVisible( false )
	frm.list.VBar.btnDown:SetVisible( false )

	function frm.list.VBar:PerformLayout()

		local Scroll = self:GetScroll() / self.CanvasSize
		local BarSize = math.max( self:BarScale() * self:GetTall(), 10 )
		local Track = self:GetTall() - BarSize
		Track = Track + 1
		Scroll = Scroll * Track

		self.btnGrip:SetPos( 0, Scroll )
		self.btnGrip:SetSize( 13, BarSize )

	end

	function frm.list.VBar:Paint() end

	function frm.list.VBar.btnGrip:Paint()
		draw.RoundedBox( 0, 8, 0, 5, frm.list.VBar.btnGrip:GetTall(), Color( 0, 0, 0, 100 ) )
	end

	return frm.list

end

-- LABEL
function bhud.addlbl( d, text, bold, space )

	local lbl = vgui.Create( "DLabel" )
	if bold == true then lbl:SetFont( "bhud_roboto_18_bold" ) else lbl:SetFont( "bhud_roboto_28" ) end
	if space == true then text = "\n" .. text end
	lbl:SetText( text )
	lbl:SetColor( Color( 50, 50, 50 ) )
	lbl:SizeToContents()
	d:AddItem( lbl )

end

-- CHECKBOX
function bhud.addchk( d, w, text, c, cb )

	local chk = vgui.Create( "DPanel", d )
	chk:SetSize( w, 20 )

	chk.lbl = vgui.Create( "DLabel", chk )
	chk.lbl:SetText( text )
	chk.lbl:SetPos( 5, 3 )
	chk.lbl:SetFont( "bhud_roboto_16" )
	chk.lbl:SetColor( Color( 50, 50, 50 ) )
	chk.lbl:SizeToContents()

	chk.box = vgui.Create( "DCheckBox", chk )
	chk.box:SetPos( w - 55, 0 )
	chk.box:SetSize( 40, 20 )
	chk.box:SetChecked( c )

	function chk:Paint() end

	function chk.box:Paint()
		if chk.box:GetChecked() then
			draw.RoundedBox( 4, 0, 0, 40, 20, Color( 255, 150, 0 ) )
			draw.RoundedBox( 4, 23, 3, 14, 14, Color( 240, 240, 240 ) )
			draw.SimpleText( "ON", "bhud_roboto_12", 5, 5, Color( 255, 255, 255 ) )
		else
			draw.RoundedBox( 4, 0, 0, 40, 20, Color( 75, 75, 75 ) )
			draw.RoundedBox( 4, 3, 3, 14, 14, Color( 240, 240, 240 ) )
			draw.SimpleText( "OFF", "bhud_roboto_12", 20, 5, Color( 255, 255, 255 ) )
		end
	end

	function chk.box:OnChange( c )
		cb( c )
	end

	d:AddItem( chk )

end

-- SLIDER
function bhud.addsld( d, w, text, v, min, max, cb )

	local sld = vgui.Create( "DNumSlider", d )
	sld:SetMin( min )
	sld:SetMax( max )
	sld:SetValue( v )
	sld:SetText( "" )
	sld:SetSize( 10, 20 )
	sld.Scratch:SetVisible( false )

	function sld:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
		draw.SimpleText( text, "bhud_roboto_16", 5, 2, Color( 50, 50, 50 ) )
		draw.RoundedBox( 0, ( w / 2.4 ) + 8, 9, ( w / 2.4 ) - 23, 3, Color( 230, 230, 230 ) )
	end

	function sld:PaintOver( w, h )
		draw.RoundedBox( 0, w - 45, 0, w, h, Color( 255, 255, 255 ) )
		draw.RoundedBox( 4, w - 42, 0, 40, 20, Color( 75, 75, 75 ) )
		draw.SimpleText( tostring( math.Round( sld:GetValue() ) ), "bhud_roboto_16", w - 38, 2, Color( 255, 255, 255 ) )
	end

	function sld.Slider:Paint() end

	function sld.Slider.Knob:Paint( w, h )
		draw.RoundedBox( 2, 2, 2, 11, 11, Color( 255, 150, 0 ) )
	end

	function sld:OnValueChanged( v )
		cb( math.Round( v ) )
	end

	d:AddItem( sld )

end
