---------------------------------------------------------------------
-- client_guardian.lua
-- Anti-cheat Tribal & Sécurité du Sanctuaire XXL
---------------------------------------------------------------------

local inArena = false
local allowed = {}

---------------------------------------------------------------------
-- CHARGEMENT DES ARMES AUTORISÉES
---------------------------------------------------------------------

CreateThread(function()
    for _, weapon in ipairs(Config.AllowedWeapons) do
        allowed[GetHashKey(weapon)] = true
    end
end)

---------------------------------------------------------------------
-- DETECTION DES ARMES INTERDITES
---------------------------------------------------------------------

local function RemoveForbiddenWeapons()
    local ped = PlayerPedId()

    for _, weapon in ipairs(GetAllWeapons()) do
        local hash = GetHashKey(weapon)
        if HasPedGotWeapon(ped, hash, false) then
            if not allowed[hash] then
                RemoveWeaponFromPed(ped, hash)
            end
        end
    end
end

---------------------------------------------------------------------
-- LOOP : ANTI-CHEAT / ARME INTERDITE
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Citizen.Wait(800)

        if not inArena then goto continue end

        -- Retire toutes les armes non autorisées
        if Config.BlockForbiddenWeapons then
            RemoveForbiddenWeapons()
        end

        -- empêche explosifs
        DisableControlAction(0, 0x7F8D09B8, true)   -- dynamite
        DisableControlAction(0, 0x9C8A94E1, true)   -- throwing dynamite
        DisableControlAction(0, 0xB2F377E8, true)   -- volatile

        ::continue::
    end
end)

---------------------------------------------------------------------
-- EVENT : LE JOUEUR ENTRE DANS L’ARENE
---------------------------------------------------------------------

RegisterNetEvent("arena:enterArenaClient")
AddEventHandler("arena:enterArenaClient", function()
    inArena = true

    if Config.GiveWeaponsOnEnter then
        TriggerServerEvent("arena:give_sacred_weapons")
    end
end)

---------------------------------------------------------------------
-- EVENT : SORTIE DE L’ARENE
---------------------------------------------------------------------

RegisterNetEvent("arena:exitArenaClient")
AddEventHandler("arena:exitArenaClient", function()
    inArena = false

    if Config.RestoreWeaponsOnExit then
        TriggerServerEvent("arena:return_original_weapons")
    end
end)

---------------------------------------------------------------------
-- INTERDICTION DES PROJECTILES NON TRIBAUX
---------------------------------------------------------------------

CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not inArena then goto continue end

        -- désactive molotov, dynamite, bouteille, etc
        DisableControlAction(0, 0x73A8FD5B, true)
        DisableControlAction(0, 0x96C61FDF, true)
        DisableControlAction(0, 0x3B24C470, true)

        ::continue::
    end
end)

---------------------------------------------------------------------
-- SECURISATION DU DUEL
---------------------------------------------------------------------

RegisterNetEvent("arena:duel_start_lock")
AddEventHandler("arena:duel_start_lock", function()
    local ped = PlayerPedId()
    DisablePlayerFiring(ped, true)
    Citizen.Wait(3000)
    DisablePlayerFiring(ped, false)
end)

---------------------------------------------------------------------
-- OUTILS
---------------------------------------------------------------------

function GetAllWeapons()
    return {
        "WEAPON_BOW",
        "WEAPON_LASSO",
        "WEAPON_MELEE_KNIFE",
        "WEAPON_THROWN_TOMAHAWK",
        "WEAPON_THROWN_DYNAMITE",
        "WEAPON_THROWN_BOLAS",
        "WEAPON_THROWN_POISONBOTTLE",
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_LANCASTER",
        "WEAPON_RIFLE_VARMINT",
        "WEAPON_SHOTGUN_REPEATING",
        "WEAPON_REPEATER_HENRY"
    }
end
