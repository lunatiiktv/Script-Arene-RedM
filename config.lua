Config = {}

-----------------------------------------------------
-- 📍 POSITIONS PRINCIPALES
-----------------------------------------------------

-- Entrée de l'arène libre
Config.Entrance = vector3(-3901.68, -2472.05, -10.11)
Config.EntranceRadius = 1.8

-- Entrée du mode DUEL
Config.DuelEntrance = vector3(-3897.50, -2472.50, -10.11)

-- Centre EXACT du sanctuaire XXL
Config.ArenaCenter = vector3(-3901.68, -2472.05, -10.11)

-- Où le joueur sort après mort / quit
Config.Exit = vector3(-3909.50, -2471.50, -10.11)

-----------------------------------------------------
-- ⚔ TAILLE & LIMITES DE L'ARENE XXL
-----------------------------------------------------

-- Rayon du cercle sacré (grande arène comme tu veux)
Config.ArenaRadius = 28.0

-- Distance max autorisée avant "anti-fuite"
Config.ArenaMaxDistance = 35.0

Config.AntiLeaveDuringDuel = true

-----------------------------------------------------
-- 🏹 ARMES AUTORISÉES DANS L’ARENE
-----------------------------------------------------

Config.AllowedWeapons = {
    "WEAPON_RIFLE_VARMINT",          -- fusil petit gibier
    "WEAPON_REPEATER_WINCHESTER",    -- Winchester
    "WEAPON_MELEE_KNIFE",            -- couteau
    "WEAPON_BOW",                    -- arc simple
    "WEAPON_THROWN_TOMAHAWK"         -- tomahawk
}

Config.BlockForbiddenWeapons   = true
Config.GiveWeaponsOnEnter      = true
Config.RestoreWeaponsOnExit    = true

-----------------------------------------------------
-- ❤️ PARAMÈTRES DE SANTÉ
-----------------------------------------------------

Config.HealOnEnter = true

-----------------------------------------------------
-- 🔥 MUSIQUES ET SONS
-----------------------------------------------------

-- Fichiers (dans /audio/)
Config.RitualMusicFile   = "ritual_music"
Config.DrumFile          = "drum_loop"
Config.WhispersFile      = "spirit_whispers"
Config.StartRitualSound  = "ritual_start_sfx"

-- Volumes
Config.MusicVolume   = 0.35
Config.DrumVolume    = 0.55
Config.WhispersVolume = 0.40

-- Activation
Config.EnableRitualMusic = true
Config.EnableDrumLoop = true

-----------------------------------------------------
-- 🧊 FX & CINEMATIQUES
-----------------------------------------------------

Config.DuelStartCinematic = true
Config.DuelCamTime = 4000

-- Countdown du duel
Config.DuelCountdown = { "3", "2", "1", "TIRE !" }

-----------------------------------------------------
-- 🕯 SCORES / RECOMPENSES
-----------------------------------------------------

Config.ScoreFile = "data/scores.json"

Config.RewardKill = 1     -- récompense par kill en FFA
Config.RewardWin  = 5     -- récompense victoire duel

-----------------------------------------------------
-- 🗿 NPC & TOTEM (déjà géré dans props.lua et fx)
-----------------------------------------------------

Config.Referee = {
    model   = "U_M_M_NbxShaman_01",
    coords  = vector3(-3901.68, -2472.05, -10.11 + 2.5),
    heading = 180.0,
    animDict = "amb_rest@world_human_meditation@male_a@idle_b",
    animName = "idle_f"
}
