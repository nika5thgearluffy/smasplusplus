local smasM3ATWSystem = {}

registerEvent(smasM3ATWSystem, "onStart")
registerEvent(smasM3ATWSystem, "onSectionChange")
registerEvent(smasM3ATWSystem, "onExitLevel")
registerEvent(smasM3ATWSystem, "onPlayerHarm")
registerEvent(smasM3ATWSystem, "onPlayerKill")
registerEvent(smasM3ATWSystem, "onInputUpdate")

local playervuln = false
local playerwon = false
local alreadyWon = false

local mario3AroundTheWorldMusicRng = {
    "_OST/Mario 3 - Around the World (Bootleg)/03 - Music 1 (Forget Him).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/04 - Music 2 (Through the Night).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/05 - Music 3 (Quick Fix).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/06 - Music 4 (Lost Forest).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/07 - Music 5 (Lame Bells).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/08 - Music 6 (FM Acid).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/09 - Music 7 (SMB Tepples).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/10 - Music 8 (Uzhos).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/11 - Music 9 (Space Standart).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/12 - Music 10 (Another It).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/13 - Music 11 (Nonamed).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/14 - Music 12 (Class11.Time Flies).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/15 - Music 13 (Wizardry).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/16 - Music 14 (Ending Theme).vgm",
    "_OST/Mario 3 - Around the World (Bootleg)/17 - Music 15 (SMB).vgm",
}

local function levelWon()
    for _,o in ipairs(Player.get()) do
        if o.idx ~= plr.idx then
            o.section = plr.section
            o.x = (plr.x+(plr.width/2)-(o.width/2))
            o.y = (plr.y+plr.height-o.height)
            o.speedX,o.speedY = 0,0
            o.forcedState,o.forcedTimer = 8,-plr.idx
        end
    end
    Sound.playSFX()
    muteMusic(-1)
    Audio.SeizeStream(-1)
    Audio.MusicStop()
    smasBooleans.musicMuted = true
    GameData.winStateActive = true
    playervuln = true
    playerwon = true
    Routine.wait(5, true)
    smasBooleans.musicMuted = false
    GameData.winStateActive = false
    Level.exit(LEVEL_WIN_TYPE_OFFSCREEN)
end

function smasM3ATWSystem.onPlayerHarm(evt)
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) and playervuln then
        evt.cancelled = true
    end
end

function smasM3ATWSystem.onPlayerKill(evt)
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) and playervuln then
        evt.cancelled = true
    end
end

function smasM3ATWSystem.onInputUpdate()
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) and playerwon then
        for k,_ in pairs(player.keys) do
            player.keys[k] = false
        end
        if Player.count() >= 2 then
            for k,_ in pairs(player2.keys) do
                player2.keys[k] = false
            end
        end
    end
end

-- Change the music on the start of the level...
function smasM3ATWSystem.onStart()
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) then
        --Sound.changeMusicRNG(mario3AroundTheWorldMusicRng, -1)
    end
end

-- ...As well as when changing a section.
function smasM3ATWSystem.onSectionChange(sectionID, playerID)
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) then
        --Sound.changeMusicRNG(mario3AroundTheWorldMusicRng, -1)
    end
end

function smasM3ATWSystem.onExitLevel(winType)
    if (table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) and winType == LEVEL_WIN_TYPE_OFFSCREEN) and not alreadyWon then
        alreadyWon = true
        Routine.run(levelWon)
    end
end

return smasM3ATWSystem