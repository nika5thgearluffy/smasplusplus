local smasAudioVolumeSystem = {}

local audiomasterSMAS = require("scripts/audiomasterSMAS")

function smasAudioVolumeSystem.onInitAPI()
    registerEvent(smasAudioVolumeSystem,"onDraw")
end

local timeTickUntilMusicMute = 0

-- Set to true to set the volume for both Music & SFXs right away, for updating
smasAudioVolumeSystem.setVolumeNow = {}
smasAudioVolumeSystem.setVolumeNow.music = false
smasAudioVolumeSystem.setVolumeNow.sfx = false

function smasAudioVolumeSystem.onDraw()
    if not Misc.inMarioChallenge() then
        if GameData.SMASPlusPlus.audio.musicVolume == nil then
            GameData.SMASPlusPlus.audio.musicVolume = 60
        end
        if GameData.SMASPlusPlus.audio.sfxVolume == nil then
            GameData.SMASPlusPlus.audio.sfxVolume = 1
        end
        if (pausemenu2 and pauseplus) or (pauseplus) then
            pauseplus.setSelectionValue("soundsettings", "Music Volume", GameData.SMASPlusPlus.audio.musicVolume)
            pauseplus.setSelectionValue("soundsettings", "SFX Volume", GameData.SMASPlusPlus.audio.sfxVolume)

            if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                Audio.MusicVolume(0)
                timeTickUntilMusicMute = 0
            elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                if smasAudioVolumeSystem.setVolumeNow then
                    timeTickUntilMusicMute = timeTickUntilMusicMute + 1
                    if timeTickUntilMusicMute == 1 then
                        Audio.MusicVolume(pauseplus.getSelectionValue("soundsettings","Music Volume"))
                    end
                end
            end
        elseif pausemenu2 == nil and pauseplus == nil then
            if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                timeTickUntilMusicMute = 0
                Audio.MusicVolume(0)
            elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                if smasAudioVolumeSystem.setVolumeNow then
                    timeTickUntilMusicMute = timeTickUntilMusicMute + 1
                    if timeTickUntilMusicMute == 1 then
                        Audio.MusicVolume(GameData.SMASPlusPlus.audio.musicVolume)
                    end
                end
            end
        end
        for i = 1,91 do
            if smasAudioVolumeSystem.setVolumeNow then
                pcall(function() Audio.sounds[i].sfx.volume = math.floor(GameData.SMASPlusPlus.audio.sfxVolume * 128 + 0.5) end)
            end
        end
        if smasExtraSounds.active then
            if Audio.sounds[43].muted then
                Audio.sounds[43].sfx.volume = 0
            end
        end
        if smasAudioVolumeSystem.setVolumeNow then
            SFX.volume.MASTER = GameData.SMASPlusPlus.audio.sfxVolume
            audiomasterSMAS.volume.MASTER = GameData.SMASPlusPlus.audio.sfxVolume
        end
        if smasAudioVolumeSystem.setVolumeNow then
            timeTickUntilMusicMute = 0
            smasAudioVolumeSystem.setVolumeNow = false
        end
    end
end

return smasAudioVolumeSystem