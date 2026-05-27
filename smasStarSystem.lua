local starsystem = {}

starsystem.fadeInActive = false
starsystem.fadePriority = 6
starsystem.opacityTick = 0.01

starsystem.stardoor = Graphics.loadImageResolved("starlock.png")

starsystem.opacity = 0

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
        starsystem.opacity = starsystem.opacity + starsystem.opacityTick
        Graphics.drawScreen{color = Color.black .. starsystem.opacity, priority = starsystem.fadePriority}
    end
end

return starsystem