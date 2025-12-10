---------------------------------------------------------------------
-- CLIENT SOUNDS : Sons d'ambiance rituelle premium
---------------------------------------------------------------------

local ritualMusicId = nil
local whispersId = nil
local drumsId = nil
local strongSpiritId = nil
local farWhispersId = nil

---------------------------------------------------------------------
-- STOP ALL SFX
---------------------------------------------------------------------

RegisterNetEvent("arena:stop_all_sfx")
AddEventHandler("arena:stop_all_sfx", function()
    if ritualMusicId then
        StopSound(ritualMusicId)
        ReleaseSoundId(ritualMusicId)
        ritualMusicId = nil
    end

    if whispersId then
        StopSound(whispersId)
        ReleaseSoundId(whispersId)
        whispersId = nil
    end

    if drumsId then
        StopSound(drumsId)
        ReleaseSoundId(drumsId)
        drumsId = nil
    end

    if strongSpiritId then
        StopSound(strongSpiritId)
        ReleaseSoundId(strongSpiritId)
        strongSpiritId = nil
    end

    if farWhispersId then
        StopSound(farWhispersId)
        ReleaseSoundId(farWhispersId)
        farWhispersId = nil
    end
end)

---------------------------------------------------------------------
-- FAR AMBIENCE (chants lointains + vent tribal)
---------------------------------------------------------------------

RegisterNetEvent("arena:play_whispers_far")
AddEventHandler("arena:play_whispers_far", function()
    if farWhispersId then return end

    farWhispersId = GetSoundId()

    PlaySoundFrontend(farWhispersId, Config.WhispersFile, "dlc_xm_orb_map_table_sounds", true)
    SetVariableOnSound(farWhispersId, "volume", Config.WhispersVolume * 0.3)
end)

---------------------------------------------------------------------
-- MID AMBIENCE (tambours + murmures)
---------------------------------------------------------------------

RegisterNetEvent("arena:play_mid_ambience")
AddEventHandler("arena:play_mid_ambience", function()
    if drumsId then return end

    drumsId = GetSoundId()
    PlaySoundFrontend(drumsId, Config.DrumFile, "dlc_xm_orb_map_table_sounds", true)
    SetVariableOnSound(drumsId, "volume", Config.DrumVolume)
end)

---------------------------------------------------------------------
-- STRONG SPIRITS (esprits forts)
---------------------------------------------------------------------

RegisterNetEvent("arena:play_strong_spirits")
AddEventHandler("arena:play_strong_spirits", function()
    if strongSpiritId then return end

    strongSpiritId = GetSoundId()

    PlaySoundFrontend(strongSpiritId, Config.WhispersFile, "dlc_xm_orb_map_table_sounds", true)
    SetVariableOnSound(strongSpiritId, "volume", Config.WhispersVolume * 1.5)
end)

---------------------------------------------------------------------
-- FULL RITUAL (musique complète au centre)
---------------------------------------------------------------------

RegisterNetEvent("arena:play_ritual_full")
AddEventHandler("arena:play_ritual_full", function()
    if ritualMusicId then return end

    ritualMusicId = GetSoundId()

    PlaySoundFrontend(ritualMusicId, Config.RitualMusicFile, "dlc_xm_orb_map_table_sounds", true)
    SetVariableOnSound(ritualMusicId, "volume", Config.MusicVolume)
end)

---------------------------------------------------------------------
-- START RITUAL SFX
---------------------------------------------------------------------

RegisterNetEvent("arena:start_ritual_sfx")
AddEventHandler("arena:start_ritual_sfx", function()
    local sfx = GetSoundId()

    PlaySoundFrontend(sfx, Config.StartRitualSound, "dlc_xm_orb_map_table_sounds", true)
    SetVariableOnSound(sfx, "volume", 1.0)
end)
