---------------------------------------------------------------------
-- client_duel.lua
-- Gestion des duels 1v1 dans le Sanctuaire Tribal XXL
---------------------------------------------------------------------

local center = Config.ArenaCenter
local inDuel = false
local duelOpponent = nil
local duelSpot = nil

---------------------------------------------------------------------
-- PETIT UTIL POUR TEXTE
---------------------------------------------------------------------

local function DrawTxt(text, x, y, scale)
    SetTextScale(scale, scale)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

---------------------------------------------------------------------
-- POSITIONS DE DUEL (FACE À FACE)
---------------------------------------------------------------------

local function GetDuelSpots()
    local dist = 10.0

    local p1 = vector3(center.x - dist, center.y, center.z)
    local p2 = vector3(center.x + dist, center.y, center.z)

    return p1, p2
end

---------------------------------------------------------------------
-- CINEMATIQUE DE DEBUT DE DUEL
---------------------------------------------------------------------

local function PlayDuelCinematic()
    if not Config.DuelStartCinematic then return end

    local ped = PlayerPedId()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    local camPos = vector3(center.x, center.y - 15.0, center.z + 8.0)
    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(cam, center.x, center.y, center.z + 1.0)

    RenderScriptCams(true, true, 1500, true, false, 0)

    Citizen.Wait(Config.DuelCamTime or 4000)

    RenderScriptCams(false, true, 1500, true, false, 0)
    DestroyCam(cam, false)
end

---------------------------------------------------------------------
-- COMPTE À REBOURS
---------------------------------------------------------------------

local function StartCountdown()
    if not Config.DuelCountdown then return end

    TriggerEvent("arena:duel_start_lock") -- lock tir 3s au début

    for _, num in ipairs(Config.DuelCountdown) do
        for i = 1, 120 do
            DrawTxt("~e~" .. tostring(num) .. "~q~", 0.50, 0.45, 1.0)
            Citizen.Wait(0)
        end
    end

    -- Flash FX + petit son
    TriggerEvent("arena:fx_duel_flash")
    TriggerEvent("arena:start_ritual_sfx")
end

---------------------------------------------------------------------
-- EVENT : PREPARATION DU DUEL (SPAWN FACE À FACE)
-- appelé par le serveur avec :
-- duelData = { spot = 1 ou 2, opponent = id, isFirst = true/false }
---------------------------------------------------------------------

RegisterNetEvent("arena:duel_prepare_client")
AddEventHandler("arena:duel_prepare_client", function(duelData)
    inDuel = true
    duelOpponent = duelData.opponent
    duelSpot = duelData.spot or 1

    local ped = PlayerPedId()
    local p1, p2 = GetDuelSpots()

    if duelSpot == 1 then
        SetEntityCoords(ped, p1.x, p1.y, p1.z)
        SetEntityHeading(ped, 90.0)
    else
        SetEntityCoords(ped, p2.x, p2.y, p2.z)
        SetEntityHeading(ped, 270.0)
    end

    -- Cinématique seulement pour le premier joueur si on veut
    if duelData.isFirst then
        PlayDuelCinematic()
    end

    StartCountdown()

    TriggerEvent("vorp:TipBottom", "Le rituel du sang commence...", 4000)
end)

---------------------------------------------------------------------
-- EVENT : FIN DU DUEL (VICTOIRE / DEFAITE)
---------------------------------------------------------------------

RegisterNetEvent("arena:duel_end_client")
AddEventHandler("arena:duel_end_client", function(result)
    inDuel = false

    if result == "win" then
        TriggerEvent("vorp:TipBottom", "Les esprits te reconnaissent comme vainqueur.", 5000)
    elseif result == "lose" then
        TriggerEvent("vorp:TipBottom", "Les esprits ont jugé un autre guerrier plus fort...", 5000)
    else
        TriggerEvent("vorp:TipBottom", "Le rituel a été interrompu.", 4000)
    end
end)

---------------------------------------------------------------------
-- PROTECTION : BLOQUER LE QUIT EN PLEIN DUEL (OPTIONNEL SIMPLE)
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Citizen.Wait(0)

        if inDuel then
            -- on peut plus ouvrir la roue d'armes par ex.
            DisableControlAction(0, 0x0F39B3D4, true) -- weapon wheel
        end
    end
end)
