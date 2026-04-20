local starsystem = {}

starsystem.fadeInActive = false
starsystem.fadePriority = 6

starsystem.stardoor = Graphics.loadImageResolved("starlock.png")

local opacity = 0

--Star system SaveData variables
if SaveData.SMASPlusPlus.levels.starCount == nil then --This will make a new star count system that won't corrupt save files
    SaveData.SMASPlusPlus.levels.starCount = 0
end
if SaveData.SMASPlusPlus.levels.complete.normal == nil then --This will add a table to list completed levels when collecting win states
    SaveData.SMASPlusPlus.levels.complete.normal = {}
end
if SaveData.SMASPlusPlus.levels.complete.optional == nil then --This will add a table to list completed levels when collecting win states in optional levels
    SaveData.SMASPlusPlus.levels.complete.optional = {}
end

function starsystem.onInitAPI()
    registerEvent(starsystem,"onDraw")
end

function starsystem.onDraw()
    local warps = Warp.get()
    for _,v in ipairs(warps) do
        if v.isValid and (not v.isHidden) and v.starsRequired > SaveData.SMASPlusPlus.levels.starCount then
            Graphics.drawImageToSceneWP(starsystem.stardoor, v.entranceX + 0.5 * v.entranceWidth - 12, v.entranceY - 20, -40) --This will draw the star door locks, since the original image is invisible
        end
    end
    if starsystem.fadeInActive then
        opacity = opacity + 0.01
        Graphics.drawScreen{color = Color.black .. opacity, priority = starsystem.fadePriority}
    end
end

return starsystem