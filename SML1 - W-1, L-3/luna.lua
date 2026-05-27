local level_dependencies_normal= require("level_dependencies_normal")
local smasStarSystem = require("smasStarSystem")

local shouldFadeAndEnd = false

function onEvent(eventName)
    if eventName == "Boss Start" then
        Sound.changeMusic("_OST/Super Mario Land/Boss Battle.spc|0;g=2.5;e0", 0)
    end
    if eventName == "Bridge End" then
        Sound.playSFX(4)
    end
    if eventName == "Boss End" then
        Sound.playSFX(170)
        Sound.changeMusic(0, 0)
        smasBooleans.disablePauseMenu = true
        smasBooleans.winStateActive = true
        Levul.markComplete(false, true, true)
    end
    if eventName == "Cutscene Start" then
        for _,p in ipairs(Player.get()) do
            p:teleport(-139680, -140156, true)
            p.direction = 1
            smasBooleans.disablePlayerKeys = true
            if p.standingNPC and p.standingNPC ~= nil then
                -- Apparently there's a bug where the player is invisible when teleported standing on an NPC? Clear that so the player is visible again
                p:mem(0x176, FIELD_WORD, 0)
            end
        end
    end
    if eventName == "Cutscene 1" then
        Sound.playSFX(47)
    end
    if eventName == "Cutscene 2" then
        Sound.playSFX(164)
    end
    if eventName == "Cutscene 4" then
        Sound.playSFX(34)
    end
    if eventName == "End Level" then
        shouldFadeAndEnd = true
        smasStarSystem.opacityTick = 0.03
        smasStarSystem.fadeInActive = true
    end
end

function onDraw()
    if smasStarSystem.opacity >= 1 and shouldFadeAndEnd then
        Level.exit(LEVEL_WIN_TYPE_STAR)
    end
end