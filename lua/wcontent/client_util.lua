
function wcontent:DownloadFile(id, callback)
    steamworks.Download(id, true, function(path)
        callback(path)
    end)
end

function wcontent:GetInfo(id, callback)
    steamworks.FileInfo(id, callback)
end

function wcontent:DownloadMaterial(key, url, callback)
    local crc = util.CRC(key)

    if file.Exists("wcontent/materials/" .. crc .. ".png", "DATA") then
        callback(Material("../data/wcontent/materials/" .. crc .. ".png"))
        return
    end

    http.Fetch(url, function(body)
        file.Write("wcontent/materials/" .. crc .. ".png", body)
        callback(Material("../data/wcontent/materials/" .. crc .. ".png"))
    end)
end

function wcontent:IDFromString(str)
    local m = str:match(".+%?id=(.+)")

    if m then return m end
    return str
end
