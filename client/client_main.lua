local inArena = false
local spawnedProps = {}
local spawnedFX = {}
local chamanPed = nil

-------------------------------------------------------
-- UTILS
-------------------------------------------------------

local function DrawTxt(text, x, y, scale)
    SetTextScale(scale, scale)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

-------------------------------------------------------
-- SPAWN OBJETS / PROPS
-------------------------------------------------------

local function SpawnProp(prop)
    local modelHash = GetHashKey(prop.model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end

    local obj = CreateObject(modelHash, prop.coords.x, prop.coords.y, prop.coords.z, false, true, false)
    SetEntityHeading(obj, prop.heading or 0.0)

    if prop.scale then
        SetEntityScale(obj, prop.scale, 0) 
    end

    FreezeEntityPosition(obj, true)

    return obj
end

local function SpawnAllProps()
    for _, prop in ipairs(Props) do
        local obj = SpawnProp(prop)
        table.insert(spawnedProps, obj)

        -- FX Feu (Brasier)
        if prop.isBrazier then
            UseParticleFxAssetNextCall("core")
            local fx = StartParticleFxLoopedOnEntity("ent_amb_campfire_fire_large", obj, 0.0, 0.0, 1.2, 0.0, 0.0, 0.0, 2.5, false, false, false)
            table.insert(spawnedFX, fx)
        end

        -- FX Torches
        if prop.isTorch then
            UseParticleFxAssetNextCall("core")
            local fx = StartParticleFxLoopedOnEntity("ent_amb_campfire_fire_small", obj, 0, 0, 1.15, 0, 0, 0, 1.2, false, false, false)
            table.insert(spawnedFX, fx)
        end
    end
end

-------------------------------------------------------
-- SPAWN CHAMAN
-------------------------------------------------------

local function SpawnChaman()
    local model = GetHashKey(Config.Chaman.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end

    chamanPed = CreatePed(model, Config.Chaman.coords.x, Config.Chaman.coords.y, Config.Chaman.coords.z,
        Config.Chaman.heading, false, true)

    FreezeEntityPosition(chamanPed, true)
    SetEntityInvincible(chamanPed, true)
    SetBlockingOfNonTemporaryEvents(chamanPed, true)

    RequestAnimDict(Config.Chaman.animDict)
    while not HasAnimDictLoaded(Config.Chaman.animDict) do Citizen.Wait(10) end

    TaskPlayAnim(chamanPed, Config.Chaman.animDict, Config.Chaman.animName, 8.0, -8.0, -1, 1, 0.0, false, 0, false)
end

-------------------------------------------------------
-- CERCLE PEINT AU SOL (XXL)
-------------------------------------------------------

local function DrawCircle()
    if not Config.PaintCircle then return end
    
    local center = Config.ArenaCenter
    local radius = Config.ArenaRadius
    local c = Config.PaintColor

    DrawCircle(center.x, center.y, radius, c.r, c.g, c.b, c.a)
end

-------------------------------------------------------
-- ANTI-FUITE
-------------------------------------------------------

local function AntiEscapeLoop()
    while true do
        Citizen.Wait(500)

        if not inArena then goto continue end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.ArenaCenter)

        if dist > Config.EscapeReturnDistance then
            SetEntityCoords(ped, Config.ArenaCenter.x, Config.ArenaCenter.y, Config.ArenaCenter.z)
            TriggerEvent("vorp:TipBottom", "Les esprits te ramènent dans le cercle sacré…", 3000)
        end

        ::continue::
    end
end
CreateThread(AntiEscapeLoop)

-------------------------------------------------------
-- SON D'AMBIANCE DYNAMIQUE (DISTANCE)
-------------------------------------------------------

local function UpdateAmbientSounds()
    while true do
        Citizen.Wait(1000)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.ArenaCenter)

        -- Au loin : vent + chants
        if dist < Config.SoundDistanceOuter and dist >= Config.SoundDistanceMid then
            TriggerEvent("arena:play_whispers_far")

        -- Moyen : tambours + murmures
        elseif dist < Config.SoundDistanceMid and dist >= Config.SoundDistanceInner then
            TriggerEvent("arena:play_mid_ambience")

        -- Proche : esprits + grosse ambiance
        elseif dist < Config.SoundDistanceInner and dist >= Config.SoundDistanceCore then
            TriggerEvent("arena:play_strong_spirits")

        -- Dans le cercle central : musique rituelle complète
        elseif dist < Config.SoundDistanceCore then
            TriggerEvent("arena:play_ritual_full")
        end
    end
end
CreateThread(UpdateAmbientSounds)

-------------------------------------------------------
-- GESTION ENTRÉE / SORTIE
-------------------------------------------------------

CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Entrance)

        if dist < Config.EntranceRadius then
            DrawTxt("~e~E~q~ • Entrer dans le Sanctuaire Tribal", 0.5, 0.88, 0.7)

            if IsControlJustPressed(0, 0xCEFD9220) then
                TriggerServerEvent("arena:enterArenaServer")
            end
        end
    end
end)

RegisterNetEvent("arena:enterArenaClient")
AddEventHandler("arena:enterArenaClient", function()
    inArena = true

    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.ArenaCenter.x, Config.ArenaCenter.y, Config.ArenaCenter.z)
    SetEntityHeading(ped, Config.ArenaHeading)

    TriggerEvent("arena:start_ritual_sfx")
end)

RegisterNetEvent("arena:exitArenaClient")
AddEventHandler("arena:exitArenaClient", function()
    inArena = false

    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.Exit.x, Config.Exit.y, Config.Exit.z)

    TriggerEvent("arena:stop_all_sfx")
end)

-------------------------------------------------------
-- CHARGEMENT DES PROPS + CHAMAN AU DÉMARRAGE
-------------------------------------------------------

CreateThread(function()
    Wait(2000)
    SpawnAllProps()
    SpawnChaman()
    print("[ARENE XXL] Props & Chaman chargés.")
end)
