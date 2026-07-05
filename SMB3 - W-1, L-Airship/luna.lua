local level_dependencies_normal = require("level_dependencies_normal")

local littleDialogue = require("littleDialogue")

littleDialogue.typewriterEnabled = true

local autoscroll = require("autoscroll")

local airshipScroll = require("airshipScroll")

function onStart()
    if player:mem(0x15E, FIELD_WORD) == 0 and SysManager.getEnteredCheckpointID() == 0 then
        triggerEvent("Beginning Message 0")
    end
end

function onLoadSection2()
    autoscrolla.scrollRight(1)
end

function onEvent(eventName)
    if eventName == "Airship Begin" then
        Sound.playSFX(27)
    end
    if eventName == "Door Forms" then
        Sound.playSFX(20)
    end
    if eventName == "Ending 1" then
        for _,p in ipairs(Player.get()) do
            p:teleport(-99904, -100416)
            p.direction = 1
        end
        Sound.playSFX(45)
    end
end

local function magicWandCalculation(plr)
    return
        plr.x + (plr.width / 2 - (plr.width / 2)),
        plr.y - (plr.height / 2 + 10)
end

function onDraw()
    for _,p in ipairs(Player.get()) do
        if smasBooleans.hasGrabbedMagicWand then
            tempX,tempY = magicWandCalculation(p)
            Graphics.drawImageWP(
                Graphics.sprites.npc[755].img,
                tempX,
                tempY,
                0,
                0,
                NPC.config[755].width,
                NPC.config[755].height,
                -15
            )
        end
    end
end
