local smasM3ATWSystem = {}

registerEvent(smasM3ATWSystem, "onStart")

-- Change the music on the start of the level
function smasM3ATWSystem.onStart()
    if table.icontains(smasTables.__m3AllAroundTheWorldLevels, Level.filename()) then
        Sound.changeMusicRNG(smasTables.mario3AroundTheWorldMusicRng, -1)
    end
end

return smasM3ATWSystem