--smasNPCSystem.lua
--By "The Sun God: Nika"

--[[
    NPC option values:
    
    levelID = The actual level ID that NPC is taking
    id = The ID of the NPC
    image = Image of the NPC
    frameCount = Frame count of the NPC
    x = X position, used via scene coordinates
    y = Y position, used via scene coordinates
    width = Width of the NPC
    height = Height of the NPC
    direction = The direction the NPC is facing
    message = The message the NPC is using
    friendly = Whether the NPC is friendly or not
    cantMove = Whether the NPC doesn't move
    usingVanillaLayers = If this is using the vanilla layer system or not, if false this uses the smasLayerSystem library
    layer = The layer the NPC is attached to
    speed = The movement speed the NPC takes
    priority = The priority to draw the NPC on
    speedX = The speedX of the NPC
    speedY = the speedY of the NPC
    frameSpeed = The frame speed of the NPC
]]

local smasNPCSystem = {}

local littleDialogue
pcall(function() littleDialogue = require("littleDialogue") end)

smasNPCSystem.createdNPCs = {}
smasNPCSystem.NPCCount = 0
smasNPCSystem.messageMarkPriority = -40

local testNPC = Graphics.loadImageResolved("MALC - HUB/npc-466.png")
local testNPC2 = Graphics.loadImageResolved("npc-946.png")
local messageDialogMark = Graphics.loadImageResolved("graphics/hardcoded/hardcoded-43.png")

-- This is used so the infinite 1UP trick can exist
-- [CLAUDE AI WAS USED IN THIS PART OF THE CODE]
local shellComboCount = {}  -- track combo per shell NPC index
local shellPrevX = {}       -- track previous X position per shell
local shellStuck = {}  -- new flag to track stuck state

local pointsTable = {2, 3, 4, 5, 6, 7, 8, 9}  -- SCORE_100 through SCORE_8000

local function awardComboPoints(shell, idx)
    shellComboCount[idx] = shellComboCount[idx] + 1
    
    -- Give points slightly above the shell so they're visible
    local pointPos = vector(shell.x + shell.width / 2, shell.y - 16)
    
    if shellComboCount[idx] >= 8 then
        Misc.givePoints(10, pointPos, false)  -- SCORE_1UP
    else
        local pointIdx = pointsTable[shellComboCount[idx]]
        Misc.givePoints(pointIdx, pointPos, false)
    end
end

function smasNPCSystem.onInitAPI()
    registerEvent(smasNPCSystem,"onStart")
    --registerEvent(smasNPCSystem,"onTick")
    registerEvent(smasNPCSystem,"onDraw")
end

function smasNPCSystem.countNPCs()
    return smasNPCSystem.NPCCount
end

function smasNPCSystem.removeNPC(args)
    args.npcLevelID = args.npcLevelID or 1
    smasNPCSystem.NPCCount = smasNPCSystem.NPCCount - 1
    table.remove(smasNPCSystem.createdNPCs, args.npcLevelID)
end

function smasNPCSystem.createNPC(args) --smasNPCSystem.createNPC{id = 1, image = testNPC2, frameCount = 17, x = -200752, y = -200128, width = 68, height = 54, direction = -1, messageToSpeak = "Test", isFriendly = true, cantMove = true, useVanillaLayers = false, attachToLayer = "Default", movementSpeed = 2, frameSpeed = 3}
    if args.image == nil then
        error("You must specify an image for this Lua NPC!")
        return
    end
    if args.id == nil then
        error("You must specify the ID for this Lua NPC!")
        return
    end
    if args.frameCount == nil then
        frameCount = 1
    end
    if args.width == nil then
        error("You must specify the width for this Lua NPC!")
        return
    end
    if args.height == nil then
        error("You must specify the height for this Lua NPC!")
        return
    end
    if args.x == nil then
        error("You must specify an X coordinate for this Lua NPC!")
        return
    end
    if args.y == nil then
        error("You must specify an Y coordinate for this Lua NPC!")
        return
    end
    if args.isFriendly == nil then
        isFriendly = false
    end
    if args.cantMove == nil then
        cantMove = false
    end
    if args.messageToSpeak == nil then
        messageToSpeak = ""
    end
    if args.useVanillaLayers == nil then
        useVanillaLayers = false
    end
    if args.attachToVanillaLayer == nil then
        attachToVanillaLayer = "Default"
    end
    if args.movementSpeed == nil then
        args.movementSpeed = 0
    end
    if args.priority == nil then
        args.priority = -45
    end
    if args.speedX == nil then
        args.speedX = 0
    end
    if args.speedY == nil then
        args.speedY = 0
    end
    if args.frameSpeed == nil then
        args.frameSpeed = 8
    end
    
    smasNPCSystem.NPCCount = smasNPCSystem.NPCCount + 1
    
    table.insert(smasNPCSystem.createdNPCs, {
        id = args.id,
        levelID = smasNPCSystem.NPCCount,
        image = args.image,
        frameCount = args.frameCount,
        x = args.x,
        y = args.y,
        width = args.width,
        height = args.height,
        direction = args.direction,
        message = args.messageToSpeak,
        friendly = args.isFriendly,
        cantMove = args.cantMove,
        usingVanillaLayers = args.useVanillaLayers,
        layer = args.attachToLayer,
        speed = args.movementSpeed,
        priority = args.priority,
        speedX = args.speedX,
        speedY = args.speedY,
        frameSpeed = args.frameSpeed,
    })
end

function smasNPCSystem.drawNPC(levelID)
    if levelID == nil then
        error("NPC ID must be specified!")
        return
    end
    
    Graphics.drawBox{
        texture = smasNPCSystem.createdNPCs[levelID].image,
        x = smasNPCSystem.createdNPCs[levelID].x + (smasNPCSystem.createdNPCs[levelID].width * 0.5),
        y = smasNPCSystem.createdNPCs[levelID].y + (smasNPCSystem.createdNPCs[levelID].height * 0.5),
        width = smasNPCSystem.createdNPCs[levelID].width * smasNPCSystem.createdNPCs[levelID].direction,
        height = smasNPCSystem.createdNPCs[levelID].height,
        sourceX = 0,
        sourceY = 0,
        sourceWidth = smasNPCSystem.createdNPCs[levelID].width,
        sourceHeight = smasNPCSystem.createdNPCs[levelID].height,
        priority = smasNPCSystem.createdNPCs[levelID].priority,
        sceneCoords = true,
        centered = true,
    }
end

function smasNPCSystem.onStart()
    if Level.filename() == "SMB1 - W-1, L-1.lvlx" then
        --smasNPCSystem.createNPC{id = 1, image = testNPC2, frameCount = 17, x = player.x, y = player.y - 300, width = 68, height = 54, direction = -1, isFriendly = true, cantMove = true, useVanillaLayers = true, attachToLayer = "Default", movementSpeed = 2, frameSpeed = 3, messageToSpeak = ""}
    end
end

-- [CLAUDE AI WAS USED IN THIS PART OF THE CODE]
function smasNPCSystem.onTick()
    -- Loop through all koopa shell NPCs
    for k, shell in ipairs(NPC.get(NPC.SHELL)) do
        local idx = shell.idx

        if shellPrevX[idx] == nil then
            shellPrevX[idx] = shell.x
            shellComboCount[idx] = 0
            shellStuck[idx] = false
        end

        -- Check if shell is active OR stuck
        if shell.speedX ~= 0 then
            local posChanged = math.abs(shell.x - shellPrevX[idx]) > 0.1

            if not posChanged and not shellStuck[idx] then
                local nearbyBlocks = Block.getIntersecting(
                    shell.x - 2, shell.y,
                    shell.x + shell.width + 2, shell.y + shell.height
                )

                if #nearbyBlocks > 0 then
                    shell.speedX = 0
                    shellStuck[idx] = true
                end
            end

            if shellStuck[idx] then
                local touchingNPCs = NPC.getIntersecting(
                    shell.x, shell.y,
                    shell.x + shell.width, shell.y + shell.height
                )

                for _, npc in ipairs(touchingNPCs) do
                    if npc ~= shell then
                        awardComboPoints(shell, idx)
                    end
                end

                for i = 1, Player.count() do
                    local playerIntersects = Player.getIntersecting(
                        shell.x, shell.y,
                        shell.x + shell.width, shell.y + shell.height
                    )

                    for _, pl in ipairs(playerIntersects) do
                        if pl.speedY > 0 and pl.y - pl.height <= shell.y - 8 then
                            pl.speedY = -7
                            awardComboPoints(shell, idx)
                        end
                    end
                end
            else
                shellComboCount[idx] = 0
            end

            shellPrevX[idx] = shell.x
        else
            -- Shell is fully stopped and not stuck, clean up
            shellPrevX[idx] = nil
            shellComboCount[idx] = nil
            shellStuck[idx] = nil
        end
    end
end

function smasNPCSystem.onDraw()
    if EventManager.onStartRan then
        for k,v in ipairs(smasNPCSystem.createdNPCs) do
            if smasNPCSystem.createdNPCs[k] ~= nil then --If nothing is nil...
                if smasNPCSystem.createdNPCs[k].usingVanillaLayers then --If we're using the vanilla layer system...
                    local layer = Layer.get(smasNPCSystem.createdNPCs[k].layer) --Get the name of the layer
                    if layer ~= nil then
                        if not layer.isHidden then
                            smasNPCSystem.drawNPC(k)
                        end
                    end
                elseif not smasNPCSystem.createdNPCs[k].usingVanillaLayers then --Elseif using smasLayerSystem, draw the NPC using the new system instead
                    for a,b in ipairs(smasLayerSystem.layers) do
                        if not smasLayerSystem.layerIsHidden[a] then
                            smasNPCSystem.drawNPC(k)
                        end
                    end
                end
                --Message box system!
                for a,b in ipairs(Player.getIntersecting(smasNPCSystem.createdNPCs[k].x, smasNPCSystem.createdNPCs[k].y, smasNPCSystem.createdNPCs[k].x + smasNPCSystem.createdNPCs[k].width, smasNPCSystem.createdNPCs[k].y + smasNPCSystem.createdNPCs[k].height)) do
                    for c,d in ipairs(smasLayerSystem.layers) do
                        if not smasLayerSystem.layerIsHidden[c] then --If not hidden...
                            if smasNPCSystem.createdNPCs[k].message ~= "" then --If the message isn't blank...
                                Graphics.drawImageToSceneWP(messageDialogMark, smasNPCSystem.createdNPCs[k].x + 25, smasNPCSystem.createdNPCs[k].y - 20, smasNPCSystem.messageMarkPriority) --Draw a exclamation mark if the player is nearby
                                if b.keys.up == KEYS_PRESSED and not Misc.isPaused() then --Is the player nearby presses up...
                                    if littleDialogue then
                                        littleDialogue.create({text = smasNPCSystem.createdNPCs[k].message})
                                    else
                                        Text.showMessageBox(smasNPCSystem.createdNPCs[k].message) --Show the message!
                                    end
                                end
                            end
                        end
                    end
                end
                if not Misc.isPaused() then
                    smasNPCSystem.createdNPCs[k].x = smasNPCSystem.createdNPCs[k].x + smasNPCSystem.createdNPCs[k].speedX
                    smasNPCSystem.createdNPCs[k].y = smasNPCSystem.createdNPCs[k].y + smasNPCSystem.createdNPCs[k].speedY
                    for a,b in ipairs(Block.get(Block.SOLID)) do
                        if not Collisionz.CheckCollision(smasNPCSystem.createdNPCs[k], b) and Collisionz.FindCollision(smasNPCSystem.createdNPCs[k], b) == Collisionz.CollisionSpot.COLLISION_NONE then
                            if smasNPCSystem.createdNPCs[k].speedY <= 8 then
                                smasNPCSystem.createdNPCs[k].speedY = smasNPCSystem.createdNPCs[k].speedY + (Defines.npc_grav * 0.0005)
                            end
                        elseif Collisionz.CheckCollision(smasNPCSystem.createdNPCs[k], b) and Collisionz.FindCollision(smasNPCSystem.createdNPCs[k], b) == Collisionz.CollisionSpot.COLLISION_TOP then
                            smasNPCSystem.createdNPCs[k].speedY = 0
                        end
                    end
                end
            end
        end
    end
end

return smasNPCSystem