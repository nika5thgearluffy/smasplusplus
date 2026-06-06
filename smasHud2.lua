local smasHud = {}

local smasFunctions = require("smasFunctions")
local textplus = require("textplus")
local timer = require("timer-mod")
local playerManager = require("playerManager")

local smasHudActivated = true

smasHud.font = textplus.loadFont("littleDialogue/font/1.ini")
smasHud.priority = 5

smasHud.elements = {}
smasHud.elements.show = {
    coinRegular = true,
    starCount = true,
    lives = true,
    reserveBox = true,
    hearts = true,
    deathCount = true,
    score = true,
    timer = true,
    customItemBox = true,
    pWing = true,
    bombs = true,
}
smasHud.elements.icons = {
    x = Graphics.sprites.hardcoded["33-1"].img,
    coinRegular = Graphics.sprites.hardcoded["33-2"].img,
    starCount = Graphics.sprites.hardcoded["33-5"].img,
    lives = Graphics.loadImageResolved("graphics/hardcoded/hardcoded-100-2.png"),
    reserveBox = Graphics.sprites.hardcoded["48-0"].img,
    reserveBox2 = Graphics.sprites.hardcoded["48-1"].img,
    deathCount = Graphics.loadImageResolved("graphics/hardcoded/hardcoded-100-3.png"),
    timer = Graphics.sprites.hardcoded["52"].img,
    heartFull = Graphics.sprites.hardcoded["36-1"].img,
    heartEmpty = Graphics.sprites.hardcoded["36-2"].img,
    key = Graphics.sprites.hardcoded["33-0"].img,
    rupees = Graphics.sprites.hardcoded["33-6"].img,
    bombs = Graphics.sprites.hardcoded["33-8"].img,
}

smasHud.drawing = {}
smasHud.drawing.angles = {
    left = 5,
    middle = camera.width / 2,
    right = camera.width - 30,
}

registerEvent(smasHud,"onDraw")

function smasHud.activateHud(toggle)
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

local function getValuesForPlayerReserve(p)
    local reserveItem = SaveData.SMASPlusPlus.hud.reserve[p.idx]
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
    return w,h,sourcex,sourcey,reserve
end

function smasHud.drawHud()
    -- Keep these updated
    smasHud.drawing.angles.left = 5
    smasHud.drawing.angles.middle = camera.width / 2
    smasHud.drawing.angles.right = camera.width - 5

    -- Main hud drawing code
    if smasHudActivated then
        -- Coins
        if smasHud.elements.show.coinRegular then
            Graphics.drawImageWP(smasHud.elements.icons.coinRegular, smasHud.drawing.angles.left + 15, 25, smasHud.priority)
            Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.left + 35, 25, smasHud.priority)
            textplus.print{
                x = smasHud.drawing.angles.left + 55,
                y = 25,
                text = tostring(SysManager.coinCountClassicWith99Limit()),
                priority = smasHud.priority,
                color = Color.white,
                font = smasHud.font,
            }
        end
        -- Stars
        if smasHud.elements.show.starCount then
            local stars = SaveData.SMASPlusPlus.levels.starCount
            if stars > 0 then
                Graphics.drawImageWP(smasHud.elements.icons.starCount, smasHud.drawing.angles.left + 15, 50, smasHud.priority)
                Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.left + 35, 50, smasHud.priority)
                textplus.print{
                    x = smasHud.drawing.angles.left + 55,
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
            local livesPosition = 210
            Graphics.drawImageWP(smasHud.elements.icons.lives, smasHud.drawing.angles.middle - livesPosition, 40, smasHud.priority)
            Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.middle - livesPosition + 36, 40, smasHud.priority)
            if SaveData.SMASPlusPlus.hud.lives <= 999 then
                textplus.print{
                    x = smasHud.drawing.angles.middle - livesPosition + 54,
                    y = 40,
                    text = tostring(SysManager.lifeCount()),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            elseif SaveData.SMASPlusPlus.hud.lives >= 1000 then
                textplus.print{
                    x = smasHud.drawing.angles.middle - livesPosition + 54,
                    y = 40,
                    text = SysManager.lifeCountWithCrownsAndZeroFailsafe(),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            end
        end
        -- Reserve Box
        local chars = playerManager.getCharacters()
        if smasHud.elements.show.reserveBox then
            for _,p in ipairs(Player.get()) do
                if (chars[p.character].base == 1 or chars[p.character].base == 2) then
                    Graphics.drawImageWP(smasHud.elements.icons.reserveBox, smasHud.drawing.angles.middle - 30, 15, smasHud.priority)
                    if SaveData.SMASPlusPlus.hud.reserve[player.idx] > 0 then
                        local w,h,sourcex,sourcey,reserve = getValuesForPlayerReserve(player)
                        Graphics.drawImageWP(reserve, smasHud.drawing.angles.middle - 18, 28, sourcex, sourcey, w, h, smasHud.priority)
                    end
                    if Player.count() >= 2 then
                        Graphics.drawImageWP(smasHud.elements.icons.reserveBox2, smasHud.drawing.angles.middle - 30, 85, smasHud.priority)
                        if SaveData.SMASPlusPlus.hud.reserve[player2.idx] > 0 then
                            local w,h,sourcex,sourcey,reserve = getValuesForPlayerReserve(player2)
                            Graphics.drawImageWP(reserve, smasHud.drawing.angles.middle - 18, 98, sourcex, sourcey, w, h, smasHud.priority)
                        end
                    end
                end
                if (chars[p.character].base == 3 or chars[p.character].base == 4 or chars[p.character].base == 5) then
                    for i = 1,3 do
                        Graphics.drawImageWP(smasHud.elements.icons.heartEmpty, smasHud.drawing.angles.middle - 75 + (i * 32), 18, smasHud.priority)
                    end
                    for i = 1,player:mem(0x16, FIELD_WORD) do
                        Graphics.drawImageWP(smasHud.elements.icons.heartFull, smasHud.drawing.angles.middle - 75 + (i * 32), 18, smasHud.priority)
                    end
                    if Player.count() >= 2 then
                        for i = 1,3 do
                            Graphics.drawImageWP(smasHud.elements.icons.heartEmpty, smasHud.drawing.angles.middle - 75 + (i * 32), 78, smasHud.priority)
                        end
                        for i = 1,player2:mem(0x16, FIELD_WORD) do
                            Graphics.drawImageWP(smasHud.elements.icons.heartFull, smasHud.drawing.angles.middle - 75 + (i * 32), 78, smasHud.priority)
                        end
                    end
                end
            end
        end
        -- Death count
        if smasHud.elements.show.deathCount then
            local deathPosition = 100
            Graphics.drawImageWP(smasHud.elements.icons.deathCount, smasHud.drawing.angles.middle + deathPosition, 38, smasHud.priority)
            Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.middle + deathPosition + 20, 40, smasHud.priority)
            if SaveData.SMASPlusPlus.hud.deathCount <= 999 then
                textplus.print{
                    x = smasHud.drawing.angles.middle + deathPosition + 40,
                    y = 40,
                    text = tostring(SaveData.SMASPlusPlus.hud.deathCount),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            else
                textplus.print{
                    x = smasHud.drawing.angles.middle - deathPosition + 40,
                    y = 40,
                    text = "999+",
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            end
        end
        if smasHud.elements.show.score then
            textplus.print{
                x = smasHud.drawing.angles.right - 175,
                y = 25,
                text = tostring(SysManager.scoreCountWithZeroes()),
                priority = smasHud.priority,
                color = Color.white,
                font = smasHud.font,
            }
        end
        if smasHud.elements.show.timer then
            if timer.isActive() then
                local timer = timer.getValue()
                if timer == -0 then
                    timer = 0
                end
                local timerPosition = 106
                Graphics.drawImageWP(smasHud.elements.icons.timer, smasHud.drawing.angles.right - timerPosition, 50, smasHud.priority)
                Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.right - timerPosition + 20, 50, smasHud.priority)
                textplus.print{
                    x = smasHud.drawing.angles.right - timerPosition + 40,
                    y = 50,
                    text = tostring(timer),
                    priority = smasHud.priority,
                    color = Color.white,
                    font = smasHud.font,
                }
            end
        end
        if smasHud.elements.show.bombs then
            if Player.count() == 1 then
                if player:mem(0x08, FIELD_WORD) > 0 then
                    Graphics.drawImageWP(smasHud.elements.icons.bombs, smasHud.drawing.angles.middle - 31, 52, smasHud.priority)
                    Graphics.drawImageWP(smasHud.elements.icons.x, smasHud.drawing.angles.middle - 7, 53, smasHud.priority)
                    textplus.print{
                        x = smasHud.drawing.angles.middle + 16,
                        y = 53,
                        text = tostring(player:mem(0x08, FIELD_WORD)),
                        priority = smasHud.priority,
                        color = Color.white,
                        font = smasHud.font,
                    }
                end
            else
                if player:mem(0x08, FIELD_WORD) > 0 then
                    
                end
                if player2:mem(0x08, FIELD_WORD) > 0 then
                    
                end
            end
        end
    end
end

function smasHud.onDraw()
    Graphics.overrideHUD(smasHud.drawHud)
end

return smasHud