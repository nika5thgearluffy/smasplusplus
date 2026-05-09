--smasFunctions.lua
--v1.0
--For more information on this library, use "smasFunctions.help()",
--or read the txt file "smasfunctions_help.txt" in the episode folder.

local smasFunctions = {}

function smasFunctions.sendToConsole(data)
    return console:println(tostring(data))
end

smasFunctions.sendToConsole("Loading SMASFunctions...")

if Misc.inEditor() and not Misc.hasFirstBooted() and SaveData.SMASPlusPlus == nil then
    Text.windowDebugSimple("Before testing SMAS++, you'll need close SMBX2R since there's important save data to make the game work.\n\nYou got this message because you tested a level from another episode and are now testing here, so this is important to not reset testing save data by accident!\n\nPlease click \"OK\" to close the engine automatically. You can from there rerun testing and the game will work just fine.")
    Misc.exitEngine()
end

_G.smasSaveDataSystem = require("smasSaveDataSystem") --Load smasSaveDataSystem as early as smasFunctions because we're wanting this to be a low-level library, when costumes are officially loaded

--Now for the base functions!
_G.Misk = require("scripts/functions/misc")
_G.Filed = require("scripts/functions/file")
_G.Img = require("scripts/functions/img")
_G.Sound = require("scripts/functions/sound")
_G.Tabled = require("scripts/functions/table")
_G.SysManager = require("scripts/functions/sysmanager")
_G.Time = require("scripts/functions/time")
_G.Playur = require("scripts/functions/player")
_G.Npc = require("scripts/functions/npc")
_G.Screen = require("scripts/functions/camera")
_G.Evento = require("scripts/functions/events")
_G.Effectx = require("scripts/functions/effect")
_G.Collisionz = require("scripts/functions/collision")
_G.Liquidz = require("scripts/functions/liquid")
_G.Levul = require("scripts/functions/level")

SysManager.sendToConsole("Loaded SMASFunctions.")

--This is used for spitting out help documentation for these scripts.
function smasFunctions.help()
    Misc.richDialog("SMASFunctions Help Dialog Box", File.readFile("smasFunctions_help.txt"), true)
end

_G.smasCharacterGlobals = require("smasCharacterGlobals")
_G.smasCharacterCostumes = require("smasCharacterCostumes")
_G.smasCharacterHealthSystem = require("smasCharacterHealthSystem")
_G.animationPal = require("animationPal")

return smasFunctions