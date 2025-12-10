Props = {}

local CENTER = vector3(-3901.68, -2472.05, -10.11)

-------------------------------------------------------
-- TOTEM GEANT SACRE (x3 taille)
-------------------------------------------------------

table.insert(Props, {
    model = "p_totem01x",
    coords = CENTER,
    heading = 180.0,
    scale = 3.0,
    isTotem = true
})

-------------------------------------------------------
-- PROMONTOIRE DU CHAMAN GUERRIER
-------------------------------------------------------

table.insert(Props, {
    model = "p_rock05x",
    coords = vector3(CENTER.x, CENTER.y + 7.5, CENTER.z + 1.2),
    heading = 120.0,
    scale = 1.4,
    isPlatform = true
})

-------------------------------------------------------
-- BRASIERS GEANTS (8 autour du cercle)
-------------------------------------------------------

local brazRadius = 34.0
for i = 1, 8 do
    local angle = (i / 8) * math.pi * 2
    local x = CENTER.x + math.cos(angle) * brazRadius
    local y = CENTER.y + math.sin(angle) * brazRadius

    table.insert(Props, {
        model = "p_campfirecombined01x",
        coords = vector3(x, y, CENTER.z - 0.20),
        heading = (angle * 57.2958),
        scale = 1.6,
        isBrazier = true
    })
end

-------------------------------------------------------
-- PIERRES SACREES (12 autour du cercle)
-------------------------------------------------------

local stoneRadius = 32.0
for i = 1, 12 do
    local angle = (i / 12) * math.pi * 2
    local x = CENTER.x + math.cos(angle) * stoneRadius
    local y = CENTER.y + math.sin(angle) * stoneRadius

    table.insert(Props, {
        model = "p_milestone01x",
        coords = vector3(x, y, CENTER.z - 0.25),
        heading = (angle * 57.2958),
        scale = 1.2,
        isStone = true
    })
end

-------------------------------------------------------
-- TAMBOURS RITUELS (4 directions cardinales)
-------------------------------------------------------

local drumPositions = {
    {x = 8.0,  y = 0.0},
    {x = -8.0, y = 0.0},
    {x = 0.0,  y = 8.0},
    {x = 0.0,  y = -8.0},
}

for _, pos in ipairs(drumPositions) do
    table.insert(Props, {
        model = "p_drum01x",
        coords = vector3(CENTER.x + pos.x, CENTER.y + pos.y, CENTER.z - 0.15),
        heading = 0.0,
        scale = 1.0,
        isDrum = true
    })
end

-------------------------------------------------------
-- TORCHES SACREES (8 autour du totem)
-------------------------------------------------------

local torchRadius = 10.0
for i = 1, 8 do
    local angle = (i / 8) * math.pi * 2
    local x = CENTER.x + math.cos(angle) * torchRadius
    local y = CENTER.y + math.sin(angle) * torchRadius

    table.insert(Props, {
        model = "p_torchpost01x",
        coords = vector3(x, y, CENTER.z - 0.10),
        heading = (angle * 57.2958),
        scale = 1.0,
        isTorch = true
    })
end

-------------------------------------------------------
-- TIPIS (deux tentes tribales)
-------------------------------------------------------

table.insert(Props, {
    model = "p_tipi01x",
    coords = vector3(CENTER.x + 14.0, CENTER.y + 7.0, CENTER.z - 0.10),
    heading = 210.0,
    scale = 1.1
})

table.insert(Props, {
    model = "p_tipi01x",
    coords = vector3(CENTER.x - 14.0, CENTER.y - 7.0, CENTER.z - 0.10),
    heading = 30.0,
    scale = 1.1
})

-------------------------------------------------------
-- PARTICULES / FX SACRES (sur totem + centre)
-------------------------------------------------------

Props.FX = {
    totem = {
        type = "spirit_smoke",
        coords = CENTER,
        scale = 2.5
    },
    circle = {
        type = "dust_red",
        coords = CENTER,
        scale = 3.0
    }
}

-------------------------------------------------------
-- FIN DU FICHIER
-------------------------------------------------------
