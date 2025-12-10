---------------------------------------------------------------------
-- server_duel.lua
-- Système complet de duel 1v1 pour le Sanctuaire Tribal XXL
---------------------------------------------------------------------

local VorpCore = exports.vorp_core:GetCore()

local activeDuels = {}         -- activeDuels[src] = opponent
local duelArenaBusy = false    -- évite 2 duels en même temps
local duelQueue = {}           -- joueurs en attente

---------------------------------------------------------------------
-- AJOUT EN FILE D'ATTENTE
---------------------------------------------------------------------

RegisterServerEvent("arena:queue_duel")
AddEventHandler("arena:queue_duel", function()
    local src = source

    if duelArenaBusy then
        TriggerClientEvent("vorp:TipBottom", src, "Un duel est déjà en cours.", 3000)
        return
    end

    -- Vérifie que le joueur ne spam pas
    for _, p in ipairs(duelQueue) do
        if p == src then
            TriggerClientEvent("vorp:TipBottom", src, "Tu es déjà dans la file d’attente.", 3000)
            return
        end
    end

    table.insert(duelQueue, src)
    TriggerClientEvent("vorp:TipBottom", src, "Tu rejoins la file d’attente du duel sacré.", 3000)

    TryStartDuel()
end)

---------------------------------------------------------------------
-- TENTATIVE D'INITIALISATION DU DUEL
---------------------------------------------------------------------

function TryStartDuel()
    if duelArenaBusy then return end
    if #duelQueue < 2 then return end

    duelArenaBusy = true

    local p1 = table.remove(duelQueue, 1)
    local p2 = table.remove(duelQueue, 1)

    activeDuels[p1] = p2
    activeDuels[p2] = p1

    StartDuel(p1, p2)
end

---------------------------------------------------------------------
-- PREPARATION DU DUEL
---------------------------------------------------------------------

function StartDuel(p1, p2)
    -- Spots :
    -- p1 = spot 1
    -- p2 = spot 2

    TriggerClientEvent("arena:duel_prepare_client", p1, {
        opponent = p2,
        spot = 1,
        isFirst = true
    })

    TriggerClientEvent("arena:duel_prepare_client", p2, {
        opponent = p1,
        spot = 2,
        isFirst = false
    })

    TriggerClientEvent("vorp:TipBottom", p1, "Prépare-toi guerrier...", 2000)
    TriggerClientEvent("vorp:TipBottom", p2, "Prépare-toi guerrier...", 2000)
end

---------------------------------------------------------------------
-- DECLARATION DU GAGNANT
---------------------------------------------------------------------

RegisterServerEvent("arena:duel_death")
AddEventHandler("arena:duel_death", function(dead)
    local loser = tonumber(dead)
    local winner = activeDuels[loser]

    if not winner then return end

    RewardWinner(winner)
    EndDuel(winner, loser)
end)

---------------------------------------------------------------------
-- RECOMPENSE DU VAINQUEUR
---------------------------------------------------------------------

function RewardWinner(winner)
    local User = VorpCore.getUser(winner)
    local char = User.getUsedCharacter()

    char.addCurrency(0, Config.RewardWin)

    -- Scoreboard
    if not scores[winner] then
        scores[winner] = {kills = 0, wins = 0}
    end

    scores[winner].wins = scores[winner].wins + 1
    SaveScores()
end

---------------------------------------------------------------------
-- FIN DU DUEL
---------------------------------------------------------------------

function EndDuel(winner, loser)
    -- notif clients
    TriggerClientEvent("arena:duel_end_client", winner, "win")
    TriggerClientEvent("arena:duel_end_client", loser, "lose")

    -- retéléporte en sortie
    TriggerClientEvent("arena:exitArenaClient", winner)
    TriggerClientEvent("arena:exitArenaClient", loser)

    -- reset
    activeDuels[winner] = nil
    activeDuels[loser] = nil

    duelArenaBusy = false

    -- vérifie si d'autres attendent
    TryStartDuel()
end

---------------------------------------------------------------------
-- ANTI-CHEAT : SI UN JOUEUR QUITTE
---------------------------------------------------------------------

AddEventHandler("playerDropped", function()
    local src = source

    -- Si il était en duel → l’autre gagne automatiquement
    if activeDuels[src] then
        local opp = activeDuels[src]
        RewardWinner(opp)
        EndDuel(opp, src)
    end

    -- Si il était en file d’attente → on le retire
    for i, p in ipairs(duelQueue) do
        if p == src then
            table.remove(duelQueue, i)
            break
        end
    end
end)

---------------------------------------------------------------------
-- ANTI-CHEAT : INTERDICTION DE SORTIR DE LA ZONE
---------------------------------------------------------------------

RegisterServerEvent("arena:duel_outside")
AddEventHandler("arena:duel_outside", function()
    local src = source

    if activeDuels[src] then
        local opp = activeDuels[src]
        RewardWinner(opp)
        EndDuel(opp, src)
    end
end)
