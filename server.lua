local VorpCore = exports.vorp_core:GetCore()

local scores = {}
local bets = {} -- paris actifs : bets[playerID] = {target, amount}

-------------------------------------------------------
-- CHARGEMENT / SAUVEGARDE SCORES
-------------------------------------------------------

local function loadScores()
    local file = LoadResourceFile(GetCurrentResourceName(), Config.ScoreFile)
    if file and file ~= "" then
        scores = json.decode(file) or {}
    else
        scores = {}
    end
end

local function saveScores()
    SaveResourceFile(GetCurrentResourceName(), Config.ScoreFile, json.encode(scores), -1)
end

loadScores()

-------------------------------------------------------
-- AJOUT SCORE / KILL / WIN
-------------------------------------------------------

local function addKill(killer)
    if not scores[killer] then scores[killer] = {kills = 0, wins = 0} end
    scores[killer].kills = scores[killer].kills + 1
    saveScores()
end

local function addWin(winner)
    if not scores[winner] then scores[winner] = {kills = 0, wins = 0} end
    scores[winner].wins = scores[winner].wins + 1
    saveScores()
end

-------------------------------------------------------
-- ENTRÉE DANS L'ARÈNE
-------------------------------------------------------

RegisterServerEvent("arena:enter")
AddEventHandler("arena:enter", function()
    local src = source
    local Character = VorpCore.getUser(src).getUsedCharacter()

    if Config.HealOnEnter then
        Character.setHealth(200)
    end

    VorpCore.addWeapon(src, Config.ArenaWeapon, 50)

    TriggerClientEvent("vorp:TipBottom", src, "Les esprits accueillent ton courage...", 4000)
    TriggerClientEvent("arena:enterArena", src)
end)

-------------------------------------------------------
-- SORTIE DE L'ARÈNE
-------------------------------------------------------

RegisterServerEvent("arena:leave")
AddEventHandler("arena:leave", function()
    local src = source
    VorpCore.subWeapon(src, Config.ArenaWeapon)
    TriggerClientEvent("arena:exitArena", src)
end)

-------------------------------------------------------
-- MORT RP DANS L’ARÈNE
-------------------------------------------------------

RegisterServerEvent("arena:playerDied")
AddEventHandler("arena:playerDied", function(dead, killer)
    local victim = tonumber(dead)
    local attacker = tonumber(killer)

    if attacker and GetPlayerName(attacker) then
        addKill(attacker)

        local C = VorpCore.getUser(attacker).getUsedCharacter()
        C.addCurrency(0, Config.RewardKill)

        TriggerClientEvent("vorp:TipBottom", attacker, "Tu as vaincu dans le cercle sacré (+1 kill)", 4000)
        TriggerClientEvent("vorp:TipBottom", victim, "Les esprits t’ont jugé…", 4000)

        -- RÉSOLUTION PARI
        if bets[attacker] then
            local amount = bets[attacker].amount
            local fee = math.floor(amount * (Config.FeePercent / 100))
            local winnings = (amount * 2) - fee

            C.addCurrency(0, winnings)
            bets[attacker] = nil

            TriggerClientEvent("vorp:TipBottom", attacker, "Ton pari t’a rapporté $" .. winnings, 3000)
        end
    end

    -- MORT RP → retour sortie après délai
    Citizen.SetTimeout(Config.RPMortTimer, function()
        TriggerClientEvent("arena:exitArena", victim)
    end)
end)

-------------------------------------------------------
-- PARIS / PARIER SUR UN JOUEUR
-------------------------------------------------------

RegisterCommand("pari", function(src, args)
    local targetName = args[1]
    local amount = tonumber(args[2])

    if not targetName or not amount then
        TriggerClientEvent("vorp:Tip", src, "Usage : /pari [nom joueur] [montant]", 4000)
        return
    end

    if amount < Config.MinimumBet then
        TriggerClientEvent("vorp:Tip", src, "Pari minimum : $" .. Config.MinimumBet, 4000)
        return
    end

    local Character = VorpCore.getUser(src).getUsedCharacter()

    if Character.getCurrency(0) < amount then
        TriggerClientEvent("vorp:Tip", src, "Fonds insuffisants.", 3000)
        return
    end

    -- Trouver joueur par nom approximatif
    local target = nil
    for _, id in ipairs(GetPlayers()) do
        if string.find(string.lower(GetPlayerName(id)), string.lower(targetName)) then
            target = tonumber(id)
            break
        end
    end

    if not target then
        TriggerClientEvent("vorp:Tip", src, "Joueur introuvable.", 3000)
        return
    end

    bets[src] = {target = target, amount = amount}
    Character.removeCurrency(0, amount)

    TriggerClientEvent("vorp:TipBottom", src, "Ton pari est placé. Que les esprits te soient favorables.", 4000)
end)

-------------------------------------------------------
-- CLASSEMENT / DUELSTATS
-------------------------------------------------------

RegisterCommand("duelstats", function(src)
    local result = "🏹 Classement Tribal :~n~"

    for id, data in pairs(scores) do
        result = result .. string.format(
            "~e~%s~q~ : %d kills | %d victoires~n~",
            GetPlayerName(id) or ("ID:" .. id),
            data.kills or 0,
            data.wins or 0
        )
    end

    TriggerClientEvent("chat:addMessage", src, { args = { "^3ARENE", result } })
end)

-------------------------------------------------------
-- ADMIN / RELOAD
-------------------------------------------------------

RegisterCommand("reloadarena", function(src)
    if src ~= 0 then
        local User = VorpCore.getUser(src)
        if User.getGroup() ~= "admin" and User.getGroup() ~= "god" then
            TriggerClientEvent("vorp:TipBottom", src, "Permission refusée.", 3000)
            return
        end
    end

    TriggerClientEvent("arena:reload", -1)
    print("[ARENE TRIBALE] Reload effectué.")
end)
