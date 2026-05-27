local level_dependencies_normal= require("level_dependencies_normal")
local autoscroll = require("autoscroll")
local smlPop = require("npcs/ai/SMLPop")
local smasStarSystem = require("smasStarSystem")

local shouldFadeAndEnd = false

function onStart()
    -- Start the autoscroll, as well as start the autoscroll for the pop
    autoscroll.scrollRight(2)
    smlPop.autoscrollXSpeed(2)
end

function onTick()
    for _,p in ipairs(Player.get()) do
        -- Don't kill player when touching blocks
        if p.deathTimer == 0 and p:mem(0x148, FIELD_WORD) > 0 and p:mem(0x14C, FIELD_WORD) > 0 and p:mem(0x164, FIELD_WORD) ~= -1 then
            p:kill()
        end
        if not autoscroll.isSectionScrolling(p.section) then
            smlPop.autoscrollXSpeed(0)
        end
    end
end

function onEvent(eventName)
    if eventName == "Boss Start" then
        Sound.changeMusic("_OST/Super Mario Land/Boss Battle.spc|0;g=2.5;e0", 0)
    end
    if eventName == "Boss End" then
        for k,v in ipairs(NPC.get({742,743,738})) do
            if v and v.isValid then
                v:kill()
            end
        end
        Sound.playSFX(170)
        Sound.changeMusic(0, 0)
        smasBooleans.disablePauseMenu = true
        smasBooleans.winStateActive = true
        Levul.markComplete(false, true, true)
    end
    if eventName == "Cutscene Start" then
        for _,p in ipairs(Player.get()) do
            p:teleport(-179680, -180156, true)
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
