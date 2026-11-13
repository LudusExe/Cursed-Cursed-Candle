-- Cursed Cursed Candle
-- Test map:
--   HUB
--   ├── Torches Room
--   ├── Plants Room
--   ├── Ice Room
--   ├── Light/Dark Door Room
--   └── Final Challenge
--
-- The map is intentionally built as one connected indoor complex.

local STORAGE = core.get_mod_storage()

-- Change this number when the test map layout changes.
-- This forces the new layout to be generated once.
local INITIALIZED_KEY = "test_map_v3_initialized"

local ROOM_SIZE = 21
local HALF = math.floor(ROOM_SIZE / 2)

local ROOM_HEIGHT = 7
local CORRIDOR_WIDTH = 5

local SPAWN = {
    x = 0,
    y = 1,
    z = 0,
}

local ROOMS = {
    hub = {
        x = 0,
        z = 0,
    },

    torches = {
        x = -32,
        z = 0,
    },

    plants = {
        x = 32,
        z = 0,
    },

    ice = {
        x = 0,
        z = -32,
    },

    door = {
        x = 0,
        z = 32,
    },

    final = {
        x = 0,
        z = 64,
    },
}

local generating = false


----------------------------------------------------------------
-- BASIC WORLD HELPERS
----------------------------------------------------------------

local function set_node(pos, name)
    core.set_node(pos, {
        name = name,
    })
end


local function fill(minp, maxp, name)
    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                set_node(
                    {
                        x = x,
                        y = y,
                        z = z,
                    },
                    name
                )
            end
        end
    end
end


local function clear_area(minp, maxp)
    fill(minp, maxp, "air")
end


----------------------------------------------------------------
-- ROOM
----------------------------------------------------------------

local function room_bounds(room)
    return {
        minx = room.x - HALF,
        maxx = room.x + HALF,
        minz = room.z - HALF,
        maxz = room.z + HALF,
    }
end


local function build_room(room)
    local b = room_bounds(room)

    -- Floor.
    fill(
        {
            x = b.minx,
            y = 0,
            z = b.minz,
        },
        {
            x = b.maxx,
            y = 0,
            z = b.maxz,
        },
        "ccc_core:stone"
    )

    -- Ceiling.
    fill(
        {
            x = b.minx,
            y = ROOM_HEIGHT,
            z = b.minz,
        },
        {
            x = b.maxx,
            y = ROOM_HEIGHT,
            z = b.maxz,
        },
        "ccc_core:stone"
    )

    -- North / south walls.
    for y = 1, ROOM_HEIGHT - 1 do
        for x = b.minx, b.maxx do
            set_node(
                {
                    x = x,
                    y = y,
                    z = b.minz,
                },
                "ccc_core:stone"
            )

            set_node(
                {
                    x = x,
                    y = y,
                    z = b.maxz,
                },
                "ccc_core:stone"
            )
        end
    end

    -- West / east walls.
    for y = 1, ROOM_HEIGHT - 1 do
        for z = b.minz + 1, b.maxz - 1 do
            set_node(
                {
                    x = b.minx,
                    y = y,
                    z = z,
                },
                "ccc_core:stone"
            )

            set_node(
                {
                    x = b.maxx,
                    y = y,
                    z = z,
                },
                "ccc_core:stone"
            )
        end
    end
end


----------------------------------------------------------------
-- ROOM OPENINGS
----------------------------------------------------------------

local function open_north(room)
    local b = room_bounds(room)

    for x = room.x - 2, room.x + 2 do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = x,
                    y = y,
                    z = b.minz,
                },
                "air"
            )
        end
    end
end


local function open_south(room)
    local b = room_bounds(room)

    for x = room.x - 2, room.x + 2 do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = x,
                    y = y,
                    z = b.maxz,
                },
                "air"
            )
        end
    end
end


local function open_west(room)
    local b = room_bounds(room)

    for z = room.z - 2, room.z + 2 do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = b.minx,
                    y = y,
                    z = z,
                },
                "air"
            )
        end
    end
end


local function open_east(room)
    local b = room_bounds(room)

    for z = room.z - 2, room.z + 2 do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = b.maxx,
                    y = y,
                    z = z,
                },
                "air"
            )
        end
    end
end


----------------------------------------------------------------
-- HORIZONTAL CORRIDOR
----------------------------------------------------------------

local function corridor_x(x1, x2, z)
    local minx = math.min(x1, x2)
    local maxx = math.max(x1, x2)

    -- Floor.
    for x = minx, maxx do
        for zz = z - 2, z + 2 do
            set_node(
                {
                    x = x,
                    y = 0,
                    z = zz,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Ceiling.
    for x = minx, maxx do
        for zz = z - 2, z + 2 do
            set_node(
                {
                    x = x,
                    y = ROOM_HEIGHT,
                    z = zz,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Side walls.
    for x = minx, maxx do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = x,
                    y = y,
                    z = z - 3,
                },
                "ccc_core:stone"
            )

            set_node(
                {
                    x = x,
                    y = y,
                    z = z + 3,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Interior.
    for x = minx, maxx do
        for y = 1, ROOM_HEIGHT - 1 do
            for zz = z - 2, z + 2 do
                set_node(
                    {
                        x = x,
                        y = y,
                        z = zz,
                    },
                    "air"
                )
            end
        end
    end
end


----------------------------------------------------------------
-- VERTICAL CORRIDOR
----------------------------------------------------------------

local function corridor_z(x, z1, z2)
    local minz = math.min(z1, z2)
    local maxz = math.max(z1, z2)

    -- Floor.
    for z = minz, maxz do
        for xx = x - 2, x + 2 do
            set_node(
                {
                    x = xx,
                    y = 0,
                    z = z,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Ceiling.
    for z = minz, maxz do
        for xx = x - 2, x + 2 do
            set_node(
                {
                    x = xx,
                    y = ROOM_HEIGHT,
                    z = z,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Side walls.
    for z = minz, maxz do
        for y = 1, ROOM_HEIGHT - 1 do
            set_node(
                {
                    x = x - 3,
                    y = y,
                    z = z,
                },
                "ccc_core:stone"
            )

            set_node(
                {
                    x = x + 3,
                    y = y,
                    z = z,
                },
                "ccc_core:stone"
            )
        end
    end

    -- Interior.
    for z = minz, maxz do
        for y = 1, ROOM_HEIGHT - 1 do
            for xx = x - 2, x + 2 do
                set_node(
                    {
                        x = xx,
                        y = y,
                        z = z,
                    },
                    "air"
                )
            end
        end
    end
end


----------------------------------------------------------------
-- OBJECT HELPERS
----------------------------------------------------------------

local function place_candle(pos)
    set_node(pos, "ccc_core:candle")
end


local function place_torch(pos)
    set_node(pos, "ccc_core:torch_off")
end


local function place_plant(pos)
    set_node(pos, "ccc_core:plant_seed")
end


local function place_ice(pos)
    set_node(pos, "ccc_core:ice")
end


local function place_door(pos)
    set_node(pos, "ccc_core:magic_door_closed")
end


----------------------------------------------------------------
-- HUB
----------------------------------------------------------------

local function build_hub()
    local room = ROOMS.hub

    -- Four exits.
    open_west(room)
    open_east(room)
    open_north(room)
    open_south(room)

    -- Central visual landmark.
    place_candle({
        x = room.x,
        y = 1,
        z = room.z,
    })

    place_candle({
        x = room.x - 4,
        y = 1,
        z = room.z - 4,
    })

    place_candle({
        x = room.x + 4,
        y = 1,
        z = room.z - 4,
    })

    place_candle({
        x = room.x - 4,
        y = 1,
        z = room.z + 4,
    })

    place_candle({
        x = room.x + 4,
        y = 1,
        z = room.z + 4,
    })
end


----------------------------------------------------------------
-- TORCH ROOM
----------------------------------------------------------------

local function build_torch_room()
    local room = ROOMS.torches

    -- Entrance back to hub.
    open_east(room)

    -- Three torches placed at different distances.
    place_torch({
        x = room.x - 6,
        y = 1,
        z = -5,
    })

    place_torch({
        x = room.x - 2,
        y = 1,
        z = 0,
    })

    place_torch({
        x = room.x + 4,
        y = 1,
        z = 5,
    })

    -- Candle at the far end gives the player a clear destination.
    place_candle({
        x = room.x - 7,
        y = 1,
        z = 7,
    })

    place_candle({
        x = room.x + 7,
        y = 1,
        z = -7,
    })
end


----------------------------------------------------------------
-- PLANT ROOM
----------------------------------------------------------------

local function build_plant_room()
    local room = ROOMS.plants

    -- Entrance back to hub.
    open_west(room)

    -- Plant in the centre, with light sources around it.
    place_plant({
        x = room.x,
        y = 1,
        z = 0,
    })

    place_torch({
        x = room.x - 5,
        y = 1,
        z = 0,
    })

    place_candle({
        x = room.x + 5,
        y = 1,
        z = 0,
    })

    -- Secondary plant farther away.
    place_plant({
        x = room.x,
        y = 1,
        z = 5,
    })

    place_candle({
        x = room.x - 6,
        y = 1,
        z = 6,
    })
end


----------------------------------------------------------------
-- ICE ROOM
----------------------------------------------------------------

local function build_ice_room()
    local room = ROOMS.ice

    -- Entrance back to hub.
    open_south(room)

    -- Small ice sequence.
    place_ice({
        x = room.x - 4,
        y = 1,
        z = room.z - 2,
    })

    place_ice({
        x = room.x,
        y = 1,
        z = room.z - 2,
    })

    place_ice({
        x = room.x + 4,
        y = 1,
        z = room.z - 2,
    })

    -- Light sources make the interaction readable.
    place_torch({
        x = room.x - 6,
        y = 1,
        z = room.z + 5,
    })

    place_torch({
        x = room.x + 6,
        y = 1,
        z = room.z + 5,
    })

    place_candle({
        x = room.x,
        y = 1,
        z = room.z - 7,
    })
end


----------------------------------------------------------------
-- LIGHT / DARK DOOR ROOM
----------------------------------------------------------------

local function build_door_room()
    local room = ROOMS.door

    -- Entrance from hub.
    open_north(room)

    -- Door in the centre of the room.
    for y = 1, 2 do
        place_door({
            x = room.x,
            y = y,
            z = room.z,
        })
    end

    -- Light source on one side.
    place_torch({
        x = room.x - 6,
        y = 1,
        z = room.z,
    })

    -- Another source on the opposite side.
    place_candle({
        x = room.x + 6,
        y = 1,
        z = room.z,
    })

    -- Small destination behind the door.
    place_candle({
        x = room.x,
        y = 1,
        z = room.z + 7,
    })

    -- Exit toward final room.
    open_south(room)
end


----------------------------------------------------------------
-- FINAL CHALLENGE
----------------------------------------------------------------

local function build_final_room()
    local room = ROOMS.final

    -- Entrance from the door room.
    open_north(room)

    -- The final room is intentionally more open.
    --
    -- Plant.
    place_plant({
        x = room.x - 5,
        y = 1,
        z = room.z - 1,
    })

    place_torch({
        x = room.x - 8,
        y = 1,
        z = -1 + room.z,
    })

    -- Ice.
    place_ice({
        x = room.x + 5,
        y = 1,
        z = room.z - 1,
    })

    place_torch({
        x = room.x + 8,
        y = 1,
        z = room.z + 3,
    })

    -- Final door.
    for y = 1, 2 do
        place_door({
            x = room.x,
            y = y,
            z = room.z + 5,
        })
    end

    -- Additional candles make the room readable,
    -- but do not completely illuminate it.
    place_candle({
        x = room.x - 7,
        y = 1,
        z = room.z + 7,
    })

    place_candle({
        x = room.x + 7,
        y = 1,
        z = room.z + 7,
    })

    place_candle({
        x = room.x,
        y = 1,
        z = room.z - 7,
    })
end


----------------------------------------------------------------
-- COMPLETE LAYOUT
----------------------------------------------------------------

local function build_layout()
    -- Build all rooms first.
    build_room(ROOMS.hub)
    build_room(ROOMS.torches)
    build_room(ROOMS.plants)
    build_room(ROOMS.ice)
    build_room(ROOMS.door)
    build_room(ROOMS.final)

    -- Connect hub -> torch room.
    corridor_x(
        ROOMS.torches.x + HALF,
        ROOMS.hub.x - HALF,
        0
    )

    -- Connect hub -> plant room.
    corridor_x(
        ROOMS.hub.x + HALF,
        ROOMS.plants.x - HALF,
        0
    )

    -- Connect hub -> ice room.
    corridor_z(
        0,
        ROOMS.ice.z + HALF,
        ROOMS.hub.z - HALF
    )

    -- Connect hub -> door room.
    corridor_z(
        0,
        ROOMS.hub.z + HALF,
        ROOMS.door.z - HALF
    )

    -- Connect door room -> final room.
    corridor_z(
        0,
        ROOMS.door.z + HALF,
        ROOMS.final.z - HALF
    )

    -- Build room-specific contents.
    build_hub()
    build_torch_room()
    build_plant_room()
    build_ice_room()
    build_door_room()
    build_final_room()

    -- Make sure the spawn area is completely clear.
    clear_area(
        {
            x = -2,
            y = 1,
            z = -2,
        },
        {
            x = 2,
            y = 4,
            z = 2,
        }
    )
end


----------------------------------------------------------------
-- WORLD GENERATION
----------------------------------------------------------------

local function initialize_world()
    if generating then
        return
    end

    if STORAGE:get_string(INITIALIZED_KEY) == "true" then
        return
    end

    generating = true

    -- Test-map area.
    --
    -- It is intentionally cleared first so an old version
    -- of the test map cannot remain underneath the new one.
    local minp = {
        x = -45,
        y = -2,
        z = -45,
    }

    local maxp = {
        x = 45,
        y = 10,
        z = 76,
    }

    core.emerge_area(
        minp,
        maxp,
        function(_, _, remaining)
            if remaining ~= 0 then
                return
            end

            -- Remove the old test-map geometry.
            clear_area(minp, maxp)

            -- Create the new connected map.
            build_layout()

            STORAGE:set_string(
                INITIALIZED_KEY,
                "true"
            )

            generating = false

            for _, player in ipairs(core.get_connected_players()) do
                player:set_pos(SPAWN)

                ccc.hud_message(
                    player,
                    "Explore the hub and discover the four chambers.",
                    5
                )
            end
        end
    )
end


----------------------------------------------------------------
-- LOAD
----------------------------------------------------------------

core.register_on_mods_loaded(function()
    core.after(1, initialize_world)
end)


core.register_on_joinplayer(function(player)
    if STORAGE:get_string(INITIALIZED_KEY) ~= "true" then
        return
    end

    core.after(1, function()
        if player and player:is_player() then
            player:set_pos(SPAWN)
        end
    end)
end)
