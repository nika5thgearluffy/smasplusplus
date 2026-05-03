local playerManager = require("playerManager")
local smasExtraSounds = require("smasExtraSounds")
local smasHud = require("smasHud")
local rng = require("base/rng")
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local smasTables = require("smasTables")
local smasFunctions = require("smasFunctions")
local littleDialogue
pcall(function() littleDialogue = require("littleDialogue") end)

local costume = {}

costume.loaded = false

costume.grenade = false
local eventsRegistered = false
local cooldown = 0
local plr

function costume.onInit(p)
    plr = p

    registerEvent(costume,"onStart")
    registerEvent(costume,"onTick")
    registerEvent(costume,"onTickEnd")
    registerEvent(costume,"onDraw")
    registerEvent(costume,"onPlayerHarm")
    registerEvent(costume,"onInputUpdate")
    registerEvent(costume,"onPlayerKill")
    registerEvent(costume,"onPostNPCKill")
    registerEvent(costume,"onNPCKill")
    registerEvent(costume,"onNPCHarm")
    registerEvent(costume,"onKeyboardPress")
    registerEvent(costume,"onControllerButtonPress")
    
    npcManager.registerEvent(291, costume, "onTickEndNPC")
    
    if not costume.loaded then
        Sound.loadCostumeSounds()
        costume.loaded = true
    end
    
    smasCharacterHealthSystem.defaultStartingHealth = 3
    smasCharacterHealthSystem.enabled = true
    smasCharacterHealthSystem.drawHearts = false
    
    Graphics.sprites.effect[998].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/effect-998.png")
    
    costume.abilitiesenabled = true
    costume.useGun1 = false
    costume.useGrenade2 = false
    costume.grenade = true
    
    if costume.grenade then
        local grenade = {
            id = 291,
            
            effect = 998,
            }
        
        npcManager.setNpcSettings(grenade)
    end
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

costume.grenadeID = 291
costume.goanimateExplosionID = 998

function costume.CheckStarAvailability()
    GameData.activateAbilityMessage = false
end

function costume.ExitFeature()
    GameData.activateAbilityMessage = false
end

local cooldown = 0
local answersRegistered = false

function costume.checkSpecialAbilityMessage(p)
    if not Misc.isPaused() then
        if SaveData.toggleCostumeAbilities then
            if (not GameData.activateAbilityMessage or GameData.activateAbilityMessage == nil) then
                if not table.icontains(smasTables._friendlyPlaces,Level.filename()) then
                    p:mem(0x172, FIELD_BOOL, false)
                    cooldown = 5
                    GameData.activateAbilityMessage = true
                    if littleDialogue then
                        if not answersRegistered then
                            littleDialogue.registerAnswer("WallOfWeaponsDialog",{text = "Yes",chosenFunction = function() Routine.run(costume.CheckStarAvailability) end})
                            littleDialogue.registerAnswer("WallOfWeaponsDialog",{text = "No",chosenFunction = function() Routine.run(costume.ExitFeature) end})
                            answersRegistered = true
                        end
                        littleDialogue.create({text = "<boxStyle smbx13><setPos 400 32 0.5 -1.4>Would you like to use The Wall of Weapons? You can only use this every 5 stars you collect.<question WallOfWeaponsDialog>", pauses = true, updatesInPause = true})
                    else
                        GameData.activateAbilityMessage = false
                    end
                    if cooldown <= 0 then
                        p:mem(0x172, FIELD_BOOL, true)
                    end
                else
                    p:mem(0x172, FIELD_BOOL, false)
                    cooldown = 10
                    if cooldown <= 0 then
                        p:mem(0x172, FIELD_BOOL, true)
                    end
                end
            end
        end
    end
end

function costume.onKeyboardPress(keyCode, repeated)
    if SaveData.toggleCostumeAbilities then
        local specialKey = SaveData.SMASPlusPlus.player[plr.idx].controls.specialKey
        if keyCode == smasTables.keyboardMap[specialKey] and not repeated then
            costume.checkSpecialAbilityMessage(plr)
        end
    end
end

function costume.onControllerButtonPress(button, playerIdx)
    if SaveData.toggleCostumeAbilities then
        if button == SaveData.SMASPlusPlus.player[playerIdx].controls.specialButton then
            costume.checkSpecialAbilityMessage(Player(playerIdx))
        end
    end
end

function costume.shootGun1(plr)
    --plr:mem(0x172, FIELD_BOOL, false) --Make sure run isn't pressed again until cooldown is over, in case
    local x = plr.x
    local y = plr.y + plr.height/2 - 5
    if (plr.direction == 1) then
        x = x + plr.width
    end
    local gunid = 266
    local gunNpc = NPC.spawn(gunid, x, y, player.section, false, true)
    costume.useGun1 = true
    gunNpc.frames = 1
    if (plr.direction == 1) then
        gunNpc.speedX = 14.5
        gunNpc.speedY = 0
    else
        gunNpc.speedX = -14.5
        gunNpc.speedY = 0
    end
    costume.useGun1 = false
    cooldown = 10
    if cooldown <= 0 then
        --plr:mem(0x172, FIELD_BOOL, true)
    end
end

function costume.shootGrenade2(plr)
    plr:mem(0x160, FIELD_WORD, 5)
    local x = plr.x
    local y = plr.y + plr.height/2 - 5
    if (plr.direction == 1) then
        x = x + plr.width
    end
    local grenadeid = 291
    local grenadeNpc = NPC.spawn(291, x, y, player.section, false, true)
    costume.useGrenade2 = true
    grenadeNpc.frames = 1
    if (plr.direction == 1) then
        grenadeNpc.speedX = 7.5
        grenadeNpc.speedY = 0.2
    else
        grenadeNpc.speedX = -7.5
        grenadeNpc.speedY = -0.2
    end
    costume.useGrenade2 = false
end

function costume.shootGrenade2Upwards(plr)
    plr:mem(0x160, FIELD_WORD, 5)
    local x = plr.x
    local y = plr.y + plr.height/2 - 5
    if (plr.direction == 1) then
        x = x + plr.width
    end
    local grenadeid = 291
    local grenadeNpc = NPC.spawn(291, x, y, player.section, false, true)
    costume.useGrenade2 = true
    grenadeNpc.frames = 1
    if (plr.direction == 1) then
        grenadeNpc.speedX = 0
        grenadeNpc.speedY = -7.5
    else
        grenadeNpc.speedX = -0
        grenadeNpc.speedY = -7.5
    end
    costume.useGrenade2 = false
end

function costume.onNPCKill(eventToken, npc, harmType)
    if npc.id == 291 then
        local hurtNPC = harmNPC(npc,HARM_TYPE_NPC)
    end
end

function costume.onPostNPCKill(npc, harmType)
    local items = table.map{9,184,185,249,14,182,183,34,169,170,277,264,996,994}
    local healitems = table.map{9,184,185,249,14,182,183,34,169,170,277,264}
    local rngkey
    if SaveData.toggleCostumeProfanity then
        rngkey = rng.randomInt(1,6)
        if items[npc.id] and Colliders.collide(plr, npc) then
            Sound.playSFX("luigi/GA-Boris/voices/items/"..rngkey..".ogg", 1, 1, 80)
        end
    else
        rngkey = rng.randomInt(3,6)
        if items[npc.id] and Colliders.collide(plr, npc) then
            Sound.playSFX("luigi/GA-Boris/voices/items/"..rngkey..".ogg", 1, 1, 80)
        end
    end
    if npc.id == 291 then
        for _,v in ipairs(NPC.get(291)) do
            local explosion = Effect.spawn(998, v.x, v.y + 35, player.section, false, true)
            SFX.play(smasCharacterGlobals.soundSettings.borisGrenadeExplodeSFX)
        end
    end
end

function costume.onDraw()
    if SaveData.toggleCostumeAbilities then
        if smasCharacterGlobals.abilitySettings.borisCanDrawGun then
            --Gun states
            if smasCharacterHealthSystem.health[plr.idx] == 1 or smasCharacterHealthSystem.health == 2 and (plr.powerup == 3) == false and (plr.powerup == 7) == false and plr.powerup == 2 then
                Graphics.sprites.npc[266].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gunbullet-1.png")
                local gun1 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gun-1.png")
                if plr.direction == -1 then
                    Graphics.drawImageWP(gun1, plr.x - camera.x - 14,  plr.y - camera.y + 10, 0, 0, 35, 28, -24)
                end
                if plr.direction == 1 then
                    Graphics.drawImageWP(gun1, plr.x - camera.x + 4,  plr.y - camera.y + 10, 0, 28, 35, 28, -24)
                end
            end
            if smasCharacterHealthSystem.health[plr.idx] == 3 and (plr.powerup == 3) == false and (plr.powerup == 7) == false and plr.powerup == 2 then
                Graphics.sprites.npc[266].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gunbullet-1.png")
                local gun2 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gun-2.png")
                if plr.direction == -1 then
                    Graphics.drawImageWP(gun2, plr.x - camera.x - 20,  plr.y - camera.y + 10, 0, 0, 65, 23, -24)
                end
                if plr.direction == 1 then
                    Graphics.drawImageWP(gun2, plr.x - camera.x - 14,  plr.y - camera.y + 10, 0, 23, 65, 23, -24)
                end
            end
            if plr.powerup == 3 or plr.powerup == 7 then
                local gun4 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gun-4.png")
                if plr:mem(0x160, FIELD_WORD) <= 34 and plr:mem(0x160, FIELD_WORD) >= 25 then
                    if plr.direction == -1 then
                        Graphics.drawImageWP(gun4, plr.x - camera.x - 45,  plr.y - camera.y, 0, 0, 45, 38, -24)
                    end
                    if plr.direction == 1 then
                        Graphics.drawImageWP(gun4, plr.x - camera.x + 25,  plr.y - camera.y, 0, 38, 45, 38, -24)
                    end
                end
            end
            if smasCharacterHealthSystem.health[plr.idx] == 3 and plr.powerup == 4 then
                Graphics.sprites.npc[266].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gunbullet-1.png")
                local gun3 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gun-3.png")
                if plr.direction == -1 then
                    Graphics.drawImageWP(gun3, plr.x - camera.x - 45,  plr.y - camera.y + 10, 0, 0, 91, 25, -24)
                end
                if plr.direction == 1 then
                    Graphics.drawImageWP(gun3, plr.x - camera.x - 15,  plr.y - camera.y + 10, 0, 25, 91, 25, -24)
                end
            end
            if smasCharacterHealthSystem.health[plr.idx] == 3 and plr.powerup == 5 and plr:mem(0x4A, FIELD_BOOL) == false then
                Graphics.sprites.npc[266].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gunbullet-2.png")
                local gun5 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/gun-5.png")
                if plr.direction == -1 then
                    Graphics.drawImageWP(gun5, plr.x - camera.x - 45,  plr.y - camera.y + 10, 0, 30, 78, 30, -24)
                end
                if plr.direction == 1 then
                    Graphics.drawImageWP(gun5, plr.x - camera.x - 10,  plr.y - camera.y + 10, 0, 0, 78, 30, -24)
                end
            end
            if smasCharacterHealthSystem.health[plr.idx] == 3 and plr.powerup == 6 then
                Graphics.sprites.npc[291].img = Graphics.loadImageResolved("costumes/luigi/GA-Boris/grenade.png")
            end
        end
    end
end

function costume.onInputUpdate()
    if SaveData.toggleCostumeAbilities and not Misc.isPaused() then
        if smasCharacterGlobals.abilitySettings.borisCanUseGun then
            if smasCharacterHealthSystem.health[plr.idx] == 1 or smasCharacterHealthSystem.health[plr.idx] == 2 and not (plr.powerup == 3) and not (plr.powerup == 7) and not (plr.powerup == 6) then
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false then
                    if plr:mem(0x26, FIELD_WORD) <= 1 and (plr.keys.down == KEYS_PRESSED) == false then
                        Sound.playSFX("costumes/luigi/GA-Boris/gunshot-1.ogg", 1, 1, 35)
                        costume.shootGun1(plr)
                    end
                end
            end
            if smasCharacterHealthSystem.health[plr.idx] == 3 and (plr.powerup == 3) == false and (plr.powerup == 7) == false and (plr.powerup == 6) == false then
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false then
                    if plr:mem(0x26, FIELD_WORD) <= 1 and (plr.keys.down == KEYS_PRESSED) == false then
                        Sound.playSFX("costumes/luigi/GA-Boris/gunshot-2.ogg", 1, 1, 35)
                        costume.shootGun1(plr)
                    end
                end
            end
            if plr.powerup == 4 then
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false then
                    if plr:mem(0x26, FIELD_WORD) <= 1 and (plr.keys.down == KEYS_PRESSED) == false then
                        Sound.playSFX("costumes/luigi/GA-Boris/gunshot-3.ogg", 1, 1, 35)
                        costume.shootGun1(plr)
                    end
                end
            end
            if plr.powerup == 5 then
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false then
                    if plr:mem(0x26, FIELD_WORD) <= 1 and (plr.keys.down == KEYS_PRESSED) == false then
                        Sound.playSFX("costumes/luigi/GA-Boris/gunshot-4.ogg", 1, 1, 35)
                        costume.shootGun1(plr)
                    end
                end
            end
        end
        if plr.powerup == 6 then
            if smasCharacterGlobals.abilitySettings.borisCanUseGrenade then
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false and (plr.keys.up == KEYS_DOWN) == false then
                    Sound.playSFX(smasCharacterGlobals.soundSettings.borisGrenadeLaunchSFX, 1, 1, 35)
                    costume.shootGrenade2(plr)
                end
                if plr.keys.run == KEYS_PRESSED and (plr.keys.altRun == KEYS_PRESSED) == false and plr.keys.up == KEYS_DOWN then
                    Sound.playSFX(smasCharacterGlobals.soundSettings.borisGrenadeLaunchSFX, 1, 1, 35)
                    costume.shootGrenade2Upwards(plr)
                end
            end
        end
    end
end

function costume.unmutebill()
    Routine.wait(0.1)
    Audio.sounds[22].muted = false
end

function costume.unmutehammer()
    Routine.wait(0.1)
    smasExtraSounds.sounds[105].sfx.volume = 1
    Audio.sounds[25].muted = false
end

local heartfull3 = Graphics.loadImageResolved("costumes/luigi/GA-Boris/heart.png")

local shootingPowerups = table.map{PLAYER_FIREFLOWER,PLAYER_ICE,PLAYER_HAMMER}
local function isShooting(p)
    return (p:mem(0x118,FIELD_FLOAT) >= 100 and p:mem(0x118,FIELD_FLOAT) <= 118 and shootingPowerups[p.powerup])
end

function costume.onTick()
    if SaveData.toggleCostumeAbilities then
        --Switching frames when shooting fireballs as Boris
        if isShooting then
            plr:setFrame(27)
        end
        
        
        
        --Boris HP Hover System
        if smasCharacterHealthSystem.health[plr.idx] == 1 then
            Graphics.drawImageWP(heartfull3, plr.x - camera.x - 28,  plr.y - camera.y - 55, -24)
        end
        if smasCharacterHealthSystem.health[plr.idx] == 2 then
            Graphics.drawImageWP(heartfull3, plr.x - camera.x - 28,  plr.y - camera.y - 55, -24)
            Graphics.drawImageWP(heartfull3, plr.x - camera.x,  plr.y - camera.y - 55, -24)
        end
        if smasCharacterHealthSystem.health[plr.idx] >= 3 then
            Graphics.drawImageWP(heartfull3, plr.x - camera.x - 28,  plr.y - camera.y - 55, -24)
            Graphics.drawImageWP(heartfull3, plr.x - camera.x,  plr.y - camera.y - 55, -24)
            Graphics.drawImageWP(heartfull3, plr.x - camera.x + 28,  plr.y - camera.y - 55, -24)
        end
        
        for index,explosion in ipairs(Animation.get(148)) do --Explosion SFX
            Audio.sounds[22].muted = true
            Routine.run(costume.unmutebill)
        end
        for index,explosion in ipairs(NPC.get(291)) do --Throw SFX
            Audio.sounds[25].muted = true
            smasExtraSounds.sounds[105].sfx.volume = 0
            Routine.run(costume.unmutehammer)
        end
    end
end

function costume.onCleanup(p)
    Sound.cleanupCostumeSounds()
    costume.grenade = false
    smasCharacterHealthSystem.defaultStartingHealth = 2
    smasCharacterHealthSystem.enabled = false
    smasCharacterHealthSystem.drawHearts = true
end

Misc.storeLatestCostumeData(costume)

return costume