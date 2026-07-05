local level_dependencies_normal= require("level_dependencies_normal")

function onEvent(eventName)
    if eventName == "Boss Begin" then
        Screen.setCameraPosition(-192800,-200600,-200000,-191968,1)
    end
end
