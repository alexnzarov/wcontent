wcontent = wcontent or {}

if SERVER then
    include("wcontent/server.lua")
    AddCSLuaFile("wcontent/ui_lib.lua")
    AddCSLuaFile("wcontent/client.lua")
    AddCSLuaFile("wcontent/client_util.lua")
else
    include("wcontent/client_util.lua")
    include("wcontent/ui_lib.lua")
    include("wcontent/client.lua")
end
