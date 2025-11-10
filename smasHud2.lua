local smasHud = {}

local smasFunctions = require("smasFunctions")
local textplus = require("textplus")

local smasHudActivated = true

smasHud.font = textplus.loadFont("littleDialogue/font/1.ini")
smasHud.priority = 5

smasHud.elements = {}
smasHud.elements.show = {
    coinRegular = true,
    starCount = true,
    lives = true,
    reserveBox = true,
    deathCount = true,
    score = true,
    timer = true,
    customItemBox = true,
    pWing = true,
}
smasHud.elements.icons = {
    x = Graphics.sprites.hardcoded["33-1"].img,
    coinRegular = Graphics.sprites.hardcoded["33-2"].img,
    starCount = Graphics.sprites.hardcoded["33-5"].img,
    lives = Graphics.loadImageResolved("graphics/hardcoded/hardcoded-100-2.png"),
    reserveBox = Graphics.sprites.hardcoded["48-0"].img,
    deathCount = Graphics.loadImageResolved("graphics/hardcoded/hardcoded-100-3.png"),
    timer = Graphics.sprites.hardcoded["52"].img,
}

smasHud.drawing = {}
smasHud.drawing.angles = {
    left = camera.x + 30,
    middle = camera.width / 2,
    right = camera.width - 30,
}

registerEvent(smasHud,"onDraw")

function Graphics.activateHud(toggle)
    if toggle then
        smasHud.elements.show.coinRegular = true
        smasHud.elements.show.starCount = true
        smasHud.elements.show.lives = true
        smasHud.elements.show.reserveBox = true
        smasHud.elements.show.deathCount = true
        smasHud.elements.show.score = true
        smasHud.elements.show.timer = true
        smasHud.elements.show.customItemBox = true
        smasHud.elements.show.pWing = true
        smasHudActivated = true
    else
        smasHud.elements.show.coinRegular = false
        smasHud.elements.show.starCount = false
        smasHud.elements.show.lives = false
        smasHud.elements.show.reserveBox = false
        smasHud.elements.show.deathCount = false
        smasHud.elements.show.score = false
        smasHud.elements.show.timer = false
        smasHud.elements.show.customItemBox = false
        smasHud.elements.show.pWing = false
        smasHudActivated = false
    end
end

function smasHud.drawHud()
    -- Keep these updated
    smasHud.drawing.angles.left = camera.x + 30
    smasHud.drawing.angles.middle = camera.width / 2
    smasHud.drawing.angles.right = camera.width - 30

    -- Main hud drawing code
    if smasHudActivated then
        -- Coins
        if smasHud.elements.show.coinRegular then
            Graphics.drawImageWP(smasHud.elements.icons.coinRegular, camera.x + 30, 25, smasHud.priority)
            Graphics.drawImageWP(smasHud.elements.icons.x, camera.x + 55, 25, smasHud.priority)
            textplus.print{
                x = camera.x + 80,
                y = 25,
                text = tostring(SysManager.coinCountClassicWith99Limit()),
                priority = smasHud.priority,
                color = Color.white,
                font = smasHud.font,
            }
        end
        -- Stars
        if smasHud.elements.show.starCount then
            local stars = SaveData.totalStarCount
            if stars > 0 then
                Graphics.drawImageWP(smasHud.elements.icons.starCount, camera.x + 30, 50, smasHud.priority)
                Graphics.drawImageWP(smasHud.elements.icons.x, camera.x + 55, 50, smasHud.priority)
                textplus.print{
                    x = camera.x + 80,
                    y = 50,
                    text = tostring(stars),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            end
        end
        -- Lives
        if smasHud.elements.show.lives then
            Graphics.drawImageWP(smasHud.elements.icons.lives, smasHud.drawing.angles.middle - 200, 40, smasHud.priority)
            Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.middle - 190, 40, smasHud.priority)
            if SaveData.SMASPlusPlus.hud.lives <= 999 then
                textplus.print{
                    x = smasHud.drawing.angles.middle - 155,
                    y = 40,
                    text = SysManager.coinCountClassicWith99Limit(),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            elseif SaveData.SMASPlusPlus.hud.lives >= 1000 then
                textplus.print{
                    x = smasHud.drawing.angles.middle - 155,
                    y = 40,
                    text = SysManager.lifeCountWithCrownsAndZeroFailsafe(),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            end
        end
        -- Reserve Box
        if smasHud.elements.show.reserveBox then
            Graphics.drawImageWP(smasHud.elements.icons.reserveBox, smasHud.drawing.angles.middle - 30, 15, smasHud.priority)
            if SaveData.SMASPlusPlus.hud.reserve[player.idx] > 0 then
                local reserveItem = SaveData.SMASPlusPlus.hud.reserve[player.idx]
                local reserve = Graphics.sprites.npc[reserveItem].img

                local w = NPC.config[reserveItem].gfxwidth
                if w == 0 then
                    w = NPC.config[reserveItem].width
                end

                local h = NPC.config[reserveItem].gfxheight
                if h == 0 then
                    h = NPC.config[reserveItem].height
                end

                local sourcex = 0;
                local sourcey = 0;

                --Special case for megashroom
                if(reserveItem == 425) then
                    sourcey = 5*h;
                end

                Graphics.drawImageWP(reserve, smasHud.drawing.angles.middle - 15, 28, sourcex, sourcey, w, h, smasHud.priority)
            end
        end
        -- Death count
        if smasHud.elements.show.deathCount then
            
        end
    end
end

function smasHud.onDraw()
    smasHud.drawHud()
end

return smasHud