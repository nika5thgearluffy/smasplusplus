local pm = require("playerManager")
local smasExtraSounds = require("smasExtraSounds")
local smasFunctions = require("smasFunctions")

local costume = {}

costume.loaded = false
local plr

function costume.onInit(p)
    plr = p
    registerEvent(costume,"onPlayerHarm")
    registerEvent(costume,"onInputUpdate")
    registerEvent(costume,"onTick")
    registerEvent(costume,"onDraw")
    registerEvent(costume,"onKeyboardPress")
    registerEvent(costume,"onControllerButtonPress")
    if not costume.loaded then
        Sound.loadCostumeSounds()
        costume.loaded = true
    end
    
    Defines.player_walkspeed = 4
    Defines.player_runspeed = 5
    Defines.jumpheight = 25
    Defines.jumpheight_bounce = 25
    Defines.projectilespeedx = 7.0
    Defines.player_grav = 0.44
    
    costume.abilitesenabled = true
end

local function harmNPC(npc,...) -- npc:harm but it returns if it actually did anything
    local oldKilled     = npc:mem(0x122,FIELD_WORD)
    local oldProjectile = npc:mem(0x136,FIELD_BOOL)
    local oldHitCount   = npc:mem(0x148,FIELD_FLOAT)
    local oldImmune     = npc:mem(0x156,FIELD_WORD)
    local oldID         = npc.id
    local oldSpeedX     = npc.speedX
    local oldSpeedY     = npc.speedY

    npc:harm(...)

    return (
           oldKilled     ~= npc:mem(0x122,FIELD_WORD)
        or oldProjectile ~= npc:mem(0x136,FIELD_BOOL)
        or oldHitCount   ~= npc:mem(0x148,FIELD_FLOAT)
        or oldImmune     ~= npc:mem(0x156,FIELD_WORD)
        or oldID         ~= npc.id
        or oldSpeedX     ~= npc.speedX
        or oldSpeedY     ~= npc.speedY
    )
end

function costume.swooshattack(p)
    if (plr.powerup ~= 5) then
        p:mem(0x140, FIELD_WORD, 0) --Blinker is 0
        p:mem(0x120, FIELD_BOOL, false) --Making sure Alt Jump isn't pressed until after the attack
        p:mem(0x172, FIELD_BOOL, false) --No run either, in case
        Sound.playSFX(33)
        if p.direction == 1 then
            p.speedX = 8
            p.speedY = -3
        elseif p.direction == -1 then
            p.speedX = -8
            p.speedY = -3
        end
        lungingTicks = 0
        lunging = true
        if lungingTicks > 20 then
            lunging = false
        end
    end
end

function costume.onDraw()
    if SaveData.toggleCostumeAbilities then
        if lunging then
            plr:playAnim({13,14,15,16}, 4, false, -25)
        end
        --local isJumping = player:mem(0x11C, FIELD_WORD) --Jumping detection
        local isUnderwater = plr:mem(0x36, FIELD_BOOL) --Underwater detection
        --if isJumping and p:mem(0x14, FIELD_WORD) <= 0 and not isUnderwater and not player:isOnGround() then --Checks to see if the player is jumping...
            --p:setFrame(12)
        --end
    end
end

function costume.onTick()
    if SaveData.toggleCostumeAbilities then
        local hitNPCs = Colliders.getColliding{a = plr, b = hitNPCs, btype = Colliders.NPC}
        if lunging then
            plr.keys.left = false
            plr.keys.right = false
            plr.keys.up = false
            plr.keys.down = false
            plr.keys.jump = false
            plr.keys.altJump = false
            plr.keys.run = false
            for _,npc in ipairs(hitNPCs) do
                if npc ~= v and npc.id > 0 then
                    -- Hurt the NPC, and make sure to not give the automatic score
                    local oldScore = NPC.config[npc.id].score
                    NPC.config[npc.id].score = 0
                    NPC.config[npc.id].score = oldScore
                    
                    local hurtNPC = harmNPC(npc,HARM_TYPE_NPC)
                    if hurtNPC then
                        Misc.givePoints(0,{x = npc.x+npc.width*1.5,y = npc.y+npc.height*0.5},true)
                    end
                end
            end
            lungingTicks = lungingTicks + 1

            plr.x = plr.x + 4 * plr.direction

            if lungingTicks > 15 then
                lunging = false
                plr:mem(0x140, FIELD_WORD, 50)
            end
        end
    end
end

function costume.onPlayerHarm(e, p)
    if SaveData.toggleCostumeAbilities then
        if lunging then
            e.cancelled = true
            return
        end
    end
end

function costume.onKeyboardPress(keyCode, repeated)
    if SaveData.toggleCostumeAbilities then
        local specialKey = SaveData.SMASPlusPlus.player[plr.idx].controls.specialKey
        if keyCode == smasTables.keyboardMap[specialKey] and not repeated then
            costume.swooshattack(plr)
        end
    end
end

function costume.onControllerButtonPress(button, playerIdx)
    if SaveData.toggleCostumeAbilities then
        if button == SaveData.SMASPlusPlus.player[playerIdx].controls.specialButton then
            costume.swooshattack(Player(playerIdx))
        end
    end
end

function costume.onInputUpdate()
    if SaveData.toggleCostumeAbilities then
        if plr.keys.run == KEYS_DOWN then
            plr:mem(0x168, FIELD_FLOAT, 10)
        else
            plr:mem(0x168, FIELD_FLOAT, 0)
        end
    end
end

function costume.onCleanup(p)
    Sound.cleanupCostumeSounds()
    
    Defines.jumpheight = 20
    Defines.player_walkspeed = 3
    Defines.player_runspeed = 6
    Defines.jumpheight_bounce = 32
    Defines.projectilespeedx = 7.1
    Defines.player_grav = 0.4
end

Misc.storeLatestCostumeData(costume)

return costume