local level_dependencies_normal= require("level_dependencies_normal")

function onStart()
    if GameData.gameHelpIntroActive then
        local layerMap = Layer.get("Warp - Map")
        local layerBootMenu = Layer.get("Warp - Boot Menu")
        layerMap:hide(true)
        layerBootMenu:show(true)
        smasBooleans.disablePauseMenu = true
        GameData.gameHelpIntroActive = false
    end
end
