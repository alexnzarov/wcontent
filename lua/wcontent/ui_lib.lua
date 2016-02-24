// part from my vgui framework called "mDesign"

surface.CreateFont("mDesign_FrameTitle", {font = "Roboto", size = 18})

local SetColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial

local DrawRect = surface.DrawRect
local DrawOutlinedRect = surface.DrawOutlinedRect
local DrawTexturedRect = surface.DrawTexturedRect
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local GetTextSize = surface.GetTextSize
local SetFont = surface.SetFont

local DrawText = draw.SimpleText

local ui = {}

ui.Colors = {
	["Blue"] = Color(33, 150, 243),
	["Orange"] = Color(255, 152, 0),
	["Green"] = Color(76, 175, 80),
	["LightGreen"] = Color(139, 195, 74),
	["DeepOrange"] = Color(255, 87, 34),
	["Red"] = Color(244, 67, 54),
	["Indigo"] = Color(63, 81, 181)
}

ui.DrawRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawRect(x, y, w, h)
end

ui.DrawOutlinedRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawOutlinedRect(x, y, w, h)
end

ui.DrawTexturedRect = function(x, y, w, h, material, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRect(x, y, w, h)
end

ui.DrawTexturedRectRotated = function(x, y, w, h, material, rotation, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRectRotated(x, y, w, h, rotation)
end

ui.DrawText = function(text, font, x, y, color, align_x, align_y)
    local w, h = DrawText(text, font, x, y, color, align_x, align_y)

    if !w || !h then
        SetFont(font)
        w, h = GetTextSize(text)
    end

    return w, h
end

wcontent.ui = ui

local PANEL = {}

PANEL.Angle = 0

local bmat

wcontent:DownloadMaterial("close_btn", "http://i.imgur.com/yS0oGhO.png", function(mat)
    bmat = mat
end)

function PANEL:Init()
    self.Anim = Derma_Anim("ButtonRotate", self, function(pnl, anim, delta, data)
    	if pnl.AngleAnotherWay then
    		pnl.Angle = 180 * delta
    	else
    		pnl.Angle = -180 * delta
        end
	end)

    self:SetSize(24, 24)
    self:SetText("")
end

function PANEL:DoClick()
    if self.ToClose then
        self.ToClose:Close()
    end
end

function PANEL:Paint(w, h)
    if !bmat then return end

    ui.DrawTexturedRectRotated(w / 2, h / 2, w, h, bmat, self.Angle)
end

function PANEL:OnCursorEntered()
    if self.Anim:Active() then self.Anim:Stop() end
    self.Anim:Start(0.4)
    self.AngleAnotherWay = false
end

function PANEL:OnCursorExited()
    if self.Anim:Active() then self.Anim:Stop() end
    self.Anim:Start(0.4)
    self.AngleAnotherWay = true
end

function PANEL:Think()
    if self.Anim and self.Anim:Active() then
        self.Anim:Run()
    end
end

vgui.Register("wcCloseButton", PANEL, "DButton")

local PANEL = {}

local gradient = Material("gui/gradient.vtf")

surface.CreateFont("mDesign_FrameTitle", {font = "Roboto", size = 18})

function PANEL:Init()
    self.CloseButton = vgui.Create("wcCloseButton", self)
    self.CloseButton:SetSize(24, 24)
    self.CloseButton.ToClose = self

    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()
    self.lblTitle:Remove()

	self.clrHeader = ui.Colors.Blue
end

function PANEL:SetTitle(str)
    self.strTitle = str
end

function PANEL:GetTitle(str)
    return self.strTitle or "Frame"
end

function PANEL:DrawBig(bool)
    self.bDrawBig = bool
    self:PerformLayout()
end

function PANEL:IsBig()
    return self.bDrawBig == true
end

function PANEL:SetHeaderColor(clr)
	self.clrHeader = clr
end

function PANEL:Paint(w, h)
    ui.DrawRect(0, 25, w, h - 25, 245, 245, 245)
    ui.DrawRect(0, 0, w, 25, self.clrHeader)
    ui.DrawOutlinedRect(0, 25, w, h - 25, 205, 205, 205, 250)

    ui.DrawTexturedRect(0, 26, w / 4, h - 26, gradient, 0, 0, 0, 40)
    ui.DrawTexturedRectRotated(w - (w / 4), h / 2 + 13, w / 2, h - 26, gradient, 180, 0, 0, 0, 40)

    ui.DrawText(self:GetTitle(), "mDesign_FrameTitle", 6, 13, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    ui.DrawText(self:GetTitle(), "mDesign_FrameTitle", 5, 12, Color(250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if (self.m_bBackgroundBlur) then
        Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
    end
end

function PANEL:PerformLayout()
    if self.bDrawBig then
        self.CloseButton:SetPos(self:GetWide() - 29, 5)
    else
        self.CloseButton:SetPos(self:GetWide() - 25, 1)
    end
end

function PANEL:ShowCloseButton(bool)
    self.CloseButton:SetVisible(bool)
end

vgui.Register("wcFrame", PANEL, "DFrame")
