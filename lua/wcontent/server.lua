wcontent.list = wcontent.list or {}

util.AddNetworkString("wcontent_list")
util.AddNetworkString("wcontent_add")
util.AddNetworkString("wcontent_remove")

file.CreateDir("wcontent")

function wcontent:TableToString(tbl)
    return string.Implode("\n", tbl)
end

function wcontent:StringToTable(str)
    return string.Explode("\n", str)
end

function wcontent:SaveList()
    file.Write("wcontent/list.dat", wcontent:TableToString(wcontent.list))
    wcontent:Network()
end

function wcontent:LoadList()
    wcontent.list = wcontent:StringToTable(file.Read("wcontent/list.dat", "DATA") || "")
end

wcontent:LoadList()

function wcontent:Network(ply, first)
    net.Start("wcontent_list")
    net.WriteTable(wcontent.list)
    net.WriteBool(first == true)
    if ply then net.Send(ply)
    else net.Broadcast() end
end

function wcontent:AddItem(id, position)
    if table.HasValue(wcontent.list, id) then
        table.RemoveByValue(wcontent.list, id)
    end

    table.insert(wcontent.list, position, id)

    wcontent:SaveList()
end

function wcontent:RemoveItem(id)
    table.RemoveByValue(wcontent.list, id)

    wcontent:SaveList()
end

hook.Add("PlayerSay", "wcontent", function(ply, str)
    if str:match("^[/!]wcontent") then
        ply:ConCommand("wcontent")
        return ""
    end
end)

net.Receive("wcontent_add", function(_, ply)
    if !ply:IsSuperAdmin() then return end

    wcontent:AddItem(net.ReadString(), net.ReadFloat())
end)

net.Receive("wcontent_remove", function(_, ply)
    if !ply:IsSuperAdmin() then return end

    wcontent:RemoveItem(net.ReadString())
end)

hook.Add("PlayerInitialSpawn", "wcontent_send", function(ply)
    wcontent:Network(ply, true)
end)
