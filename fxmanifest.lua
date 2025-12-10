fx_version 'adamant'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Trailborn 1883 — Arena Tribale Premium'
description 'Sanctuaire Tribal XXL | Duel 1v1 | Arène de Tir | Effets Rituels | Sons Premium'
version '2.0.0'

---------------------------------------------------------------------
-- DEPENDANCES
---------------------------------------------------------------------

dependency 'vorp_core'

---------------------------------------------------------------------
-- FICHIERS PARTAGES
---------------------------------------------------------------------

shared_scripts {
    'config.lua'
}

---------------------------------------------------------------------
-- CLIENT
---------------------------------------------------------------------

client_scripts {
    'client/client_interact.lua',
    'client/client_duel.lua',
    'client/client_guardian.lua',
    'client/client_sounds.lua',
    'client/client_fx.lua',
    'client/props.lua'
}

---------------------------------------------------------------------
-- SERVER
---------------------------------------------------------------------

server_scripts {
    '@vorp_core/lib/utils.lua',
    'server/server_main.lua',
    'server/server_duel.lua'
}

---------------------------------------------------------------------
-- AUDIO
---------------------------------------------------------------------

files {
    'audio/ritual_music.ogg',
    'audio/drum_loop.ogg',
    'audio/spirit_whispers.ogg',
    'audio/ritual_start_sfx.ogg',
    'data/scores.json'
}

data_file 'AUDIO_WAVEPACK' 'audio/'

---------------------------------------------------------------------
-- RESSOURCES INCLUSES
---------------------------------------------------------------------

lua54 'yes'
