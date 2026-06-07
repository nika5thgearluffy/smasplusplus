local smasStarSystem = {}

smasStarSystem.fadeInActive = false
smasStarSystem.fadePriority = 6
smasStarSystem.opacityTick = 0.01

smasStarSystem.starDoorImage = Graphics.loadImageResolved("starlock.png")

smasStarSystem.opacity = 0

-- Used to get total count of stars
smasStarSystem.warpStarCount = {}



-- Register events below
registerEvent(smasStarSystem,"onStart")
registerEvent(smasStarSystem,"onDraw")
registerEvent(smasStarSystem,"onWarpEnter")



function smasStarSystem.onStart()
    for _,v in ipairs(Warp.get()) do
        -- Get total count of stars for each warp
        if v.starsRequired ~= nil then
            smasStarSystem.warpStarCount[_] = v.starsRequired
        end
    end
end

function smasStarSystem.onDraw()
    for _,warp in ipairs(Warp.get()) do
        if warp.isValid and (not warp.isHidden) and warp.starsRequired > SaveData.SMASPlusPlus.levels.starCount then
            -- This will draw the star door locks, since the original image is invisible
            Graphics.drawImageToSceneWP(smasStarSystem.starDoorImage, warp.entranceX + 0.5 * warp.entranceWidth - 12, warp.entranceY - 20, -40)
        end
        -- This should automatically update warps being locked when the star count has been modified in-level
        if warp.isValid and (not warp.isHidden) then
            if warp.starsRequired ~= nil and smasStarSystem.warpStarCount[warp.idx + 1] ~= nil then
                if SaveData.SMASPlusPlus.levels.starCount < smasStarSystem.warpStarCount[warp.idx + 1] then
                    warp.starsRequired = smasStarSystem.warpStarCount[warp.idx + 1]
                elseif SaveData.SMASPlusPlus.levels.starCount >= smasStarSystem.warpStarCount[warp.idx + 1] then
                    warp.starsRequired = 0
                end
            end
        end
    end
    if smasStarSystem.fadeInActive then
        smasStarSystem.opacity = smasStarSystem.opacity + smasStarSystem.opacityTick
        Graphics.drawScreen{color = Color.black .. smasStarSystem.opacity, priority = smasStarSystem.fadePriority}
    end
end


return smasStarSystem