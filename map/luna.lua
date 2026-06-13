local smwMap = require("smwMap")
local littleDialogue = require("littleDialogue")

-- Change the hub level to the world map
if GameData.SMASPlusPlus.game.hubLevel ~= Level.filename() then
    SysManager.changeMapHub(Level.filename())
end

_G.pausemenu2 = require("pausemenu2")

local playerManager = require("playermanager")
smasDateAndTime = require("smasDateAndTime")

function onStart()
    GameData.friendlyArea = true
    if SaveData.introselect == nil then
        SaveData.introselect = SaveData.introselect or 1
    end
    if SaveData.firstBootCompleted == nil then
        SaveData.firstBootCompleted = false
    end
    Misc.saveGame()
end

local mapimage

GameData.gameFirstLoaded = false

function onDraw()
    --Costume map images
    if SaveData.SMASPlusPlus.player[1].currentCostume ~= "N/A" then
        pcall (function() mapimage = (Graphics.loadImageResolved("costumes/"..playerManager.getName(player.character).."/"..player:getCostume().."/player-"..playerManager.getName(player.character)..".png")) end)
        if mapimage then
            smwMap.playerSettings.images[player.character] = mapimage
        elseif mapimage == nil then
            smwMap.playerSettings.images[player.character] = Graphics.loadImageResolved("smwMap/player-mario.png")
        end
    end
    
    
    
    --Disable drop item key
    player.keys.dropItem = false
    if Player.count() >= 2 then
        player2.keys.dropItem = false
    end
    
    --Text.print(smwMap.unlockingCurrentPath, 100, 100)
end