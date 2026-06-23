local smasAudioVolumeSystem = {}

function smasAudioVolumeSystem.onInitAPI()
    registerEvent(smasAudioVolumeSystem,"onDraw")
end

local timeTickUntilSoundChange = 0

-- Set to true to set the volume for both Music & SFXs right away, for updating
smasAudioVolumeSystem.setVolumeNow = {}
smasAudioVolumeSystem.setVolumeNow.music = false
smasAudioVolumeSystem.setVolumeNow.sfx = false

function smasAudioVolumeSystem.onDraw()
    if (pausemenu2 and pauseplus) or (pauseplus) then
        --pauseplus.setSelectionValue("soundsettings", "SFX Volume", GameData.SMASPlusPlus.audio.sfxVolume)

        if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
            Audio.MusicVolume(0)
            timeTickUntilSoundChange = 0
        elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
            if smasAudioVolumeSystem.setVolumeNow.music then
                timeTickUntilSoundChange = timeTickUntilSoundChange + 1
                if timeTickUntilSoundChange == 1 then
                    Audio.MusicVolume(GameData.SMASPlusPlus.audio.musicVolume)
                end
            end
        end
    elseif pausemenu2 == nil and pauseplus == nil then
        if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
            timeTickUntilSoundChange = 0
            Audio.MusicVolume(0)
        elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
            if smasAudioVolumeSystem.setVolumeNow.music then
                if timeTickUntilSoundChange == 1 then
                    Audio.MusicVolume(GameData.SMASPlusPlus.audio.musicVolume)
                end
            end
        end
    end
    for i = 1, Audio.SfxCount() do
        if smasAudioVolumeSystem.setVolumeNow.sfx then
            if timeTickUntilSoundChange == 1 then
                pcall(function() Audio.sounds[i].sfx.volume = math.floor(GameData.SMASPlusPlus.audio.sfxVolume * 128 + 0.5) end)
            end
        end
    end
    if smasExtraSounds.active then
        if Audio.sounds[43].muted then
            Audio.sounds[43].sfx.volume = 0
        end
    end
    if smasAudioVolumeSystem.setVolumeNow.sfx then
        if timeTickUntilSoundChange == 1 then
            SFX.volume.MASTER = GameData.SMASPlusPlus.audio.sfxVolume
        end

        if timeTickUntilSoundChange >= 2 then
            timeTickUntilSoundChange = 0
            smasAudioVolumeSystem.setVolumeNow.sfx = false
        end
    end
    if smasAudioVolumeSystem.setVolumeNow.music then
        if timeTickUntilSoundChange >= 2 then
            timeTickUntilSoundChange = 0
            smasAudioVolumeSystem.setVolumeNow.music = false
        end
    end
end

return smasAudioVolumeSystem