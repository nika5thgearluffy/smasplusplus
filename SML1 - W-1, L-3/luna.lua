local level_dependencies_normal= require("level_dependencies_normal")

function onEvent(eventName)
    if eventName == "Boss Start" then
        Sound.changeMusic("_OST/Super Mario Land/Boss Battle.spc|0;g=2.5;e0", 0)
    end
    if eventName == "Bridge End" then
        Sound.playSFX(4)
    end
    if eventName == "Boss End" then
        Sound.playSFX(170)
        Sound.changeMusic(0, 0)
    end
end