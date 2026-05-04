local smasCharacterHealthSystem = {}

if Screen == nil then
    _G.smasFunctions = require("smasFunctions")
end

--If enabled or not.
smasCharacterHealthSystem.enabled = false
--If we should use the small state with the health system. Default is false.
smasCharacterHealthSystem.useSmallState = false
--The health to start the character with on each level.
smasCharacterHealthSystem.defaultStartingHealth = 2
--The max health of this character.
smasCharacterHealthSystem.maxHealth = 3
--The health of this character.
smasCharacterHealthSystem.health = {}
for i = 1,200 do
    smasCharacterHealthSystem.health[i] = smasCharacterHealthSystem.defaultStartingHealth
end
--The Y position of the hearts. This is automatically updated.
smasCharacterHealthSystem.heartYPosition = 0
--Graphics for the heart full/empty sprites.
smasCharacterHealthSystem.heartFullGFX = Graphics.loadImageResolved("hardcoded/hardcoded-36-1.png")
smasCharacterHealthSystem.heartEmptyGFX = Graphics.loadImageResolved("hardcoded/hardcoded-36-2.png")
--The priority for drawing the hearts.
smasCharacterHealthSystem.drawingPriority = 5
--Whether we should draw the hearts or not.
smasCharacterHealthSystem.drawHearts = true

function smasCharacterHealthSystem.onInitAPI()
    registerEvent(smasCharacterHealthSystem,"onPlayerHarm")
    registerEvent(smasCharacterHealthSystem,"onPostNPCKill")
    registerEvent(smasCharacterHealthSystem,"onDraw")
end

local hit = false

function smasCharacterHealthSystem.hpHit(p)
    if smasCharacterHealthSystem.enabled then
        if not p.hasStarman and not p.isMega then
            smasCharacterHealthSystem.health[p.idx] = smasCharacterHealthSystem.health[p.idx] - 1
            if smasCharacterHealthSystem.health[p.idx] < 1 then
                p:kill()
            end
        end
    end
end

function smasCharacterHealthSystem.onPlayerHarm(evt, p)
    if smasCharacterHealthSystem.enabled and not evt.cancelled then
        smasCharacterHealthSystem.hpHit(p)
    end
end

function smasCharacterHealthSystem.onPostNPCKill(npc, harmType)
    if smasCharacterHealthSystem.enabled then
        local items = table.map{9,184,185,249,14,182,183,34,169,170,277,264,996,994}
        local healitems = table.map{9,184,185,249,14,182,183,34,169,170,277,264}
        for _,p in ipairs(Player.get()) do
            if healitems[npc.id] and Colliders.collide(p, npc) then
                smasCharacterHealthSystem.health[p.idx] = smasCharacterHealthSystem.health[p.idx] + 1
            end
        end
    end
end

function smasCharacterHealthSystem.onDraw()
    if smasCharacterHealthSystem.enabled then
        for _,p in ipairs(Player.get()) do

            if not smasCharacterHealthSystem.useSmallState then
                if p.powerup <= 1 then --Do something where it doesn't shrink to the small state
                    p.powerup = 2
                end
            end
            
            if smasCharacterHealthSystem.health[p.idx] > smasCharacterHealthSystem.maxHealth then
                smasCharacterHealthSystem.health[p.idx] = smasCharacterHealthSystem.maxHealth
            end
            
            --Check to see if we need to move the hearts based on if we got an itembox or not...
            if Graphics.getHUDType(p.character) == Graphics.HUD_HEARTS then
                smasCharacterHealthSystem.heartYPosition = 16
            elseif Graphics.getHUDType(p.character) == Graphics.HUD_ITEMBOX then
                smasCharacterHealthSystem.heartYPosition = 80
            end
            
            if p.forcedState == FORCEDSTATE_POWERDOWN_SMALL or p.forcedState == FORCEDSTATE_POWERDOWN_FIRE or p.forcedState == FORCEDSTATE_POWERDOWN_ICE then
                p.forcedState = FORCEDSTATE_NONE
                p:mem(0x140, FIELD_WORD, 150)
            end
            
            if Graphics.isHudActivated() then
                if smasHud.visible.customItemBox then
                    if smasCharacterHealthSystem.drawHearts then
                        if smasCharacterHealthSystem.health[p.idx] <= 0 then
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(357, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(388, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(420, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                        end
                        if smasCharacterHealthSystem.health[p.idx] == 1 then
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(357, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(388, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(420, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                        end
                        if smasCharacterHealthSystem.health[p.idx] == 2 then
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(357, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(388, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartEmptyGFX, Screen.calculateCameraDimensions(420, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                        end
                        if smasCharacterHealthSystem.health[p.idx] >= 3 then
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(357, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(388, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                            Graphics.drawImageWP(smasCharacterHealthSystem.heartFullGFX, Screen.calculateCameraDimensions(420, 1), smasCharacterHealthSystem.heartYPosition, smasCharacterHealthSystem.drawingPriority)
                        end
                    end
                end
            end
        end
    end
end

return smasCharacterHealthSystem