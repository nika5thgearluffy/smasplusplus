--musicalChairs.lua v1.0
--By "The Sun God: Nika"
--Yoshi beats for the win!

local musicalChairs = {}

--If enabled, Yoshi beats will be active.
musicalChairs.enabled = true
musicalChairs.musicList = {
    
    --Super Mario World
    ["_OST\\Super Mario World\\Here We Go (Advance) (Yoshi).spc"] = {
        yoshiTrack = 6,
    },
    ["_OST\\Super Mario World\\Underground (Yoshi).spc"] = {
        yoshiTrack = 6,
    },
    ["_OST\\Super Mario World\\Forest (Yoshi).spc"] = {
        yoshiTrack = 6,
    },
    ["_OST\\Super Mario World\\Athletic (Yoshi).spc"] = {
        yoshiTrack = 6,
    },
    
    --Super Mario Bros. Spencer
    ["_OST\\Super Mario Bros Spencer\\Another World.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Athletic (Beach).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Athletic (Desert).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Athletic (Firey Forest).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Athletic.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Beaches All Around.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Bonus.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Boss Battle.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Castle.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Caves.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Firey Caves.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Firey See-Saws.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Forest.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Going Underground.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Going Underwater.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Ice Cream Desert (Missing Creams).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Ice Cream Desert (Skies).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Ice Cream Desert (Underground).ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Icey Deserty Icicles.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Mountain Base of Climbing.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Overworld.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Spinning the Flames.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Star.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Tower.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Town.ogg"] = {
        yoshiTrack = 2,
    },
    ["_OST\\Super Mario Bros Spencer\\Water.ogg"] = {
        yoshiTrack = 2,
    },
    
    --Extra tracks
    ["_OST\\New Super Mario Bros. Wii\\STRM_BGM_CHIJOU.ogg"] = {
        yoshiTrack = 2,
    },
    
}

function musicalChairs.onInitAPI()
    registerEvent(musicalChairs,"onDraw")
end

function musicalChairs.onDraw()
    if musicalChairs.enabled then
        for _, p in ipairs(Player.get()) do
            local music = Audio.MusicGet(false)
            if music ~= nil and music ~= "" then
                local episodePath = Misc.episodePath()
                local musicNoPathPos = string.find(music, episodePath, 1, true)
                if musicNoPathPos ~= nil then
                    local musicNoPath = string.sub(music, musicNoPathPos + #episodePath)
                    local trackInfo = musicalChairs.musicList[musicNoPath]
                    if trackInfo ~= nil then
                        if p.mount == MOUNT_YOSHI then
                            Sound.unmuteChannel(trackInfo.yoshiTrack)
                        else
                            Sound.muteChannel(trackInfo.yoshiTrack)
                        end
                    end
                end
            end
        end
    end
end

return musicalChairs