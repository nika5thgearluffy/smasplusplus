local smasDamagePause = {}
local damageWhetherShouldUnPause = false

-- Register events below
registerEvent(smasDamagePause, "onTick")

-- All forced states to use when pausing via damage.
smasDamagePause.forcedStatesToPauseWith = {
    FORCEDSTATE_POWERUP_BIG,
    FORCEDSTATE_POWERDOWN_SMALL,
    FORCEDSTATE_POWERUP_FIRE,
    FORCEDSTATE_POWERUP_LEAF,
    FORCEDSTATE_POWERUP_TANOOKI,
    FORCEDSTATE_POWERUP_HAMMER,
    FORCEDSTATE_POWERDOWN_BIG, -- Includes tier 3 to big forced state
    FORCEDSTATE_POWERUP_ICE,
    FORCEDSTATE_POWERDOWN_FIRE,
    FORCEDSTATE_POWERDOWN_ICE,
    FORCEDSTATE_MEGASHROOM,
}

function smasDamagePause.onTick()
    -- Check if a stopwatch is active, and don't do anything if so
    if mem(0x00B2C62E, FIELD_WORD) == 0 then
        for _,p in ipairs(Player.get()) do
            for k,v in ipairs(smasDamagePause.forcedStatesToPauseWith) do
                if p and p.isValid then
                    if damagePause.forcedStatesToPauseWith[p:mem(0x122, FIELD_WORD)] then
                        if not Defines.levelFreeze then
                            Defines.levelFreeze = true
                            damageWhetherShouldUnPause = true
                        end
                    else
                        if damageWhetherShouldUnPause then
                            Defines.levelFreeze = false
                            damageWhetherShouldUnPause = false
                        end
                    end
                else
                    -- Stop level freeze if a player is invalid when doing a forced state
                    if damageWhetherShouldUnPause then
                        Defines.levelFreeze = false
                        damageWhetherShouldUnPause = false
                    end
                end
            end
        end
    end
end

return smasDamagePause