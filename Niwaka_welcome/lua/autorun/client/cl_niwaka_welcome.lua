--[[-------------------------------------------------------------------

    NIWAKA WELCOME : ADDONS

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 01/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

---------------------------------------------------------------------]]

CreateClientConVar("wscreen_loading", "0", true, false)

local matBlurScreen = Material("pp/blurscreen")

surface.CreateFont( "NiwakaWelcome", {
	font = "Roboto", 
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

do
	wscreen = {}
	wscreen.detours = {}

	wscreen.SetStatus = function(status, dots, loaded)
		wscreen.TextAlpha = 0
		wscreen.StatusText = status
		wscreen.Dots = dots and true or false
		wscreen.Loaded = (wscreen.Loaded or loaded) == true

		if loaded == true then
			if IsValid(wscreen.Panel) and not wscreen.Loading then
				wscreen.LoadSong()
				wscreen.Loading = true
			end
		end
	end
	
	wscreen.LoadSong = function()
		if wscreen.Loading then return end
		sound.PlayURL("LIEN DE VOTRE MUSIQUE", "", function(station)
			if not IsValid(station) then return end

			if !IsValid(wscreen.Panel) or IsValid(wscreen.Sound) then
				station:Stop()
				return
			end

			station:SetVolume(.3)
			wscreen.Sound = station
		end)
	end

	wscreen.WantedCamAngles = Angle(15, -40, 0) -- NE PAS TOUCHER
	wscreen.NextAngle = CurTime() + 2

	wscreen.CalcView = function(ply, pos, angles, fov)
		wscreen.CamAngles =  wscreen.WantedCamAngles + Angle(10.019955, 135.079285, 0.000000) -- Pour l'angle aussi faites 10 taper getpos et copier l'angle
		return {
			origin = Vector(1854.163208, 6359.741699, 1384.630615), -- à configurer pour obtenir le Vector Faites F10 ou la touche pour ouvrir votre console et taper getpos
			angles = wscreen.CamAngles,
			fov = fov,
			drawviewer = false,
		}
	end

	wscreen.Init = function()
		RunConsoleCommand("wscreen_loading", "1")

		wscreen.Panel = vgui.Create("DFrame")
		wscreen.Panel:Dock(FILL)
		wscreen.Panel:SetAlpha(0)
		wscreen.Panel:ShowCloseButton(false)
		wscreen.Panel:DockPadding(0, 0, 0, 0)
		wscreen.Panel:SetTitle("")
		wscreen.Panel:MakePopup()

		local cb = wscreen.Panel:Add("DButton")
		cb:Dock(FILL)
		cb:SetText("")
		cb.Paint = nil

		cb.DoClick = function(self)
			if wscreen.Loaded then
				RunConsoleCommand("wscreen_loading", "0")
				self:GetParent():Close()
			end
		end

		local w = 0
		local a = 255

		local ourMat = Material( "materials/niwaka/nwelcomescreen.png" ) -- Mettre l'endroit où se situe votre logo (Materials)

	

		wscreen.Panel.Paint = function(self, fw, fh)

			
			
			

			local sw = ScrW()
			local sh = ScrH()

			if wscreen.Loaded and ((1 / FrameTime()) > 5) then
				a = Lerp(FrameTime() * 0.2, a, 0)
			end

			if wscreen.TextAlpha then
				wscreen.TextAlpha = Lerp(FrameTime() / 2, wscreen.TextAlpha, 255)
			end
			
			local x, y = wscreen.Panel:LocalToScreen(0, 0)

			render.SetScissorRect(x, y, x + wscreen.Panel:GetWide(), y + wscreen.Panel:GetTall(), true)
				draw.RoundedBox(0, 0, 0, fw, fh, Color( 62, 90, 173, a))

					
			
					surface.SetMaterial(matBlurScreen)
					surface.SetDrawColor(215, 215, 215, 255)

					for i = 0.33, 1, 0.33 do
						matBlurScreen:SetFloat("$blur", 10 * i)
						matBlurScreen:Recompute()
						render.UpdateScreenEffectTexture()
						surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
					end		
								
					

					draw.SimpleText("Bienvenue sur NiwakaWelcomeScreen", "NiwakaWelcome", 900, 500,  Color(255, 255, 255, math.abs(math.sin(RealTime() * math.pi * 0.8)) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
					
					surface.SetMaterial( ourMat	) -- Ne pas supprimer ceci pour voir le logo de votre serveur
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawTexturedRect( 800, 200, 200, 200 )
					
			render.SetScissorRect(0, 0, 0, 0, false)	
		end


		hook.Add( "KeyPress", "keypress_use_hi", function( ply, key )
			if ( key == IN_ATTACK ) then
				if IsValid(wscreen.Sound) then
					wscreen.Sound:Stop()
				end
			end
		end )

		wscreen.Panel.Close = function(self)
			if IsValid(wscreen.Sound) then
				wscreen.Sound:Stop()
			end
			hook.Remove("CalcView", "wscreen")			
			self:Remove()
		end

		wscreen.Panel:AlphaTo(255, 2)
	
		timer.Create("wscreen-seemserror", 0.1, 1, function()
			hook.Run("Wscreen Init")
			wscreen.SetStatus("", false, true)
		end)
		hook.Add("CalcView", "wscreen", wscreen.CalcView)
	end

	wscreen.SetStatus("loading", true)

	hook.Add("Wscreen Init", "WelcomeScreen", function()
		wscreen.SetStatus("loaded", false, true)
		wscreen.StatusText = ""
		wscreen.LoadSong()
		timer.Destroy("wscreen-seemserror")

		timer.Create("wscreen-notice", 10, 1, function()
			wscreen.SetStatus("loaded", false, true)
		end)
	end)
end
timer.Simple(0, wscreen.Init)