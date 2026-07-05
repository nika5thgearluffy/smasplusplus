--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local smasFunctions = require("smasFunctions")
local smasBooleans = require("smasBooleans")

--Create the library table
local sampleNPC = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,

	-- ANIMATION
	--Sprite size
	gfxwidth = 32,
	gfxheight = 32,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 32,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 8,
	framestyle = 0,
	framespeed = 8, -- number of ticks (in-game frames) between animation frame changes

	foreground = true, -- Set to true to cause built-in rendering to render the NPC to Priority -15 rather than -45

	-- LOGIC
	--Movement speed. Only affects speedX by default.
	speed = 1,
	luahandlesspeed = false, -- If set to true, the speed config can be manually re-implemented
	nowaterphysics = false,
	cliffturn = false, -- Makes the NPC turn on ledges
	staticdirection = false, -- If set to true, built-in logic no longer changes the NPC's direction, and the direction has to be changed manually

	--Collision-related
	npcblock = false, -- The NPC has a solid block for collision handling with other NPCs.
	npcblocktop = false, -- The NPC has a semisolid block for collision handling. Overrides npcblock's side and bottom solidity if both are set.
	playerblock = false, -- The NPC prevents players from passing through.
	playerblocktop = false, -- The player can walk on the NPC.

	nohurt=true, -- Disables the NPC dealing contact damage to the player
	nogravity = false,
	noblockcollision = false,
	notcointransformable = true, -- Prevents turning into coins when beating the level
	nofireball = true,
	noiceball = true,
	noyoshi= true, -- If true, Yoshi, Baby Yoshi and Chain Chomp can eat this NPC

	score = 1, -- Score granted when killed
	--  1 = 10,    2 = 100,    3 = 200,  4 = 400,  5 = 800,
	--  6 = 1000,  7 = 2000,   8 = 4000, 9 = 8000, 10 = 1up,
	-- 11 = 2up,  12 = 3up,  13+ = 5-up, 0 = 0

	--Various interactions
	jumphurt = false, --If true, spiny-like (prevents regular jump bounces)
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping and causes a bounce
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false
	nowalldeath = false, -- If true, the NPC will not die when released in a wall

	linkshieldable = false,
	noshieldfireeffect = false,

	grabside=false,
	grabtop=false,

	--Identity-related flags. Apply various vanilla AI based on the flag:
	--iswalker = false,
	--isbot = false,
	--isvegetable = false,
	--isshoe = false,
	--isyoshi = false,
	--isinteractable = true,
	--iscoin = false,
	--isvine = false,
	--iscollectablegoal = false,
	--isflying = false,
	--iswaternpc = false,
	--isshell = false,
	
	-- Various interactions
	-- ishot = true,
	-- iscold = true,
	-- durability = -1, -- Durability for elemental interactions like ishot and iscold. -1 = infinite durability
	-- weight = 2,
	-- isstationary = true, -- gradually slows down the NPC
	-- nogliding = true, -- The NPC ignores gliding blocks (1f0)

	--Emits light if the Darkness feature is active:
	--lightradius = 100,
	--lightbrightness = 1,
	--lightoffsetx = 0,
	--lightoffsety = 0,
	--lightcolor = Color.white,

	--Define custom properties below
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below
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

--Register events
function sampleNPC.onInitAPI()
	npcManager.registerEvent(npcID, sampleNPC, "onTickNPC")
	--npcManager.registerEvent(npcID, sampleNPC, "onTickEndNPC")
	npcManager.registerEvent(npcID, sampleNPC, "onDrawNPC")
	registerEvent(sampleNPC, "onSFXStart")
    registerEvent(sampleNPC, "onPlayerKill")
end

function sampleNPC.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
        data.hitGroundState = 0
        data.hasGrabbed = false
        data.hitGroundTimer = 0
        data.hasHitGroundOnce = false
        data.hasHitGroundTwice = false

        data.playerGrabbedWandX = 0
        data.playerGrabbedWandY = 0
        data.playerGrabbedWandDirection = 0
        data.playerGrabbedWandShouldntDie = false

        data.cutsceneTimer = 0
        data.startTimerCountdown = false
        data.timerOn0 = false
        data.isDone = false

        Sound.playSFX(122)

		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v.heldIndex ~= 0 --Negative when held by NPCs, positive when held by players
	or v.isProjectile   --Thrown
	or v.forcedState > 0--Various forced states
	then
		-- Handling of those special states. Most NPCs want to not execute their main code when held/coming out of a block/etc.
		-- If that applies to your NPC, simply return here.
		-- return
	end
	
	-- Put main AI below here
    if data.hitGroundState == 1 and not data.hasHitGroundTwice then
        data.hitGroundTimer = data.hitGroundTimer + 1
        if data.hitGroundTimer == 1 then
            data.wandMoveSFX = Sound.playSFX(123, 1, 0, 12)
        end
    end
	if v.collidesBlockBottom and not data.hasGrabbed then
        if data.hitGroundState == 0 and not data.hasHitGroundOnce then
            data.hitGroundState = 1
            v.speedY = -8
            Sound.playSFX(3)
            data.hasHitGroundOnce = true
        elseif data.hitGroundState == 1 and data.hasHitGroundOnce then
            data.hitGroundState = 2
            if data.wandMoveSFX and data.wandMoveSFX ~= nil then
                data.wandMoveSFX:stop()
            end
            data.hasHitGroundTwice = true
        end
    end
    for _,p in ipairs(Player.get()) do
        if Colliders.collide(p, v) then
            data.hasGrabbed = true
            data.playerGrabbedWand = p
            data.playerGrabbedWandX = p.x
            data.playerGrabbedWandY = p.y
            data.playerGrabbedWandDirection = p.direction
            p.nonpcinteraction = true
            break
        end
    end
    if data.hasGrabbed and not data.isDone then
        smasBooleans.hasGrabbedMagicWand = true
        if data.wandMoveSFX and data.wandMoveSFX ~= nil then
            data.wandMoveSFX:Stop()
        end
        data.cutsceneTimer = data.cutsceneTimer + 1
        if not data.timerOn0 then
            if data.cutsceneTimer == 1 then
                Misc.npcToCoins()
                Sound.muteMusic(data.playerGrabbedWand.section)
                Sound.playSFX(21)
            end
            if data.cutsceneTimer == lunatime.toTicks(4.5) then
                data.startTimerCountdown = true
            end
        else
            if data.cutsceneTimer == lunatime.toTicks(2.5) then
                local newX,newY = playerCoordinatesForSectionTransition(data.playerGrabbedWand, 4)
                data.playerGrabbedWandX = newX
                data.playerGrabbedWandY = newY
                data.playerGrabbedWand:teleport(data.playerGrabbedWandX, data.playerGrabbedWandY)
            end
            if data.cutsceneTimer >= lunatime.toTicks(8) then
                data.playerGrabbedWand.y = data.playerGrabbedWand.y + 5
                data.playerGrabbedWandY = data.playerGrabbedWandY + 5
                data.playerGrabbedWandShouldntDie = true
                if data.cutsceneTimer >= lunatime.toTicks(8.5) then
                    triggerEvent(v.data._settings.eventName)
                    data.isDone = true
                end
            end
        end
        smasBooleans.winStateActive = true
        if data.startTimerCountdown then
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
                data.timerOn0 = true
                data.cutsceneTimer = 0
                data.startTimerCountdown = false
            end
        end
    end
end

function sampleNPC.onDrawNPC(v)
    if Defines.levelFreeze then return end

	local data = v.data

    if data.hasHitGroundTwice or data.hasGrabbed then
        v.animationFrame = 0
    end
    if data.hasGrabbed and not data.isDone then
        NPC.config[NPC_ID].nogravity = true
        data.playerGrabbedWand.x = data.playerGrabbedWandX
        data.playerGrabbedWand.y = data.playerGrabbedWandY
        data.playerGrabbedWand.direction = data.playerGrabbedWandDirection
        v.x, v.y = magicWandCalculation(data.playerGrabbedWand)
        v.despawnTimer = 1000
        data.playerGrabbedWand.frame = Playur.jumpPose(data.playerGrabbedWand)
        for _,p in ipairs(Player.get()) do
            if p.idx ~= data.playerGrabbedWand.idx then
                p.section = data.playerGrabbedWand.section
                p.x = (data.playerGrabbedWand.x+(data.playerGrabbedWand.width/2)-(p.width/2))
                p.y = (data.playerGrabbedWand.y+data.playerGrabbedWand.height-p.height)
                p.speedX,p.speedY = 0,0
                p.forcedState,p.forcedTimer = 8,-data.playerGrabbedWand.idx
            end
        end
    end
end

function sampleNPC.onSFXStart(eventObj, soundID)
    for k,v in ipairs(NPC.get(NPC_ID)) do
        if v.data.hasGrabbed and (soundID == 1 or soundID == 10) then
            eventObj.cancelled = true
        end
    end
end

function sampleNPC.onPlayerKill(eventObj)
    for k,v in ipairs(NPC.get(NPC_ID)) do
        if v.data.playerGrabbedWandShouldntDie then
            eventObj.cancelled = true
        end
    end
end

--Gotta return the library table!
return sampleNPC