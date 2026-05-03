local costume = {}
local klonoa = API.load("characters/klonoaa");
local colliders = require("colliders")
local playerManager = require("playerManager");
local smasExtraSounds = require("smasExtraSounds")
local smasFunctions = require("smasFunctions")

costume.loaded = false
local plr

function costume.onInit(p)
    plr = p
    registerEvent(costume, "onDraw")
    registerEvent(costume, "onTick")
    klonoa.flapAnimSpeed=3
    ringbox = colliders.Box(0, 0, 32, 32)
    if not costume.loaded then
        Sound.loadCostumeSounds()
        costume.loaded = true
    end
end

function costume.onTick()
    ringbox.y = plr.y + 0
end

function costume.onDraw()
    for _,v in ipairs(Animation.get(152)) do
        v.height = 64
    end
    
    if(plr.holdingNPC) then
        plr.holdingNPC.x = plr.x-65536
        plr.holdingNPC.y = plr.y-65536
    end
end

function costume.onCleanup(playerObject)
    Sound.cleanupCostumeSounds()
    
    klonoa.flapAnimSpeed = 6
    ringbox = colliders.Box(0, 0, 32, 32)
    ringbox.y = playerObject.y + 16
end

Misc.storeLatestCostumeData(costume)

return costume