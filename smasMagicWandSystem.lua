local smasMagicWandSystem = {}

local hasGrabbed = false

local playerGrabbedWand
local playerGrabbedWandX = 0
local playerGrabbedWandY = 0
local playerGrabbedWandDirection = 0
local playerGrabbedWandWidth = 0
local playerGrabbedWandHeight = 0
local playerGrabbedWandShouldntDie = false

local cutsceneTimer = 0
local startTimerCountdown = false
local timerOn0 = false

local backgroundBlueTimer = 0
local backgroundShouldBlue = false
local backgroundBlueOpacity = 0

local opacity = 0
local opacityTick = 0.015

local fadeOutOn = false

function smasMagicWandSystem.collectWand(plr)
    -- Fill out values for keeping the player still
    playerGrabbedWand = plr
    playerGrabbedWandX = plr.x
    playerGrabbedWandY = plr.y
    playerGrabbedWandDirection = plr.direction
    playerGrabbedWandWidth = plr.width
    playerGrabbedWandHeight = plr.height

    hasGrabbed = true
end

registerEvent(smasMagicWandSystem,"onTick")
registerEvent(smasMagicWandSystem,"onDraw")
registerEvent(smasMagicWandSystem,"onSFXStart")
registerEvent(smasMagicWandSystem,"onPlayerKill")

registerEvent(smasMagicWandSystem,"onMagicWandChangeSection")
registerEvent(smasMagicWandSystem,"onMagicWandEndSequence")

local function playerCoordinatesForSectionTransition(plr, newSection, x, y)
    -- Get current section bounds
    local currentSection = Section(plr.section)
    local currentBounds = currentSection.boundary
    
    -- Calculate player's relative position within current section (0 to 1)
    local relX = (plr.x - currentBounds.left) / (currentBounds.right - currentBounds.left)
    local relY = (plr.y - currentBounds.top) / (currentBounds.bottom - currentBounds.top)
    
    -- Get new section bounds
    local sectionNew = Section(newSection)
    local sectionNewBounds = sectionNew.boundary
    
    -- Apply same relative position to new section
    local newX = sectionNewBounds.left + relX * (sectionNewBounds.right - sectionNewBounds.left)
    local newY = sectionNewBounds.top + relY * (sectionNewBounds.bottom - sectionNewBounds.top)
    
    -- Override with explicit x/y if provided
    if x ~= nil then newX = x end
    if y ~= nil then newY = y end
    
    return newX, newY
end

local function magicWandCalculation(plr)
    return
        plr.x + (plr.width / 2 - (plr.width / 2)),
        plr.y - (plr.height / 2 + 10)
end

function smasMagicWandSystem.onTick()
    if hasGrabbed then
        cutsceneTimer = cutsceneTimer + 1
        if not timerOn0 then
            if cutsceneTimer == 1 then
                Misc.npcToCoins()
                Sound.muteMusic(playerGrabbedWand.section)
                Sound.playSFX(21)
            end
            if cutsceneTimer == lunatime.toTicks(4.5) then
                startTimerCountdown = true
            end
        else
            if cutsceneTimer == lunatime.toTicks(2.5) then
                local newX,newY = playerCoordinatesForSectionTransition(playerGrabbedWand, NPC.config[932].selectedSection)
                playerGrabbedWandX = newX
                playerGrabbedWandY = newY
                playerGrabbedWand:teleport(playerGrabbedWandX, playerGrabbedWandY)
                EventManager.callEvent("onMagicWandChangeSection", NPC.config[932].selectedSection)
            end
            if cutsceneTimer >= lunatime.toTicks(8) then
                playerGrabbedWand.y = playerGrabbedWand.y + 5
                playerGrabbedWandY = playerGrabbedWandY + 5
                playerGrabbedWandShouldntDie = true
                if cutsceneTimer >= lunatime.toTicks(12) then
                    EventManager.callEvent("onMagicWandEndSequence")
                    hasGrabbed = false
                end
            end
        end
        smasBooleans.winStateActive = true
        if startTimerCountdown then
            if Timer.isActive() and Timer.getValue() > 0 then
                Sound.playSFX(113)
                if Timer.getValue() >= 100 then
                    Timer.add(-5)
                    SaveData.SMASPlusPlus.hud.score = SaveData.SMASPlusPlus.hud.score + 100
                else
                    Timer.add(-1)
                    SaveData.SMASPlusPlus.hud.score = SaveData.SMASPlusPlus.hud.score + 10
                end
            else
                Sound.playSFX(114)
                timerOn0 = true
                cutsceneTimer = 0
                startTimerCountdown = false
            end
        end
    end
end

function smasMagicWandSystem.onDraw()
    if hasGrabbed then
        local x,y = magicWandCalculation(playerGrabbedWand)
        playerGrabbedWand.x = playerGrabbedWandX
        playerGrabbedWand.y = playerGrabbedWandY
        playerGrabbedWand.direction = playerGrabbedWandDirection
        playerGrabbedWand.frame = Playur.jumpPose(playerGrabbedWand)
        playerGrabbedWand.width = playerGrabbedWandWidth
        playerGrabbedWand.height = playerGrabbedWandHeight
        playerGrabbedWand.speedX = 0
        playerGrabbedWand.speedY = 0
        for _,p in ipairs(Player.get()) do
            if p.idx ~= playerGrabbedWand.idx then
                p.section = playerGrabbedWand.section
                p.x = (playerGrabbedWand.x+(playerGrabbedWand.width/2)-(p.width/2))
                p.y = (playerGrabbedWand.y+playerGrabbedWand.height-p.height)
                p.speedX,p.speedY = 0,0
                p.forcedState,p.forcedTimer = 8,-playerGrabbedWand.idx
            end
        end
        Graphics.drawImageToSceneWP(
            Graphics.sprites.npc[932].img,
            x,
            y,
            0,
            0,
            NPC.config[932].width,
            NPC.config[932].height,
            -15
        )
        if backgroundShouldBlue then
            backgroundBlueTimer = backgroundBlueTimer + 1
            if backgroundBlueTimer >= lunatime.toTicks(1.5) then
                if backgroundBlueOpacity < 1 then
                    backgroundBlueOpacity = backgroundBlueOpacity + 0.008
                end
                Graphics.drawScreen({
                    color = Color.fromHexRGB(0x84CEFF) .. backgroundBlueOpacity,
                    priority = -99,
                })
            end
            if cutsceneTimer >= lunatime.toTicks(11) then
                if opacity < 1 then
                    opacity = opacity + opacityTick
                end
                Graphics.drawScreen{color = Color.black .. opacity, priority = 1}
            end
        end
    end
    if fadeOutOn then
        if opacity > 0 then
            opacity = opacity - opacityTick
            Graphics.drawScreen{color = Color.black .. opacity, priority = 1}
        else
            fadeOutOn = false
        end
    end
end

function smasMagicWandSystem.onMagicWandChangeSection(sectionID)
    backgroundShouldBlue = true
end

function smasMagicWandSystem.onMagicWandEndSequence()
    fadeOutOn = true
end

function smasMagicWandSystem.onSFXStart(eventObj, soundID)
    if hasGrabbed and (soundID == 1 or soundID == 10) then
        eventObj.cancelled = true
    end
end

function smasMagicWandSystem.onPlayerKill(eventObj)
    if playerGrabbedWandShouldntDie then
        eventObj.cancelled = true
    end
end

return smasMagicWandSystem
