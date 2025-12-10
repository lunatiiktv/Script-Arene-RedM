local inArena = false
local spawnedObjects = {}
local spawnedEffects = {}
local npcReferee = nil
local musicSoundId = nil
local drumSoundId = nil

-------------------------------------------------------
--  DESSIN TEXTE HUD
-------------------------------------------------------

function DrawTxt(text, x, y, scale)
    SetTextScale(scale, scale)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

-------------------------------------------------------
--  ENTRÉE / SORTIE ARENE
-------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Entrée
        if #(coords - Config.Entrance) < Config.EntranceRadius then
            DrawTxt("Appuyez sur ~e~E~q~ pour entrer dans l’arène tribale", 0.50, 0.90, 0.7)

            if IsControlJustPressed(0, 0xCEFD9220) then
                TriggerServerEvent("arena:enter")
            end
        end

        -- Anti-fuite si dans l'arène
        if inArena and #(coords - Config.Arena) > 60.0 then
            SetEntityCoords(ped, Config.Arena.x, Config.Arena.y, Config.Arena.z)
            DrawTxt("Les esprits te ramènent dans le cercle sacré…", 0.50, 0.85, 0.6)
        end
    end
end)

-------------------------------------------------------
--  TELEPORT ENTRE / SORTIE
-------------------------------------------------------

RegisterNetEvent("arena:enterArena")
AddEventHandler("arena:enterArena", function()
    inArena = true
    local ped = PlayerPedId()

    SetEntityCoords(ped, Config.Arena)
    SetEntityHeading(ped, Config.ArenaHeading)

    -- Message RP
    Citizen.CreateThread(function()
        for i = 1, 180 do
            DrawTxt("~e~Les esprits t’observent… Que ton tir soit juste.", 0.50, 0.85, 0.6)
            Citizen.Wait(0)
        end
    end)

    StartRitualMusic()
    StartDrumLoop()
end)

RegisterNetEvent("arena:exitArena")
AddEventHandler("arena:exitArena", function()
    inArena = false
    local ped = PlayerPedId()

    StopRitualMusic()
    StopDrumLoop()

    SetEntityCoords(ped, Config.Exit)
end)

-------------------------------------------------------
--  MORT RP DANS L’ARENE
-------------------------------------------------------

RegisterNetEvent("arena:deathEffect")
AddEventHandler("arena:deathEffect", function()

    local ped = PlayerPedId()

    -- Animation rituelle
    RequestAnimDict("mech_loco_m@character@kneel@male_a@idle")
    while not HasAnimDictLoaded("mech_loco_m@character@kneel@male_a@idle") do
        Citizen.Wait(10)
    end

    TaskPlayAnim(ped, "mech_loco_m@character@kneel@male_a@idle", "idle", 8.0, -8.0, Config.RPMortTimer, 1, 0, false, 0, false)

    -- Effet visuel sombre
    Citizen.Wait(250)
    AnimpostfxPlay("DeathFailMP01", 5000, true)
end)

-------------------------------------------------------
--  SPAWN PROPS / EFFETS (FEU + FUMÉE)
-------------------------------------------------------

function SpawnArenaObjects()
    for _, prop in ipairs(Props) do

        local model = GetHashKey(prop.model)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end

        local obj = CreateObject(model, prop.coords.x, prop.coords.y, prop.coords.z, false, true, false)
        SetEntityHeading(obj, prop.heading)
        FreezeEntityPosition(obj, true)
        table.insert(spawnedObjects, obj)

        -- Torches : feu FX
        if prop.isTorch then
            UseParticleFxAssetNextCall("core")
            local fx = StartParticleFxLoopedOnEntity(
                "ent_amb_campfire_fire_small", 
                obj, 
                0.0, 0.0, 1.2, 
                0.0, 0.0, 0.0, 
                1.8, false, false, false
            )
            table.insert(spawnedEffects, fx)
        end

        -- Totem : fumée FX
        if prop.isTotem then
            UseParticleFxAssetNextCall("core")
            local fx = StartParticleFxLoopedOnEntity(
                "ent_amb_smolder_spread",
                obj,
                0.0, 0.0, 2.5,
                0.0, 0.0, 0.0,
                0.6, false, false, false
            )
            table.insert(spawnedEffects, fx)
        end

    end
end

-------------------------------------------------------
--  NPC SHAMAN / ANIMATION
-------------------------------------------------------

function SpawnReferee()
    local model = GetHashKey(Config.Referee.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end

    npcReferee = CreatePed(model, Config.Referee.coords, Config.Referee.heading, false, true)

    FreezeEntityPosition(npcReferee, true)
    SetEntityInvincible(npcReferee, true)

    -- Animation
    RequestAnimDict(Config.Referee.animDict)
    while not HasAnimDictLoaded(Config.Referee.animDict) do Citizen.Wait(10) end

    TaskPlayAnim(
        npcReferee,
        Config.Referee.animDict,
        Config.Referee.animName,
        8.0, -8.0,
        -1,
        1,
        0.0,
        false,
        0,
        false
    )
end

-------------------------------------------------------
--  MUSIQUE RITUELLE
-------------------------------------------------------

function StartRitualMusic()
    if not Config.EnableRitualMusic then return end

    if musicSoundId then StopRitualMusic() end
    musicSoundId = GetSoundId()

    PlaySoundFrontend(musicSoundId, "RITUAL_MUSIC", "RITUALSET", true)
    SetVariableOnSound(musicSoundId, "volume", Config.MusicVolume)
end

function StopRitualMusic()
    if musicSoundId then
        StopSound(musicSoundId)
        ReleaseSoundId(musicSoundId)
        musicSoundId = nil
    end
end

-------------------------------------------------------
--  BOUCLE TAMBOURS
-------------------------------------------------------

function StartDrumLoop()
    if not Config.EnableDrumLoop then return end

    if drumSoundId then StopDrumLoop() end
    drumSoundId = GetSoundId()

    PlaySoundFrontend(drumSoundId, "DRUM_LOOP", "HUD_SHOP_SOUNDSET", true)
    SetVariableOnSound(drumSoundId, "volume", Config.DrumVolume)
end

function StopDrumLoop()
    if drumSoundId then
        StopSound(drumSoundId)
        ReleaseSoundId(drumSoundId)
        drumSoundId = nil
    end
end

-------------------------------------------------------
--  RELOAD ADMIN
-------------------------------------------------------

RegisterNetEvent("arena:reload")
AddEventHandler("arena:reload", function()

    -- Delete props
    for _, obj in ipairs(spawnedObjects) do
        DeleteObject(obj)
    end
    spawnedObjects = {}

    -- Stop FX
    for _, fx in ipairs(spawnedEffects) do
        StopParticleFxLooped(fx, false)
    end
    spawnedEffects = {}

    -- Remove NPC
    if npcReferee then DeletePed(npcReferee) end
    npcReferee = nil

    -- Respawn
    SpawnArenaObjects()
    SpawnReferee()

end)

-------------------------------------------------------
--  BLIP ARENE
-------------------------------------------------------

Citizen.CreateThread(function()
    Citizen.Wait(2000)

    local blip = N_0x554d9d53f696d002(587827268)

    SetBlipSprite(blip, 587827268, true)
    SetBlipScale(blip, 0.25)
    SetBlipCoords(blip, Config.Arena)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Arène d’Entraînement")
end)

-------------------------------------------------------
--  SPAWN AUTOMATIQUE AU LANCEMENT
-------------------------------------------------------

Citizen.CreateThread(function()
    SpawnArenaObjects()
    SpawnReferee()
    print("[ARENE TRIBALE] Client chargé ✔")
end)
