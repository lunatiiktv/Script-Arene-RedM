---------------------------------------------------------------------
-- client_fx.lua : Effets visuels sacrés (TOTEM / cercle / duel)
---------------------------------------------------------------------

local center = Config.ArenaCenter
local activeFX = {}

---------------------------------------------------------------------
-- PARTICULES UTILISÉES
---------------------------------------------------------------------

local PARTICLES = {
    totem_smoke = { dict = "core", fx = "ent_amb_smolder_spread" },
    totem_spirits = { dict = "core", fx = "ent_amb_campfire_smoke" },
    dust_red = { dict = "core", fx = "ent_dst_sandstorm_spawn" },
    circle_flash = { dict = "core", fx = "ent_amb_campfire_fire_small" }
}

---------------------------------------------------------------------
-- CHARGEMENT PARTICULES
---------------------------------------------------------------------

local function LoadPtfx(dict)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(10)
    end
    UseParticleFxAsset(dict)
end

---------------------------------------------------------------------
-- FX : TOTEM GEANT
---------------------------------------------------------------------

local function StartTotemFX()
    -- Fumée sacrée
    LoadPtfx(PARTICLES.totem_smoke.dict)
    local fx1 = StartParticleFxLoopedAtCoord(PARTICLES.totem_smoke.fx,
        center.x, center.y, center.z + 6.5, 0.0, 0.0, 0.0, 2.8, false, false, false)
    table.insert(activeFX, fx1)

    -- Esprits qui montent
    LoadPtfx(PARTICLES.totem_spirits.dict)
    local fx2 = StartParticleFxLoopedAtCoord(PARTICLES.totem_spirits.fx,
        center.x, center.y, center.z + 7.0, 0.0, 0.0, 0.0, 1.6, false, false, false)
    table.insert(activeFX, fx2)
end

---------------------------------------------------------------------
-- FX : POUSSIÈRE ROUGE DU CERCLE
---------------------------------------------------------------------

local function StartDustCircle()
    LoadPtfx(PARTICLES.dust_red.dict)

    for i = 1, 16 do
        local angle = (i / 16) * math.pi * 2
        local x = center.x + math.cos(angle) * Config.ArenaRadius
        local y = center.y + math.sin(angle) * Config.ArenaRadius

        local fx = StartParticleFxLoopedAtCoord(PARTICLES.dust_red.fx,
            x, y, center.z + 0.3, 0.0, 0.0, angle, 0.6, false, false, false)

        table.insert(activeFX, fx)
    end
end

---------------------------------------------------------------------
-- FX : FLASH DUEL
---------------------------------------------------------------------

RegisterNetEvent("arena:fx_duel_flash")
AddEventHandler("arena:fx_duel_flash", function()
    LoadPtfx(PARTICLES.circle_flash.dict)

    local fx = StartParticleFxNonLoopedAtCoord(
        PARTICLES.circle_flash.fx,
        center.x, center.y, center.z + 1.0,
        0.0, 0.0, 0.0,
        3.0
    )
end)

---------------------------------------------------------------------
-- ARRÊT FX
---------------------------------------------------------------------

RegisterNetEvent("arena:stop_fx")
AddEventHandler("arena:stop_fx", function()
    for _, fx in ipairs(activeFX) do
        StopParticleFxLooped(fx, false)
    end
    activeFX = {}
end)

---------------------------------------------------------------------
-- BOUCLE DE CHARGEMENT DES FX LORS DE L’ARRIVÉE
---------------------------------------------------------------------

CreateThread(function()
    Wait(3000)

    StartTotemFX()
    StartDustCircle()

    print("[ARENA XXL] FX actifs.")
end)
