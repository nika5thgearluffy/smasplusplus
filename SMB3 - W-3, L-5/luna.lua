local level_dependencies_normal= require("level_dependencies_normal")

function onEvent(eventName)
    if eventName == "Three 1-up Block 1" then
        Sound.playSFX(22)
        Defines.earthquake = 5
    end
end
