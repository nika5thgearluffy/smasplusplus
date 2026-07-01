local level_dependencies_normal= require("level_dependencies_normal")

function onEvent(eventName)
    if eventName == "Get Item!" then
        smasMapInventorySystem.addPowerUp(7, 1) -- P-Wing
        Audio.MusicFadeOut(1, 1)
        Sound.playSFX("chest.ogg")
        Sound.playSFX("_OST/Super Mario Bros 3/Battle Mode Win.spc")
    end
    if eventName == "End Level" then
        Levul.markComplete(true, false, true)
        Level.exit(LEVEL_WIN_TYPE_STAR)
    end
end
