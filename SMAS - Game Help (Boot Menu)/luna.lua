Graphics.activateHud(false)
Misc.saveGame()

local littleDialogue = require("littleDialogue")
local warpTransition = require("warpTransition")

warpTransition.musicFadeOut = false
warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
warpTransition.sameSectionTransition = warpTransition.TRANSITION_NONE
warpTransition.crossSectionTransition = warpTransition.TRANSITION_FADE
warpTransition.activateOnInstantWarps = false
warpTransition.TRANSITION_FADE = 1
warpTransition.TRANSITION_SWIRL = 1
warpTransition.TRANSITION_IRIS_OUT = 1
warpTransition.TRANSITION_PAN = 6

local playerManager = require("playerManager")
local textplus = require("textplus")
local autoscroll = require("autoscroll")
smasDateAndTime = require("smasDateAndTime")
local Routine = require("routine")
local smasExtraSounds = require("smasExtraSounds")
local anothercurrency = require("ShopSystem/anothercurrency")

local dying = false;
local deathVisibleCount = 198;
local deathTimer = deathVisibleCount;
local earlyDeathCheck = 3;
local cooldown = 0

local timer_deathTimer;
local deltaTime = Routine.deltaTime
local deathDelay = lunatime.toTicks(1.2)
local deathTimer = deathDelay

local costumes = {}

local dependencies = {}

function p1teleportdoor()
    Routine.waitFrames(30)
    player:mem(0x140,FIELD_WORD,100)
    player2:mem(0x140,FIELD_WORD,100)
    Player(2):teleport(Player(1).x - 32, Player(1).y - 32, bottomCenterAligned)
end

function p2teleportdoor()
    Routine.waitFrames(30)
    player:mem(0x140,FIELD_WORD,100)
    player2:mem(0x140,FIELD_WORD,100)
    Player(1):teleport(Player(2).x - 32, Player(2).y - 32, bottomCenterAligned)
end

function dependencies.onInitAPI()
    registerEvent(dependencies, "onStart")
    registerEvent(dependencies, "onLoad")
    registerEvent(dependencies, "onTick")
    registerEvent(dependencies, "onDraw")
    registerEvent(dependencies, "onCameraUpdate")
    registerEvent(dependencies, "onInputUpdate")
end

function dependencies.onStart()
    local character = player.character;
    local costumes = playerManager.getCostumes(player.character)
    local currentCostume = player:getCostume()
    
    local costumes
    mm = require("Characters/megaman");
    mm.playIntro = false;
    playerphysicspatch = require("playerphysicspatch")
    kindHurtBlock = require("kindHurtBlock")
    littleDialogue.defaultStyleName = "smw"
end

function dependencies.onTick()
    if Player.count() >= 2 then
        if Player(1).forcedState == FORCEDSTATE_PIPE then
            if Player(1).forcedTimer >= 70 and not Misc.isPaused() then
                player:mem(0x140,FIELD_WORD,100)
                player2:mem(0x140,FIELD_WORD,100)
                Player(2):teleport(player.x - 32, player.y - 32, bottomCenterAligned)
            end
        end
        if Player(2).forcedState == FORCEDSTATE_PIPE then
            if Player(2).forcedTimer >= 70 and not Misc.isPaused() then
                player:mem(0x140,FIELD_WORD,100)
                player2:mem(0x140,FIELD_WORD,100)
                Player(1):teleport(Player(2).x - 32, Player(2).y - 32, bottomCenterAligned)
            end
        end
    end
    if Player.count() >= 2 then
        if Player(1).forcedState == FORCEDSTATE_DOOR then
            if Player(1).forcedTimer == 1 then
                Routine.run(p1teleportdoor)
            end
        end
        if Player(2).forcedState == FORCEDSTATE_DOOR then
            if Player(2).forcedTimer == 1 then
                Routine.run(p2teleportdoor)
            end
        end
    end
    if player.character == CHARACTER_SNAKE then
        Graphics.activateHud(true)
    end
    if player.character == CHARACTER_NINJABOMBERMAN then
        Graphics.activateHud(true)
    end
    local character = player.character;
    local costumes = playerManager.getCostumes(player.character)
    local currentCostume = player:getCostume()

    local costumes
    if table.icontains(smasTables.__smb2Levels,Level.filename()) == true then
        if NPC.config[274].score == 11 then
            Sound.playSFX(147)
            NPC.config[274].score = 6
        end
    elseif Level.filename() then
        if NPC.config[274].score == 11 then
            NPC.config[274].score = 6 --Nothing plays btw, just resets
        end
    end
end

Cheats.register("fcommandssuck",{
    onActivate = (function()
        Defines.player_hasCheated = false
        malcwarp = require("malcwarp")
        thecostume = require("thecostume")
        exitcommands = require("exitcommands")
        commandlist = require("commandlist")
        return true -- this makes the cheat not toggleable
    end),
    flashPlayer = true,activateSFX = "_OST/_Sound Effects/hits1.ogg",
})

return dependencies