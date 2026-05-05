local level_dependencies_normal= require("level_dependencies_normal")
local autoscroll = require("autoscroll")
local smlPop = require("npcs/ai/SMLPop")

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
    end
end

function onEvent(eventName)
    if eventName == "Boss Start" then
        Sound.changeMusic("_OST/Super Mario Land/Boss Battle.spc|0;g=2.5;e0", 0)
    end
    if eventName == "Boss End" then
        Sound.playSFX(170)
        Sound.changeMusic(0, 0)
    end
end
