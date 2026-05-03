local smasFunctions = require("smasFunctions")

local costume = {}

costume.loaded = false

local pm = require("playerManager")
local smasExtraSounds = require("smasExtraSounds")
local smasTables = require("smasTables")

local plr

function costume.onInit(p)
    registerEvent(costume,"onTick")
    registerEvent(costume,"onDraw")
    registerEvent(costume,"onInputUpdate")
    registerEvent(costume,"onPostNPCKill")
    registerEvent(costume,"onPlayerKill")
    registerEvent(costume,"onPlayerHarm")
    registerEvent(costume,"onKeyboardPress")
    registerEvent(costume,"onControllerButtonPress")
    if not costume.loaded then
        Sound.loadCostumeSounds()
        costume.loaded = true
    end
    plr = p
end

local pacmanpowerup6 = Graphics.loadImageResolved("costumes/toad/PacMan-Arrangement-PacMan/toad-6.png")

local moving = false
local running = false

local teleportmode = false
local timetostopteleport = 130
local pelletnumber = 1

function costume.onDraw()
    if teleportmode then
        
    end
end

function costume.onPlayerHarm(e)
    if teleportmode then
        e.cancelled = true
    end
end

function costume.onPlayerKill(e)
    if teleportmode then
        e.cancelled = true
    end
end

function costume.onTick()
    if not moving then
        plr.speedX = 0
    elseif moving then
        if not running then
            if plr.keys.left == KEYS_DOWN then
                plr.speedX = -4
            end
            if plr.keys.right == KEYS_DOWN then
                plr.speedX = 4
            end
        elseif running then
            if plr.keys.left == KEYS_DOWN then
                plr.speedX = -6
            end
            if plr.keys.right == KEYS_DOWN then
                plr.speedX = 6
            end
        end
    end
    if plr.powerup ~= 3 then
        running = false
    end
    if teleportmode then
        timetostopteleport = timetostopteleport - 1
        plr.forcedState = FORCEDSTATE_INVISIBLE
        if timetostopteleport >= 5 then
            Graphics.drawImageToSceneWP(pacmanpowerup6, plr.x - 36, plr.y - 40, 600, 400, 100, 100, 1, -25)
        end
        plr:mem(0x140, FIELD_WORD, 20)
        if plr.keys.up == KEYS_DOWN then
            plr.y = plr.y - 4
        end
        if plr.keys.down == KEYS_DOWN then
            plr.y = plr.y + 4
        end
        if plr.keys.left == KEYS_DOWN then
            plr.x = plr.x - 4
        end
        if plr.keys.right == KEYS_DOWN then
            plr.x = plr.x + 4
        end
        if timetostopteleport <= 2 then
            plr.forcedState = FORCEDSTATE_NONE
        end
        if timetostopteleport <= 0 then
            timetostopteleport = 0
            teleportmode = false
        end
    end
    if timetostopteleport == 1 then
        Sound.playSFX("toad/PacMan-Arrangement-PacMan/teleport-end.ogg")
    end
    if not teleportmode then
        
    end
    if plr:isGroundTouching() and (plr.forcedState == FORCEDSTATE_INVISIBLE) == false then
        timetostopteleport = 130
    end
    if plr.powerup == 5 then
        Defines.jumpheight = 30
    else
        Defines.jumpheight = 20
    end
end

function costume.onPostNPCKill(npc, harmType)
    local coins = table.map{10,33,88,103,138,251,252,253,258,528}
    if coins[npc.id] and Colliders.collide(plr, npc) then
        if pelletnumber == 1 then
            pelletnumber = 2
            smasExtraSounds.sounds[14].sfx = Audio.SfxOpen(Misc.resolveSoundFile("costumes/toad/PacMan-Arrangement-PacMan/pellet-2.ogg"))
        elseif pelletnumber == 2 then
            pelletnumber = 1
            smasExtraSounds.sounds[14].sfx = Audio.SfxOpen(Misc.resolveSoundFile("costumes/toad/PacMan-Arrangement-PacMan/pellet-1.ogg"))
        end
        if plr.powerup == 7 then
            SaveData.SMASPlusPlus.hud.coinsClassic = SaveData.SMASPlusPlus.hud.coinsClassic + 1
        end
    end
end

function costume.onInputUpdate()
    if not Misc.isPaused() then
        --Normal movement
        if plr.keys.left == KEYS_DOWN then
            moving = true
        elseif plr.keys.right == KEYS_DOWN then
            moving = true
        elseif plr.keys.left == KEYS_UP then
            moving = false
        elseif plr.keys.right == KEYS_UP then
            moving = false
        end
        --Fire flower dash movement
        if plr.powerup == 3 and plr.keys.run == KEYS_DOWN then
            running = true
        elseif plr.powerup == 3 and plr.keys.run == KEYS_UP then
            running = false
        end
        --Dash SFX
        if plr.powerup == 3 and plr.keys.run == KEYS_PRESSED and moving and plr:isOnGround() then
            if table.icontains(smasTables._noLevelPlaces,Level.filename()) == false then
                Sound.playSFX("toad/PacMan-Arrangement-PacMan/dash.ogg")
            end
        end
        --Fireball redo
        if plr.powerup == 3 and plr.keys.run == KEYS_PRESSED and not plr.keys.down == KEYS_DOWN then
            plr:mem(0x172, FIELD_BOOL, false)
            local fireballnpc = NPC.spawn(13, plr.x, plr.y, plr.section, false, true)
            if table.icontains(smasTables._noLevelPlaces,Level.filename()) == false then
                Sound.playSFX(18)
            end
            if plr.direction == 1 then
                fireballnpc.speedX = 10
                fireballnpc.speedY = -4
            elseif plr.direction == -1 then
                fireballnpc.speedX = -10
                fireballnpc.speedY = -4
            end
        end
        --Higher jump
        if plr.powerup == 4 and plr.keys.jump == KEYS_PRESSED and plr:mem(0x00, FIELD_BOOL) == true then
            plr:mem(0x00, FIELD_BOOL, false)
            if table.icontains(smasTables._noLevelPlaces,Level.filename()) == false then
                Sound.playSFX("toad/PacMan-Arrangement-PacMan/double-jump.ogg")
            end
            plr.speedY = -12
        end
        --Iceball redo
        if plr.powerup == 7 and plr.keys.run == KEYS_PRESSED and not plr.keys.down == KEYS_DOWN then
            plr:mem(0x172, FIELD_BOOL, false)
            local iceballnpc = NPC.spawn(265, plr.x, plr.y, plr.section, false, true)
            if table.icontains(smasTables._noLevelPlaces,Level.filename()) == false then
                Sound.playSFX(93)
            end
            if plr.direction == 1 then
                iceballnpc.speedX = 10
                iceballnpc.speedY = -4
            elseif plr.direction == -1 then
                iceballnpc.speedX = -10
                iceballnpc.speedY = -4
            end
        end
    end
end

function teleportingability(p)
    --Teleport (Only active for 2 seconds)
    if p.powerup == 6 then
        if table.icontains(smasTables._noLevelPlaces,Level.filename()) == false then
            if timetostopteleport >= 1 then
                Sound.playSFX("toad/PacMan-Arrangement-PacMan/teleport-start.ogg")
                teleportmode = true
            end
        end
    end
    if p.powerup == 6 and not teleportmode then
        p:mem(0x172, FIELD_BOOL, false)
    end
end

function costume.onKeyboardPress(keyCode, repeated)
    local specialKey = SaveData.SMASPlusPlus.player[plr.idx].controls.specialKey
    if keyCode == smasTables.keyboardMap[specialKey] and not repeated then
        if not teleportmode then
            teleportingability(plr)
        end
    end
end

function costume.onControllerButtonPress(button, playerIdx)
    if button == SaveData.SMASPlusPlus.player[playerIdx].controls.specialButton then
        if not teleportmode then
            teleportingability(plr)
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