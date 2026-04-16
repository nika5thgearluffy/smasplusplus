local smasPSwitch = {}

function smasPSwitch.onInitAPI()
    registerEvent(smasPSwitch,"onDraw")
end

local pSwitchMusic
smasPSwitch.pSwitchMusicStarted = false

local deathTimerPSwitch = 0



function smasPSwitch.startPSwitchMusic() --Starts the P-Switch music.
    if not smasPSwitch.pSwitchMusicStarted then
        if not smasPSwitch.inNoPSwitchMusicPlayingSituations() then
            SysManager.sendToConsole("P-Switch music activated!")
            Audio.music[1][1].music = Misc.episodePath()..smasCharacterInfo.pSwitchMusic
            Audio.music[1][2].music = Misc.episodePath()..smasCharacterInfo.pSwitchMusic
            smasPSwitch.pSwitchMusicStarted = true
        end
    end
end



function smasPSwitch.stopPSwitchMusic(resetLevelMusic) --Stops the P-Switch music.
    if resetLevelMusic == nil then
        resetLevelMusic = true
    end
    
    if pSwitchMusic ~= nil then
        pSwitchMusic:Stop()
    end
    
    smasPSwitch.pSwitchMusicStarted = false
    
    if not smasPSwitch.inNoPSwitchMusicPlayingSituations() then
        if resetLevelMusic then
            SysManager.sendToConsole("P-Switch music deactivated!")
        end
    end
end



function smasPSwitch.inNoPSwitchMusicPlayingSituations()
    for _,p in ipairs(Player.get()) do
        return (p.hasStarman
            or p.isMega
            or GameData.winStateActive
            or Level.endState() > 0
        )
    end
end



function smasPSwitch.onDraw()
    for _,p in ipairs(Player.get()) do --Make sure all players are counted if i.e. using supermario128...
        
        
        
        
        --Start P-Switch/Stopwatch codes
        if mem(0x00B2C62C, FIELD_WORD) == mem(0x00B2C87C, FIELD_WORD) - 1 then --P-Switch
            smasPSwitch.startPSwitchMusic()
            smasBooleans.pSwitchActive = true
        end
        if mem(0x00B2C62E, FIELD_WORD) == mem(0x00B2C87C, FIELD_WORD) - 1 then --Stopwatch
            smasPSwitch.startPSwitchMusic()
            smasBooleans.stopWatchActive = true
        end
        
        
        
        --Make sure the music stops when collecting a starman, a megashroom, or winning a level if active
        if smasPSwitch.inNoPSwitchMusicPlayingSituations() then
            if pSwitchMusic ~= nil then
                smasBooleans.musicMuted = false
                pSwitchMusic:Stop()
            end
        end
        
        
        
        --Stop P-Switch/Stopwatch codes
        if mem(0x00B2C62C, FIELD_WORD) == 1 then --P-Switch
            smasBooleans.pSwitchActive = false
            smasPSwitch.stopPSwitchMusic()
        end
        if mem(0x00B2C62E, FIELD_WORD) == 1 then --Stopwatch
            smasBooleans.stopWatchActive = false
            smasPSwitch.stopPSwitchMusic()
        end
        
        
        --Player death P-Switch stop codes
        if not Playur.isAnyPlayerAlive() then
            deathTimerPSwitch = deathTimerPSwitch + 1
            if deathTimerPSwitch == 1 then
                smasPSwitch.stopPSwitchMusic(false)
            end
        end
        
        
        
        
    end
end

return smasPSwitch