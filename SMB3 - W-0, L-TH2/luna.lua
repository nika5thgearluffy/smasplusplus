local level_dependencies_normal= require("level_dependencies_normal")
local rngTimer = 0
local rngItemState = 0
local rngItem = 1
local rngItemList = {
    [1] = "rng1",
    [2] = "rng2",
    [3] = "rng3",
}
local rngItemListInventory = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
}
local rngItemChosen = false

function onTick()
    if rngItemState == 1 then
        Text.printWP(rngTimer, 50, 50, 8)
        rngTimer = rngTimer + 1
        if rngTimer >= lunatime.toTicks(0.2) then
            triggerEvent(rngItemList[rngItem])
            Sound.playSFX(26)
            rngItem = rngItem + 1
            if rngItem > 3 then
                rngItem = 1
            end
            rngTimer = 0
        end
    end
    if rngItemState == 2 then
        rngTimer = rngTimer + 1
        if rngTimer == 1 then
            smasMapInventorySystem.addPowerUp(rngItemListInventory[rngItem], 1)
            Audio.MusicFadeOut(0, 1)
            Sound.playSFX("chest.ogg")
            Sound.playSFX("_OST/Super Mario Bros 3/Battle Mode Win.spc")
        end
        if rngTimer >= lunatime.toTicks(2.5) then
            Level.load(GameData.SMASPlusPlus.game.hubLevel)
        end
    end
end

function onEvent(eventName)
    if eventName == "startRNG" then
        rngItemState = 1
    end
    if eventName == "getmushroom" or eventName == "getfire" or eventName == "getleaf" then
        if not rngItemChosen then
            rngTimer = 0
            rngItemChosen = true
        end
        rngItemState = 2
    end
end

function onEventDirect(obj, eventName)
    if rngItemState == 2 and (eventName == "getmushroom" or eventName == "getfire" or eventName == "getleaf") then
        obj.cancelled = true
    end
end