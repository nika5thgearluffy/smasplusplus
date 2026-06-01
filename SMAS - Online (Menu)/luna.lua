local mleb = require("multilayeredearthboundbg")
local littleDialogue = require("littleDialogue")
local Routine = require("routine")
Graphics.activateHud(false)
local title = Graphics.loadImage("title-final-2x.png")
local smasExtraSounds = require("smasExtraSounds")
local newkeyboard = require("newkeyboard")

local exitwordswip = false

local matchChannelsToMute = {
    1,
    4,
    6,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
}

local selectChannelsToMute = {
    4,
    6,
    8,
    11,
    13,
    14,
}

local lobbyChannelsToMute = {
    1,
    4,
    8,
    11,
    13,
}

local timer = 0

mleb.addShaderSection(0, {
        texture = bg_example,
        interlace = 4,
        interlaceIntensity = 2,
        animationPhase = -0.533,
        animationSpeed = 0.5,
        verticalWobble = 0.1,
        oscillationAmplitude = 0.1,
        oscillationFrequency = 0.2,
        move = vector(0, 0),
        iFrequency = 0.1,
        iAmplitude = 0.158,
        tint=Color.blue,
        distortion = vector(0.1, 0),
       -- palette = bg_example_palB,
        paletteHeight = 2,
})

mleb.addShaderSection(0, {
        texture = bg_example,
        interlace = 4,
        interlaceIntensity = 2,
        animationPhase = 0.33,
        animationSpeed = 0.25,
        verticalWobble = 0.4,
        tint=Color.red,
        oscillationAmplitude = 0.1,
        oscillationFrequency = 0.2,
        move = vector(0, 0),
        iFrequency = -0.2,
        iAmplitude = 0.158,
        distortion = vector(0, 0),
        --palette = loadImage("bg_example_palA"),
        paletteHeight = 2,
})

mleb.addShaderSection(0, {
        texture = title,
        interlace = 2,
        interlaceIntensity = 2,
        animationPhase = 2,
        animationSpeed = 0.78,
        verticalWobble = 0.05,
        oscillationAmplitude = 0.1,
        oscillationFrequency = 0.4,
        move = vector(0, 0),
        iFrequency = 0.2,
        iAmplitude = 0.28,
        distortion = vector(0, 0),
    })

littleDialogue.defaultStyleName = "smbx13" --Change the text box to the SMBX 1.3 textbox format
smasExtraSounds.active = false
smasBooleans.disablePauseMenu = true

local IPHostBoard = newkeyboard.create{isImportant = true, isImportantButCanBeCancelled = true, clear = true, setVariable = SaveData.SMASPlusPlus.game.username, pause = false}
local IPClientBoard = newkeyboard.create{isImportant = true, isImportantButCanBeCancelled = true, clear = true, setVariable = SaveData.SMASPlusPlus.game.username, pause = false}

local function IPAddressHostEnter()
    GameData.playerEnteringHostIP = true
    IPHostBoard:open()
end

local function IPAddressClientEnter()
    GameData.playerEnteringClientIP = true
    IPClientBoard:open()
end

local function ExitToBootMenu()
    exitscreen = true
    Audio.MusicChange(0, 0)
    Routine.wait(0.4)
    Misc.saveGame()
    if Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(false)
    end
    GameData.SMASPlusPlus.online.state = 0
    Level.load("SMAS - Start.lvlx")
end

local function ExitToBootMenuWithSound()
    Sound.playSFX(14)
    ExitToBootMenu()
end

local function startConnecting()
    local isValidIP = SysManager.checkValidIPAddress(GameData.SMASPlusPlus.online.ipClient)
    if isValidIP then
        exitwordswip = true
        for i = 1,14 do
            Sound.unmuteChannel(i)
        end
        for k,v in ipairs(lobbyChannelsToMute) do
            Sound.muteChannel(v)
        end
    else
        littleDialogue.create({text = "<setPos 400 32 0.5 -1.7>Looks like this is an invalid IP address! Please reenter the address.<question IPAddressEntering>", pauses = false, updatesInPause = true})
    end
end

local function enterIPAddress()
    for i = 1,14 do
        Sound.unmuteChannel(i)
    end
    for k,v in ipairs(selectChannelsToMute) do
        Sound.muteChannel(v)
    end
    littleDialogue.create({text = "<setPos 400 32 0.5 -1.7>We'll need the client's IP address in order to connect. Please enter it.<question IPAddressEntering>", pauses = false, updatesInPause = true})
end

local function onlineBegin()
    littleDialogue.create({text = "<setPos 400 32 0.5 -1.7>Welcome to the world of online multiplayer.<page>This is the place to host and connect to other player sessions, and experience the game like never before!<page>Please note that this place is under testing, and things won't be done as of yet.<page>When you see an loading icon, it is connecting to the Internet. Please don't close the game during that sequence.<page>With that being said, welcome to Online Multiplayer.<question StartConnecting>", pauses = false, updatesInPause = true})
end 
    
function onStart()
    if GameData.SMASPlusPlus.online.state == 0 then
        GameData.SMASPlusPlus.online.state = 1
        Playur.activate1stPlayer()
    end
    smasExtraSounds.active = false
    if GameData.SMASPlusPlus.online.state == 1 then
        Routine.run(onlineBegin)
        for k,v in ipairs(matchChannelsToMute) do
            Sound.muteChannel(v)
        end
    end
    littleDialogue.defaultStyleName = "smbx13" --Change the text box to the SMBX 1.3 textbox format
    if not Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(true)
    end
end

function onTick()
    littleDialogue.defaultStyleName = "smbx13" --Change the text box to the SMBX 1.3 textbox format
    player.forcedState = FORCEDSTATE_INVISIBLE
end

function onDraw()
    if exitscreen then
        Graphics.drawScreen{color = Color.black, priority = 10}
    end
    if exitwordswip then
        Text.printWP("To exit, press PAGE DOWN.", Screen.calculateCameraDimensions(200, 1), Screen.calculateCameraDimensions(200, 2), 5)
    end
    if GameData.SMASPlusPlus.online.state == 2 then
        timer = timer + 1
        if timer == 1 then
            startConnecting()
        end
    end
end

function onKeyboardPressDirect(k, repeated, str)
    if canEnterIPAddress then
        if k and str ~= nil then
            
        end
    end
    if exitwordswip and k == VK_NEXT and not Misc.isPaused() then --PAGE_DOWN
        exitwordswip = false
        Routine.run(ExitToBootMenuWithSound)
    end
end

function onExit()
    
end

local function menu_showExitMenu()
    exitwordswip = true
    
end

littleDialogue.registerAnswer("IPAddressEntering",{text = "Enter",chosenFunction = function() IPAddressClientEnter() end})
littleDialogue.registerAnswer("IPAddressEntering",{text = "Exit",chosenFunction = function() Routine.run(ExitToBootMenu) end})

littleDialogue.registerAnswer("QuitToMenuError",{text = "Exit",chosenFunction = function() Routine.run(ExitToBootMenu) end})

littleDialogue.registerAnswer("StartConnecting",{text = "Let's get started!",chosenFunction = function() enterIPAddress() end})

littleDialogue.registerAnswer("TestExitMenu",{text = "Let's get started!",chosenFunction = function() menu_showExitMenu() end})