--[[
    SUPER MARIO ALL-STARS++
    By "The Sun God: Nika"

    Here's the starting code that loads it all. How'd I do?

    -- Total Stars --
    SMB1 = 43 (Done!)
    SMB2 = 22 (Done!)
    SMB3 = TBD (Done! World e is a wip though)
    SMBLL (Optional) = 52 (Done!)
    SMW = TBD (WIP)
    SML1 (Optional) = TBD (WIP)
    SML2 (Optional) = TBD (WIP)
    Lava Lands = 5 (WIP)
    Side Quest (Optional) = TBD (WIP)
    True Ending = 1 (WIP)
]]

function SysManagerSendToConsole(data)
    return console:println(tostring(data))
end

SysManagerSendToConsole("Super Mario All-Stars++ loading initated.")

_G.smasSaveDataSystem = require("smasSaveDataSystem")
_G.smasFunctions = require("smasFunctions")

_G.smasWeather = require("smasWeather")

if GameData.gameFirstLoaded == nil then
    GameData.gameFirstLoaded = true
    if Misc.inEditor() then
        GameData.gameFirstLoaded = false
    end
end

--Make sure we aren't running Beta 3 and below before we actually start...
if (SMBX_VERSION < VER_BETA4_PATCH_3) then
    Text.windowDebugSimple("Hey wait a minute! At least SMBX2 Beta 4 Patch 3 is required to play this game. Please download it from the official site by going to https://codehaus.wohlsoft.ru/. Until then, you can't run this episode. Sorry about that!")
    Misc.exitEngine()
end

--Make sure to save the current episode folder and save slot numbers to it's own GameData variables to prevent the broken 1.3 launcher from launching the episode...
GameData.__EpisodeFolder = Misc.episodePath()
GameData.__SaveSlot = Misc.saveSlot()

--Make sure we warn the user to upgrade the legacy save data while we can...
if mem(0x00B251E0, FIELD_WORD) >= 1 then
    SysManager.sendToConsole("Legacy star count greater than 1! Assuming we're loading a save file from Demo 2 and below...")
    if GameData.warnUserAboutOldStars == nil then
        GameData.warnUserAboutOldStars = true
    end
    if GameData.warnUserAboutOldStars then
        Misc.dialogSimple("It looks like your using a legacy save file from before Demo 3 (Or before April 10th, 2022). You'll need to migrate your save data as soon as you boot the game! That way your data can still be used in the future. Please migrate your save while you can!")
        GameData.warnUserAboutOldStars = false
    end
end

--Decrease legacy score to 0
if Misc.score() > 0 then
    Misc.score(-Misc.score()) 
end

-- Set the window title and icon
if Misc.setWindowTitle ~= nil then
    SysManager.sendToConsole("Window title set.")
    Misc.setWindowTitle("Super Mario All-Stars++")
end
if Misc.setWindowIcon ~= nil then
    SysManager.sendToConsole("Window icon set.")
    Misc.setWindowIcon(Graphics.loadImageResolved("graphics/icon/icon.png"))
end

--Register some custom global event handlers...
SysManager.sendToConsole("Registering global event handlers...")
Misc.LUNALUA_EVENTS_TBL["onPlaySFX"] = true
Misc.LUNALUA_EVENTS_TBL["onPostPlaySFX"] = true
Misc.LUNALUA_EVENTS_TBL["onChangeMusic"] = true
Misc.LUNALUA_EVENTS_TBL["onPostChangeMusic"] = true
Misc.LUNALUA_EVENTS_TBL["onPOWSMAS"] = true
Misc.LUNALUA_EVENTS_TBL["onPostPOWSMAS"] = true
Misc.LUNALUA_EVENTS_TBL["onEarthquake"] = true
Misc.LUNALUA_EVENTS_TBL["onPostEarthquake"] = true
Misc.LUNALUA_EVENTS_TBL["onCheatActivate"] = true
if SMBX_VERSION == VER_SEE_MOD then
    Misc.LUNALUA_EVENTS_TBL["onCheatDeactivate"] = true
end
Misc.LUNALUA_EVENTS_TBL["onWarpToOtherLevel"] = true
Misc.LUNALUA_EVENTS_TBL["onWarpBegin"] = true
Misc.LUNALUA_EVENTS_TBL["onCharacterChangeSMAS"] = true
Misc.LUNALUA_EVENTS_TBL["onCharacterAlterationChange"] = true

--Now, before we get started, we require the most important libraries on the top.
SysManager.sendToConsole("Loading important libraries...")

--SMAS specific functions need to be required first:
_G.smasGlobals = require("smasGlobals")
_G.smasMemoryAddresses = require("smasMemoryAddresses")
_G.smasKeySystem = require("smasKeySystem")
_G.smasHud = require("smasHud")
--_G.smasHud2 = require("smasHud2")
_G.smasAudioVolumeSystem = require("smasAudioVolumeSystem")
_G.smasAnimationSystem = require("smasAnimationSystem")
_G.smasVerboseMode = require("smasVerboseMode")
_G.smasBooleans = require("smasBooleans")
_G.smasTables = require("smasTables")
_G.smasCheats = require("smasCheats")
_G.smasStarSystem = require("smasStarSystem")
_G.smasNoTurnBack = require("smasNoTurnBack")
_G.smasSpencerFollower = require("smasSpencerFollower")
_G.smasCharacterChanger = require("smasCharacterChanger")
_G.smasAlterationSystem = require("smasAlterationSystem")
_G.smasFireballs = require("smasFireballs")
_G.smasPWing = require("smasPWing")
_G.smasExtraSounds = require("smasExtraSounds")
_G.smasMapInventorySystem = require("smasMapInventorySystem")
_G.smasWarpSystem = require("smasWarpSystem")

--Then we do everything else.
_G.smwMap = require("smwMap")
_G.classicEvents = require("classiceventsmod")
_G.extraNPCProperties = require("extraNPCProperties")
_G.cursor = require("cursor")
_G.Timer = require("timer-mod")
_G.autoscrolla = require("autoscrolla")

-- Create the user files directory if it doesn't exist yet...
if not File.folderExists(SysManager.getUserFilesSMASPlusPlusDirectory()) then
    File.createFolder(SysManager.getUserFilesSMASPlusPlusDirectory())
end

--This will add multiple player arguments.
for i = 1,200 do
    _G["player".. i] = Player(i)
end

--Then we fix up some functions that the X2 team didn't fix yet (If they released a patch and fixed a certain thing, the code will be removed from here).
if (VER_BETA4_PATCH_4_1 ~= nil) and (SMBX_VERSION <= VER_BETA4_PATCH_4_1 or SMBX_VERSION == VER_SEE_MOD) then
    function Player:teleport(x, y, bottomCenterAligned) --This fixes 2nd player teleporting, when using player/player2:teleport. This will be removed after a few months when the next SMBX2 patch releases (The next patch will fix this), to make sure people upgrade on time.
        -- If using bottom center aligned coordinates, handle that sensibly
        if bottomCenterAligned then
            x = x - (self.width * 0.5)
            y = y - self.height
        end

        -- Move the player and update section, including music
        local oldSection = self.section
        local newSection = Section.getIdxFromCoords(x, y)
        self.x, self.y = x, y
        if (newSection ~= oldSection) then
            self.section = newSection
            playMusic(newSection)
        end
    end
end

--Now that everything has been loaded, start loading the medium important stuff

SysManager.sendToConsole("Loading medium important libraries...")

_G.transplate = require("transplate")
_G.globalgenerals = require("globalgenerals") --Most important library of all. This loads general stuff for levels.
_G.repll = require("repll") --Custom sound command line, for not only testing in the editor, but for an additional clear history command
_G.rng = require("base/rng") --Load up rng for etc. things
if SaveData.speedrunMode then
    SysManager.sendToConsole("Speedrun mode enabled! Loading speedrun libraries...")
    speedruntimer = require("speedruntimer") -- Speedrun Timer Script on World Map (from MaGLX3 episode)
    inputoverlay = require("inputoverlay") -- Input Overlay (GFX by Wohlstand for TheXTech, script by me)
end

local npc_APIs = {
    "waternpcplusExt",
};
for _,v in ipairs(npc_APIs) do
    require("extra-settings/"..v);
end

local loadactivate = true
SysManager.sendToConsole("Loading Steve and SMW2 Yoshi characters...")
local steve = require("steve")
local yoshi = require("yiYoshi/yiYoshi")
local playerManager = require("playermanager") --Load up this to change Ultimate Rinka and Ninja Bomberman to Steve and Yoshi (You can still use UR and NB, check out the Toad costumes)
--These will need to be overwritten over the original libraries, because we're fixing graphics/bugs from these characters.
SysManager.sendToConsole("Overriding original character libraries...")
playerManager.overrideCharacterLib(CHARACTER_MEGAMAN,require("characters/megamann"))
playerManager.overrideCharacterLib(CHARACTER_SNAKE,require("characters/snakey"))
playerManager.overrideCharacterLib(CHARACTER_BOWSER,require("characters/bowserr"))
playerManager.overrideCharacterLib(CHARACTER_ROSALINA,require("characters/rosalinaa"))
playerManager.overrideCharacterLib(CHARACTER_SAMUS,require("characters/samuss"))
playerManager.overrideCharacterLib(CHARACTER_WARIO,require("characters/warioo"))
playerManager.overrideCharacterLib(CHARACTER_ZELDA,require("characters/zeldaa"))
playerManager.overrideCharacterLib(CHARACTER_KLONOA,require("characters/klonoaa"))
playerManager.overrideCharacterLib(CHARACTER_UNCLEBROADSWORD,require("characters/unclebroadswordd"))
playerManager.overrideCharacterLib(CHARACTER_ULTIMATERINKA,require("steve"))
Graphics.sprites.effect[152].img = Graphics.loadImageResolved("graphics/smbx2og/effect/effect-152.png")
Graphics.sprites.effect[153].img = Graphics.loadImageResolved("graphics/smbx2og/effect/effect-153.png")
Graphics.sprites.ultimaterinka[player.powerup].img = Graphics.loadImageResolved("graphics/smbx2og/character/ultimaterinka-2.png")

Progress.value = SaveData.SMASPlusPlus.levels.starCount --Every level load, we will save the total stars used with the launcher

if SaveData.SMASPlusPlus.game.username == nil then --This is for adding the player name to the launcher, aside from the total stars used
    Progress.savename = "Player" --If the player name is nil, use "Player" instead
else
    Progress.savename = SaveData.SMASPlusPlus.game.username --Or else just use the SaveData variable if it exists
end

--Make sure the warp door system doesn't get active until onStart saves the original count first...
local warpstaractive = false

--Now load the loading sound file!
local loadingsoundFile = Misc.resolveSoundFile("loadscreen.ogg")

--Placing in levels onto a table that'll prevent the loading sound from playing
smasTables._noLoadingSoundLevels = {
    "SMAS - Start.lvlx",
    "SMAS - Raca's World (Part 0).lvlx",
    "SMAS - Raca's World (Part 1).lvlx",
    "map.lvlx"
}

--Now use onLoad to play the loading sound...
function onLoad()
    if not Misc.inEditor() and not table.icontains(smasTables._noLoadingSoundLevels,Level.filename()) and loadactivate then --If luna errors during testing in the editor, this will be useful to not load the audio to prevent the audio from still being played until the engine is terminated
        SysManager.sendToConsole("Loading sound playing!")
        loadingsoundchunk = Audio.SfxOpen(loadingsoundFile)
        loadingSoundObject = Audio.SfxPlayObj(loadingsoundchunk, -1)
        fadetolevel = true
    end
end

function onLoop() --I'm sorry for using deprecated crap, this is used specifically for stopping the loading sound when erroring
    if fadetolevel then
        if unexpected_condition then
            pcall(function() loadactivate = false fadetolevel = false loadingSoundObject:Stop() end)
        end
    end
end

function onStart() --Now do onStart...
    --From earlier, if the GameData info is mismatched, run a dialog and afterward exit the engine
    if GameData.__EpisodeFolder ~= Misc.episodePath() and GameData.__SaveSlot ~= Misc.saveSlot() then
        Misc.dialog("Uh oh... it looks like you launched the episode using the broken SMBX 1.3 Launcher. Please use the SMBX2 launcher to launch the episode. Until then, you can't run this episode. Sorry about that!")
        Misc.exitEngine()
    end
    --Below will start the star door system
    warpstaractive = true
    --Do the weather SaveData additions
    if SaveData.SMASPlusPlus.misc.weatherForecast == nil then
        SaveData.SMASPlusPlus.misc.weatherForecast = weatherControl
    end
    --Calculate Easter Sunday
    Time.easterYear(os.date("*t").year)
    if SaveData.dateplayedyesterday == nil then
        yesterdaynumber = os.date("*t").day - 1
        SaveData.dateplayedyesterday = yesterdaynumber
    end
    if SaveData.dateplayedtomorrow == nil then
        tomorrownumber = os.date("*t").day + 1
        SaveData.dateplayedtomorrow = tomorrownumber
    end
    smasWeather.doWeatherUpdate()
    if not Misc.inEditor() and not table.icontains(smasTables._noLoadingSoundLevels,Level.filename()) then --Make sure to fade out the loading sound when onStart is active...
        fadetolevel = false
        if loadactivate then
            loadingSoundObject:FadeOut(800)
            loadactivate = false
        end
        GameData.gameFirstLoaded = false --Because what if we load into a level instead of the boot menu?
    end
    if SaveData.SMASPlusPlus.game.onePointThreeModeActivated == 0 then --Migrate old saves from pre-March 2022 if there are any.
        SaveData.SMASPlusPlus.game.onePointThreeModeActivated = false
    end
    if SaveData.SMASPlusPlus.game.onePointThreeModeActivated == 1 then
        SaveData.SMASPlusPlus.game.onePointThreeModeActivated = true
    end
    if SaveData.firstBootCompleted == 0 then
        SaveData.firstBootCompleted = false
    end
    if SaveData.firstBootCompleted == 1 then
        SaveData.firstBootCompleted = true
    end
    if (not SaveData.SMASPlusPlus.game.onePointThreeModeActivated) and not Misc.inEditor() and (SaveData.currentCharacter ~= nil and SaveData.SMASPlusPlus.player[1].currentCostume ~= nil) then
        player.character = SaveData.currentCharacter
        player.setCostume(SaveData.currentCharacter, SaveData.SMASPlusPlus.player[1].currentCostume, false)
    end
    if Misc.inEditor() then
        if SysManager.isOutsideOfUnplayeredAreas() then
            GameData.gameFirstLoaded = false
        end
    end
end

local cameratimer = 10
local cameratimer2 = 10
if GameData.__gifIsRecording == nil then
    GameData.__gifIsRecording = false
end
local gifRecordTimer = 0

local inputhudbg = Graphics.loadImageResolved("inputhud/inputhud.png")
local controlkey = Graphics.loadImageResolved("inputhud/control.png")
local jumpkey = Graphics.loadImageResolved("inputhud/jump.png")
local altjumpkey = Graphics.loadImageResolved("inputhud/altjump.png")
local runkey = Graphics.loadImageResolved("inputhud/run.png")
local altrunkey = Graphics.loadImageResolved("inputhud/altrun.png")
local bottomkeys = Graphics.loadImageResolved("inputhud/bottomkey.png")

function onGIFRecord(noSFXs, isActive) -- This will replace the GIF sounds to custom ones
    noSFXs.cancelled = true
    if Misc.isRecordingGIF() then
        Sound.playSFX("gif-start.ogg")
    else
        Sound.playSFX("gif-end.ogg")
    end
end

function onScreenCapture(noSFXs) -- This will replace the snapshot sound to a custom one
    noSFXs.cancelled = true
    Sound.playSFX("snapshot.ogg")
end

function onLetterboxToggle(isToggled)
    if isToggled then
        Sound.playSFX("letterbox-enable.ogg")
    else
        Sound.playSFX("letterbox-disable.ogg")
    end
end

function onDraw()
    -- Do this so that the PFP would need to be removed if non-existant
    --[[if SaveData.SMASPlusPlus.game.pfp ~= nil and Misc.resolveFile(SaveData.SMASPlusPlus.game.pfp) ~= nil then
        local pfpFileSize = File.getSize(SaveData.SMASPlusPlus.game.pfp)
        if pfpFileSize == -1 then
            SaveData.SMASPlusPlus.game.pfp = Img.load("graphics/default_pfp.png")
        end
    else
        SaveData.SMASPlusPlus.game.pfp = Img.load("graphics/default_pfp.png")
    end]]

    if Misc.inEditor() then
        player.keys.pause = false
        if Player.count() >= 2 then
            player2.keys.pause = false
        end
    end

    if SaveData.speedrunMode then
        Graphics.drawImageWP(inputhudbg,4,566,-1.9) -- Released Keys
        if player.keys.left == KEYS_DOWN then -- Pressed Left Key
            Graphics.drawImageWP(controlkey,8,578,-1) 
        end
        if player.keys.right == KEYS_DOWN then -- Pressed Right Key
            Graphics.drawImageWP(controlkey,20,578,-1)
        end
        if player.keys.up == KEYS_DOWN then -- Pressed Up Key
            Graphics.drawImageWP(controlkey,14,572,-1)
        end
        if player.keys.down == KEYS_DOWN then -- Pressed Down Key
            Graphics.drawImageWP(controlkey,14,584,-1)
        end
        if player.keys.jump == KEYS_DOWN then -- Pressed Jump Key
            Graphics.drawImageWP(jumpkey,68,584,-1)
        end
        if player.keys.run == KEYS_DOWN then -- Pressed Run Key
            Graphics.drawImageWP(runkey,58,582,-1)
        end
        if player.keys.altJump == KEYS_DOWN then -- Pressed Alt Jump Key
            Graphics.drawImageWP(altjumpkey,70,574,-1)
        end
        if player.keys.altRun == KEYS_DOWN then -- Pressed Alt Run Key
            Graphics.drawImageWP(altrunkey,60,572,-1)
        end
        if player.keys.dropItem == KEYS_DOWN then -- Pressed Drop Item Key
            Graphics.drawImageWP(bottomkeys,30,588,-1)
        end
        if player.keys.pause == KEYS_DOWN then -- Pressed Pause Key
            Graphics.drawImageWP(bottomkeys,44,588,-1)
        end
    end
    
    --This'll update the costume throughout the game
    local currentCostume = player:getCostume()
    if currentCostume ~= nil then
        SaveData.SMASPlusPlus.player[1].currentCostume = currentCostume
    elseif currentCostume == nil then
        SaveData.SMASPlusPlus.player[1].currentCostume = "N/A"
    end
    
    --This'll update the path for costumes
    if currentCostume ~= nil then
        if SaveData.SMASPlusPlus.player[1].currentCostume ~= "N/A" then
            SaveData.currentCostumePath = "costumes/"..playerManager.getName(player.character).."/"..SaveData.SMASPlusPlus.player[1].currentCostume
        else
            SaveData.currentCostumePath = "N/A"
        end
    end
end



function onTick()
    mem(0x00B25130,FIELD_WORD,2) --This will prevent split screen, again (Just in case)
    if table.icontains(smasTables._friendlyPlaces,Level.filename()) then
        GameData.friendlyArea = true --Set this to prevent Mother Brain Rinka from getting killed in places such as the boot screen, intro, or the Hub
    end
    --Now we'll overhaul the door star required system
    if warpstaractive then
        for _,warp in ipairs(Warp.get()) do
            if warp.starsRequired <= SaveData.SMASPlusPlus.levels.starCount then
                warp.starsRequired = 0
            elseif warp.starsRequired > SaveData.SMASPlusPlus.levels.starCount then
                --warp.starsRequired = warpStarDoorList(warp) --Try to have this read-only?
            end
        end
    end
    for i = 1,200 do
        if Player(i).isValid then
            if Player(i).forcedState == FORCEDSTATE_PIPE then
                if Player(i).forcedTimer == 1 then
                    local warp = Player(i):mem(0x15E, FIELD_WORD) - 1
                    EventManager.callEvent("onWarpBegin", Warp(warp), Player(i))
                end
            end
        end
    end
    --Another dumb fix pertaining to Yoshi's not actually dying when hitting lava and warping to (0,0) on a level
    for k,v in ipairs(Block.get(Block.LAVA)) do
        for l,j in ipairs(NPC.getIntersecting(v.x - 8, v.y - 8, v.x + v.width, v.y + v.height)) do
            if smasTables.allYoshiMountNPCIDsTableMapped[j.id] then
                j:kill(HARM_TYPE_VANISH)
                Effect.spawn(13, j.x, j.y, 1)
            end
        end
    end
end

function onPause(evt)
    evt.cancelled = true
    isPauseMenuOpen = not isPauseMenuOpen
end

function onCheatActivate(cheat)
    if cheat.id then
        SaveData.SMASPlusPlus.misc.totalCheatsExecuted = SaveData.SMASPlusPlus.misc.totalCheatsExecuted + 1
    end
end

--That's the end of this file!
