wcontent.list = wcontent.list or {}
wcontent._downloaded = wcontent._downloaded or {}
wcontent._cached = wcontent._cached or {}

file.CreateDir("wcontent")
file.CreateDir("wcontent/materials")

local ui = wcontent.ui 
local gradient = Material("gui/gradient.vtf")

net.Receive("wcontent_list", function()
    wcontent.list = net.ReadTable()

    if (net.ReadBool()) then
        wcontent:PerformDownload()
    end

    hook.Call("wcontent_changed")
end)

local frame
function wcontent:PerformDownload()
    if IsValid(frame) then return end

    local downloadQueue = {}
    local mountQueue = {}
    local downloaded = 0
    local mounted = 0
    local ready = true
    local mounting = false

    for k, v in ipairs(wcontent.list) do
        if wcontent._downloaded[v] then continue end

        downloadQueue[k] = v
    end

    if #downloadQueue < 1 then return end

    frame = vgui.Create("wcFrame")
    frame:SetSize(300, 55)
    frame:SetPos(ScrW() / 2 - 125, ScrH() - 60)
    frame:SetTitle("Downloading...")
    frame.CloseButton.ToClose = nil
    frame.CloseButton:SetVisible(false)
    frame.Think = function(self)
        self:SetDrawOnTop(true)

        if ready then
            ready = false

            if downloaded < #downloadQueue then
                self:DownloadNext()
            else
                mounting = true
                self:MountNext()
            end
        end
    end

    frame.DownloadNext = function(self)
        local id = downloadQueue[downloaded + 1]
        local name = id
        frame:SetTitle("Downloading " .. name .. "...")
        steamworks.FileInfo(id, function(res)
			if !res then
				downloaded = downloaded + 1
                ready = true
				
				return
			end
		
            name = res.title:Left(24)

            if IsValid(frame) then
                frame:SetTitle("Downloading " .. name .. "...")
            end
	
			wcontent._cached[id] = {title = res.title, owner = res.ownername, size = res.size, description = res.description}

            wcontent:DownloadFile(res.fileid, function(path)
                downloaded = downloaded + 1
                ready = true

                if path then
                    mountQueue[#mountQueue + 1] = {name = name, path = path, id = id}
                end
            end)
        end)
    end

    frame.MountNext = function(self)
        local d = mountQueue[mounted + 1]

        if !d then self:Remove(); return end

        frame:SetTitle("Mounting " .. d.name .. "...")
        local succ, _ = game.MountGMA(d.path)

        if !succ then
            chat.AddText(ui.Colors.Red, "Something went wrong...\nAddon \"" .. d.id .. "\" (" .. d.name .. ") wasn't mounted.")
        end

        mounted = mounted + 1
        ready = true
    end

    local progress = vgui.Create("DPanel", frame)
    progress:SetPos(5, 30)
    progress:SetSize(290, 20)
    progress.Paint = function(self, w, h)
        local fr = 0

        if mounting then
            fr = mounted == 0 && 0 || (mounted / #mountQueue)
        else
            fr = downloaded == 0 && 0 || (downloaded / #downloadQueue)
        end

        ui.DrawRect(0, 0, w * fr, h, ui.Colors.Blue)
        ui.DrawRect(0, 0, w, h, 190, 190, 190, 100)
        ui.DrawOutlinedRect(0, 0, w, h, 150, 150, 150)

        local percent = math.ceil(fr * 100)

        draw.SimpleText(percent .. "%", "mDesign_FrameTitle", w / 2, h / 2, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local frame
function wcontent:OpenPlayerMenu()
    frame = vgui.Create("wcFrame")
    frame:SetSize(460, 500)
    frame:Center()
    frame:SetTitle("Workshop Content")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(1, 26)
    scroll:SetSize(frame:GetWide() - 2, frame:GetTall() - 27)

    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(scroll:GetSize())

    for k, v in ipairs(wcontent.list) do
        local data = wcontent._cached[v]
        local size

        if !data then
            data = {title = "Loading...", owner = "unknown", size = 0, description = "Loading..."}
			
            steamworks.FileInfo(v, function(res)
				if !res then
					wcontent._cached[v] = {title = "Invalid addon (" .. v .. ")", owner = "...", size = 0, description = "..."}
				else
					wcontent._cached[v] = {title = res.title, owner = res.ownername, size = res.size || 0, description = res.description}
				end
                data = wcontent._cached[v]
                size = string.NiceSize(data.size)
            end)
        end

        size = string.NiceSize(data.size)

        local pnl = layout:Add("DButton")
        pnl:SetText("")
        pnl:SetSize(layout:GetWide(), 100)
        pnl.Paint = function(self, w, h)
            if self.Hovered then
                ui.DrawRect(0, 0, w, h, 220, 220, 220, 100)
            end
            local _, th = ui.DrawText(data.title:Left(50), "mDesign_FrameTitle", 5, 5, Color(105, 105, 105), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("by " .. data.owner, "mDesign_FrameTitle", 5, 5 + th, Color(80, 80, 80), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(size, "DermaDefault", w - 20, 5, Color(105, 105, 105), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            ui.DrawRect(0, h - 2, w, 1, 180, 180, 180)
            ui.DrawRect(0, h - 1, w, 1, color_white)
        end
        pnl.DoClick = function()
            steamworks.ViewFile(v)
        end

        local desc = vgui.Create("DLabel", pnl)
        desc:SetPos(5, 45)
        desc:SetText(data.description)
        desc.Think = function(self)
            self:SetText(data.description)
        end
        desc:SetColor(Color(130, 130, 130))
        desc:SetSize(pnl:GetWide() - 10, pnl:GetTall() - 50)
    end
end
concommand.Add("wcontent", wcontent.OpenPlayerMenu)

local frame
function wcontent:OpenAdminMenu()
    if !LocalPlayer():IsSuperAdmin() then return end
    if IsValid(frame) then return end

    frame = vgui.Create("wcFrame")
    frame:SetSize(460, 500)
    frame:Center()
    frame:SetTitle("Workshop Content")
    frame:MakePopup()

    local id = vgui.Create("DTextEntry", frame)
    id:SetPos(5, 30)
    id:SetSize(frame:GetWide() - 150, 20)
    id:SetText("Addon Link or ID...")

    local order = vgui.Create("DTextEntry", frame)
    order:SetPos(frame:GetWide() - 140, 30)
    order:SetSize(50, 20)
    order:SetNumeric(true)
    order:SetText(#wcontent.list + 1)

    local additem = vgui.Create("DButton", frame)
    additem:SetPos(frame:GetWide() - 85, 30)
    additem:SetSize(80, 20)
    additem:SetText("Add")
    additem.DoClick = function()
        local value = id:GetValue()
        local order = tonumber(order:GetValue() or "")
        if !value || value == "" || !order then return end
        local id = wcontent:IDFromString(value)

        net.Start("wcontent_add")
        net.WriteString(id)
        net.WriteFloat(math.Min(order, #wcontent.list + 1))
        net.SendToServer()
    end

    local list = vgui.Create("DListView", frame)
    list:SetPos(5, 55)
    list:SetSize(frame:GetWide() - 10, frame:GetTall() - 60)
    list:AddColumn("Order")
    list:AddColumn("ID")
    list.DoDoubleClick = function(self, _, line)
        local m = DermaMenu()
        local remove = m:AddOption("Remove")
        remove:SetIcon("icon16/cross.png")
        remove.DoClick = function()
            net.Start("wcontent_remove")
            net.WriteString(line:GetValue(2))
            net.SendToServer()
        end
        m:Open()
    end

    list.Load = function(self)
        self:Clear()

        for k, id in SortedPairs(wcontent.list) do
            self:AddLine(k, id)
        end
    end

    list:Load()

    hook.Add("wcontent_changed", "update_frame", function()
        if !IsValid(frame) then return end

        list:Load()
        order:SetText(#wcontent.list + 1)
    end)
end

concommand.Add("wcontent_admin", wcontent.OpenAdminMenu)
