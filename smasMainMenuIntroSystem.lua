local smasMainMenuIntroSystem = {}

autoscroll = require("autoscroll")
autoscroll.shouldCheckPlayerForcedState = false

-- Intro types
smasMainMenuIntroSystem.introTypes = {
    STILL = 1,
    LEFT_TO_RIGHT = 2,
    RIGHT_TO_LEFT = 3,
    TOP_TO_BOTTOM = 4,
    BOTTOM_TO_TOP = 5,
}

-- The main intro data. Coexists with "smasTables.__introLevels"
smasMainMenuIntroSystem.introTypesForIntros = {
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_SMAS.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_SMBX1.0.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_SMBX1.1.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_SMBX1.2.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_SMBX1.3.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_WSMBA.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_SMBX2.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_theeditedboss.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_SMBX1.3og.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_SMBX2b3.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_8bit.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_S!TS!.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_sunsetbeach.lvlx"
    smasMainMenuIntroSystem.introTypes.TOP_TO_BOTTOM, -- "intro_scrollingheights.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_jakebrito1.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_marioforever.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_jakebrito2.lvlx"
    smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT, -- "intro_circuitcity.lvlx"
    smasMainMenuIntroSystem.introTypes.STILL, -- "intro_metroidprime2.lvlx"
}

-- First & second scroll speeds
smasMainMenuIntroSystem.firstScrollSpeed = 6
smasMainMenuIntroSystem.secondScrollSpeed = 15

-- Ticks until scrolling first/second
smasMainMenuIntroSystem.firstScrollStopTicks = lunatime.toTicks(1.2)
smasMainMenuIntroSystem.secondScrollStopTicks = lunatime.toTicks(1.5)

-- Raised up when autoscroll is non-existant for intros that move, 0 if still or setting the next autoscroll event
local timerForStoppedAutoscroll = 0
--[[
    0 = Still
    1 = Moving from A to B
    2 = Stopped at B
    3 = Moving from B to A
    4 = Stopped at A, at the end loops back to 1
]]
local autoscrollEventID = 0

local autoscrollHasStoppedFirst = false
local autoscrollHasStoppedSecond = false

-- Returns the intro ID from the table, using the intro level's filename itself
function smasMainMenuIntroSystem.findIntroID(introLevel)
    for k,v in ipairs(smasTables.__introLevels) do
        if v == introLevel then
            return k
        end
    end
    return 0
end

-- Register events below
registerEvent(smasMainMenuIntroSystem,"onTick")

function smasMainMenuIntroSystem.onTick()
    -- Only do code for intro levels
    if table.icontains(smasTables.__introLevels, Level.filename()) and lunatime.tick() > 1 then
        local introType = smasMainMenuIntroSystem.introTypesForIntros[smasMainMenuIntroSystem.findIntroID(Level.filename())]
        if introType == smasMainMenuIntroSystem.introTypes.LEFT_TO_RIGHT then
            if autoscrollEventID == 0 then
                autoscroll.scrollRight(smasMainMenuIntroSystem.firstScrollSpeed)
                autoscrollEventID = 1
            end
            if autoscrollEventID == 1 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedFirst then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.firstScrollStopTicks
                    autoscrollHasStoppedFirst = true
                    autoscrollEventID = 2
                end
            end
            if autoscrollEventID == 2 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscroll.scrollLeft(smasMainMenuIntroSystem.secondScrollSpeed)
                    autoscrollEventID = 3
                end
            end
            if autoscrollEventID == 3 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedSecond then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.secondScrollStopTicks
                    autoscrollHasStoppedSecond = true
                    autoscrollEventID = 4
                end
            end
            if autoscrollEventID == 4 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscrollHasStoppedFirst = false
                    autoscrollHasStoppedSecond = false
                    autoscroll.scrollRight(smasMainMenuIntroSystem.firstScrollSpeed)
                    autoscrollEventID = 0
                    NPC.restoreClass("NPC")
                end
            end
        elseif introType == smasMainMenuIntroSystem.introTypes.RIGHT_TO_LEFT then
            if autoscrollEventID == 0 then
                autoscroll.scrollLeft(smasMainMenuIntroSystem.firstScrollSpeed)
                autoscrollEventID = 1
            end
            if autoscrollEventID == 1 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedFirst then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.firstScrollStopTicks
                    autoscrollHasStoppedFirst = true
                    autoscrollEventID = 2
                end
            end
            if autoscrollEventID == 2 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscroll.scrollRight(smasMainMenuIntroSystem.secondScrollSpeed)
                    autoscrollEventID = 3
                end
            end
            if autoscrollEventID == 3 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedSecond then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.secondScrollStopTicks
                    autoscrollHasStoppedSecond = true
                    autoscrollEventID = 4
                end
            end
            if autoscrollEventID == 4 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscrollHasStoppedFirst = false
                    autoscrollHasStoppedSecond = false
                    autoscroll.scrollLeft(smasMainMenuIntroSystem.firstScrollSpeed)
                    autoscrollEventID = 0
                    NPC.restoreClass("NPC")
                end
            end
        elseif introType == smasMainMenuIntroSystem.introTypes.TOP_TO_BOTTOM then
            Text.print(autoscrollEventID, 100, 100)
            if autoscrollEventID == 0 then
                autoscroll.scrollUp(smasMainMenuIntroSystem.firstScrollSpeed)
                autoscrollEventID = 1
            end
            if autoscrollEventID == 1 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedFirst then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.firstScrollStopTicks
                    autoscrollHasStoppedFirst = true
                    autoscrollEventID = 2
                end
            end
            if autoscrollEventID == 2 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscroll.scrollDown(smasMainMenuIntroSystem.secondScrollSpeed)
                    autoscrollEventID = 3
                end
            end
            if autoscrollEventID == 3 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedSecond then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.secondScrollStopTicks
                    autoscrollHasStoppedSecond = true
                    autoscrollEventID = 4
                end
            end
            if autoscrollEventID == 4 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscrollHasStoppedFirst = false
                    autoscrollHasStoppedSecond = false
                    autoscroll.scrollUp(smasMainMenuIntroSystem.firstScrollSpeed)
                    autoscrollEventID = 0
                    NPC.restoreClass("NPC")
                end
            end
        elseif introType == smasMainMenuIntroSystem.introTypes.BOTTOM_TO_TOP then
            if autoscrollEventID == 0 then
                autoscroll.scrollDown(smasMainMenuIntroSystem.firstScrollSpeed)
                autoscrollEventID = 1
            end
            if autoscrollEventID == 1 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedFirst then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.firstScrollStopTicks
                    autoscrollHasStoppedFirst = true
                    autoscrollEventID = 2
                end
            end
            if autoscrollEventID == 2 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscroll.scrollUp(smasMainMenuIntroSystem.secondScrollSpeed)
                    autoscrollEventID = 3
                end
            end
            if autoscrollEventID == 3 then
                if not autoscroll.isSectionScrolling() and not autoscrollHasStoppedSecond then
                    timerForStoppedAutoscroll = smasMainMenuIntroSystem.secondScrollStopTicks
                    autoscrollHasStoppedSecond = true
                    autoscrollEventID = 4
                end
            end
            if autoscrollEventID == 4 then
                timerForStoppedAutoscroll = timerForStoppedAutoscroll - 1
                if timerForStoppedAutoscroll == 0 then
                    autoscrollHasStoppedFirst = false
                    autoscrollHasStoppedSecond = false
                    autoscroll.scrollDown(smasMainMenuIntroSystem.firstScrollSpeed)
                    autoscrollEventID = 0
                    NPC.restoreClass("NPC")
                end
            end
        end
    end
end

return smasMainMenuIntroSystem
