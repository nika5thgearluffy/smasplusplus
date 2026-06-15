local level_dependencies_normal= require("level_dependencies_normal")
local autoscroll = require("autoscroll")
local smlPop = require("npcs/ai/SMLPop")
local smasStarSystem = require("smasStarSystem")

local shouldFadeAndEnd = false

function onStart()
    -- Start the autoscroll, as well as start the autoscroll for the pop
    autoscroll.scrollRight(2)
    smlPop.autoscrollXSpeed(2)
    for _,p in ipairs(Player.get()) do
        local pop = NPC.spawn(736, p.x, p.y)
        pop.direction = p.direction
    end
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
        --[[for k,v in ipairs(NPC.get({})) do
            if v and v.isValid then
                v:kill()
            end
        end]]
        Sound.playSFX(170)
        Sound.changeMusic(0, 0)
        --Levul.markComplete(false, true, true)
    end
end

function onDraw()
    if smasStarSystem.opacity >= 1 and shouldFadeAndEnd then
        Level.exit(LEVEL_WIN_TYPE_STAR)
    end
end
