-- Change the hub level to the e-Reader hub
if GameData.SMASPlusPlus.game.hubLevel ~= Level.filename() then
    SysManager.changeMapHub(Level.filename())
end

smasBooleans.isInHub = true

_G.pausemenu2 = require("pausemenu2")

function onDraw()
    -- Draw the black borders
    smasBorderSystem.drawBorder()
end

function onPostWarpEnter(warp, plr)
    -- Change back to the map if exiting the e-Reader hub
    if warp.levelFilename == "map.lvlx" then
        SysManager.changeMapHub("map.lvlx")
    end
end