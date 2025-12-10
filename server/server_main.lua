---------------------------------------------------------------------
-- server_main.lua
-- Logique centrale du Sanctuaire Tribal XXL Premium
---------------------------------------------------------------------

local VorpCore = exports.vorp_core:GetCore()
local json = require("json")

local savedInventories = {}
local scores = {}

---------------------------------------------------------------------
-- CHARGEMENT SCORES JSON
---------------------------------------------------------------------

local function LoadScores()
    local raw = LoadResourceFile(GetCurrentResourceName(), Config.ScoreFile)

    if raw then
        scores = json.decode(raw) or {}
    else
        scores = {}
    end
end

local function SaveScores()
    SaveResourceFile(GetCurrentResourceName(), Config.ScoreFile, json.encode(scores), -1)
end

LoadScores()

---------------------------------------------------------------------
-- INVENTAIRE : SAUVEGARDE & RESTAURATION
---------------------------------------------------------------------

local function SavePlayerInventory(src)
    local User = VorpCore.getUser(src)
    local char = User.getUsedCharacter()

    savedInventories[src] = char.getWeapons()
end

local function RestorePlayerInventory(src)
    if not savedInventories[src] then return end

    local User = VorpCore.getUser(src)
    local char = User.getUsedCharacter()

    -- Clear avant restore
    char.clearWeapons()

    for _, weapon in pairs(savedInventories[src]) do
        char.giveWeapon(weapon.name, weapon.ammo)
    end

    savedInventories[src] = nil
end

---------------------------------------------------------------------
-- DON D’ARMES SACRÉES
---------------------------------------------------------------------

RegisterServerEvent("arena:give_sacred_weapons")
AddEventHandler("arena:give_sacred_weapons", function()
    local src = source
    local User = VorpCore.getUser(src)
    local char = User.getUsedCharacter()

    char.clearWeapons()

    for _, w in ipairs(Config.AllowedWeapons) do
        char.giveWeapon(w, 20)
    end

    TriggerClientEvent("vorp:TipBottom", src, "Les esprits t’accordent les armes du rituel.", 3000)
end)

---------------------------------------------------------------------
-- ENTREE DANS L’ARENE
---------------------------------------------------------------------

RegisterServerEvent("arena:enterArenaServer")
AddEventHandler("arena:enterArenaServer", function()
    local src = source
    local User = VorpCore.getUser(src)
    local char = User.getUsedCharacter()

    SavePlayerInventory(src)

    -- Heal 
    char.setHealth(200)

    TriggerClientEvent("arena:enterArenaClient", src)
end)

---------------------------------------------------------------------
-- SORTIE DE L’ARENE
---------------------------------------------------------------------

RegisterServerEvent("arena:exitArena")
AddEventHandler("arena:exitArena", function()
    local src = source

    if Config.RestoreWeaponsOnExit then
        RestorePlayerInventory(src)
    end

    TriggerClientEvent("arena:exitArenaClient", src)
end)

---------------------------------------------------------------------
-- MORT DANS L’ARENE (KILL SYSTEM)
---------------------------------------------------------------------

RegisterServerEvent("arena:playerDied")
AddEventHandler("arena:playerDied", function(dead, killer)
    local d = tonumber(dead)
    local k = tonumber(killer)

    if k and GetPlayerName(k) then
        if not scores[k] then
            scores[k] = {kills = 0, wins = 0}
        end

        scores[k].kills = scores[k].kills + 1
        SaveScores()

        local UserK = VorpCore.getUser(k)
        local charK = UserK.getUsedCharacter()
        charK.addCurrency(0, Config.RewardKill)

        TriggerClientEvent("vorp:TipBottom", k, "+1 kill (rituel sacré)", 3000)
        TriggerClientEvent("vorp:TipBottom", d, "Les esprits t’ont vaincu…", 3000)
    end

    -- TP après délai rituel
    Citizen.SetTimeout(4500, function()
        TriggerClientEvent("arena:exitArenaClient", d)
    end)
end)

---------------------------------------------------------------------
-- COMMANDE SCOREBOARD
---------------------------------------------------------------------

RegisterCommand("duelstats", function(src)
    local msg = "🏹 ~e~Classement Tribal XXL~q~ :\n\n"

    for id, data in pairs(scores) do
        msg = msg .. string.format("~o~%s~q~ → %d kills | %d victoires\n",
            GetPlayerName(id) or ("Joueur " .. id),
            data.kills or 0,
            data.wins or 0
        )
    end

    TriggerClientEvent("chat:addMessage", src, { args = { "^3SACRED ARENA", msg } })
end)

---------------------------------------------------------------------
-- ADMIN : RELOAD
---------------------------------------------------------------------

RegisterCommand("reloadarena", function(src)
    local isConsole = (src == 0)

    if not isConsole then
        local User = VorpCore.getUser(src)
        if User.getGroup() ~= "admin" and User.getGroup() ~= "god" then
            TriggerClientEvent("vorp:TipBottom", src, "Tu n’as pas la bénédiction.", 3000)
            return
        end
    end

    TriggerClientEvent("arena:stop_all_sfx", -1)
    TriggerClientEvent("arena:stop_fx", -1)
    Citizen.Wait(500)
    TriggerClientEvent("arena:reload_client", -1)

    print("[SACRED ARENA] Reload complet envoyé.")
end)
