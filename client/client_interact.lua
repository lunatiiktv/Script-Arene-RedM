---------------------------------------------------------------------
-- client_interact.lua
-- Interactions joueur : entrée arène, entrée du mode duel, commandes
---------------------------------------------------------------------

local inArena = false

local arenaEntry = Config.Entrance
local duelEntry  = Config.DuelEntrance
local interactDist = 2.0

---------------------------------------------------------------------
-- DRAW 3D TEXT
---------------------------------------------------------------------

local function Draw3DText(coords, text)
    local onScreen,_x,_y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(0.40, 0.40)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 255, 255, 255)
        SetTextCentre(true)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
    end
end

---------------------------------------------------------------------
-- INTERACTION : ENTREE ARÈNE LIBRE (FREE-FOR-ALL)
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local dist = #(coords - arenaEntry)

        if dist < 6.0 then
            Draw3DText(arenaEntry + vector3(0,0,0.25), "~e~Arène de Tir Tribale~q~")

            if dist < interactDist then
                Draw3DText(arenaEntry + vector3(0,0,-0.05), "Appuyez sur ~e~E~q~ pour entrer")

                if IsControlJustPressed(0, 0xCEFD9220) then
                    TriggerServerEvent("arena:enterArenaServer")
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- INTERACTION : ENTRÉE DU MODE DUEL
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local dist = #(coords - duelEntry)

        if dist < 6.0 then
            Draw3DText(duelEntry + vector3(0,0,0.25), "~o~Duel Sacré 1v1~q~")

            if dist < interactDist then
                Draw3DText(duelEntry + vector3(0,0,-0.05), "Appuyez sur ~e~E~q~ pour défier")

                if IsControlJustPressed(0, 0xCEFD9220) then
                    TriggerServerEvent("arena:queue_duel")
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- COMMANDES : DUEL / QUIT
---------------------------------------------------------------------

RegisterCommand("duel", function()
    TriggerServerEvent("arena:queue_duel")
end)

RegisterCommand("quitduel", function()
    TriggerEvent("vorp:TipBottom", "Tu quittes la voie du duel.", 3000)
    TriggerServerEvent("arena:exitArena")
end)

---------------------------------------------------------------------
-- PROTECTION : BLOQUER SORTIE DE LA ZONE DURANT DUEL
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(500)
        if not Config.AntiLeaveDuringDuel then goto continue end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if #(coords - Config.ArenaCenter) > Config.ArenaMaxDistance then
            TriggerServerEvent("arena:duel_outside")
        end

        ::continue::
    end
end)
