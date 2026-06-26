local smasSMB3System13 = {}

function smasSMB3System13.onInitAPI()
    registerEvent(smasSMB3System13,"onTick")
    registerEvent(smasSMB3System13,"onDraw")
    registerEvent(smasSMB3System13,"onPlayerHarm")
end

local animationTimer = 0
local walkAnimationFrame = 1
local framesUntilUnforegrounded = 512 -- Unless standing underneath sizables, this counts down to 0 to bring the player back (Original is 472, or 480 estimated here)

smasSMB3System13.whiteSizableGoThroughTimer = {}
smasSMB3System13.framesUntilUnforegroundedPlayerTimer = {}
for i = 1,200 do
    smasSMB3System13.whiteSizableGoThroughTimer[i] = 0
    smasSMB3System13.framesUntilUnforegroundedPlayerTimer[i] = framesUntilUnforegrounded
end
smasSMB3System13.warpedIntoWhistleArea = false

function smasSMB3System13.onTick()
    -- Only do the code on SMB3 levels
    if table.icontains(smasTables.__smb3Levels,Level.filename()) then
        for k,v in ipairs(NPC.get(995)) do -- Iterate through all of these NPCs and check for if the layer name is the one required for the white sizable
            if v.layerName == "White Sizable Ducking Area" then
                for j,l in ipairs(Player.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
                    if l:mem(0x12E, FIELD_BOOL) then
                        smasSMB3System13.whiteSizableGoThroughTimer[j] = smasSMB3System13.whiteSizableGoThroughTimer[j] + 1
                        if smasSMB3System13.whiteSizableGoThroughTimer[j] == 200 and not smasBooleans.activateWarpWhistleRoomWarp[j] then
                            l.y = l.y + 8
                            smasBooleans.activateWarpWhistleRoomWarp[j] = true
                            smasSMB3System13.whiteSizableGoThroughTimer[j] = 0
                        end
                    elseif not l:mem(0x12E, FIELD_BOOL) then
                        smasSMB3System13.whiteSizableGoThroughTimer[j] = 0
                    else
                        smasSMB3System13.whiteSizableGoThroughTimer[j] = 0
                    end
                end
            end
        end
    end
end

function smasSMB3System13.onDraw()
    if table.icontains(smasTables.__smb3Levels,Level.filename()) then
        for _,p in ipairs(Player.get()) do
            --[[if smasBooleans.activateWarpWhistleRoomWarp[p.idx] and not smasSMB3System13.warpedIntoWhistleArea then
                smasAnimationSystem.renderPriority = -95
            elseif smasBooleans.activateWarpWhistleRoomWarp[p.idx] and smasSMB3System13.warpedIntoWhistleArea then
                smasAnimationSystem.renderPriority = -25
            end]]
            if smasBooleans.activateWarpWhistleRoomWarp[p.idx] then
                smasSMB3System13.framesUntilUnforegroundedPlayerTimer[p.idx] = smasSMB3System13.framesUntilUnforegroundedPlayerTimer[p.idx] - 1
                for k,v in ipairs(Block.get(Block.SIZEABLE)) do
                    if Collisionz.CheckCollision(p, v) then
                        smasSMB3System13.framesUntilUnforegroundedPlayerTimer[p.idx] = framesUntilUnforegrounded
                    end
                end
                if smasSMB3System13.framesUntilUnforegroundedPlayerTimer[p.idx] <= 0 then
                    smasSMB3System13.framesUntilUnforegroundedPlayerTimer[p.idx] = framesUntilUnforegrounded
                    smasBooleans.activateWarpWhistleRoomWarp[p.idx] = false
                end
            end
        end
    end
end

function smasSMB3System13.onPlayerHarm(eventToken)
    if table.icontains(smasTables.__smb3Levels,Level.filename()) then
        for _,p in ipairs(Player.get()) do
            if smasBooleans.activateWarpWhistleRoomWarp[p.idx] and not smasSMB3System13.warpedIntoWhistleArea then
                eventToken.cancelled = true
            end
        end
    end
end

return smasSMB3System13