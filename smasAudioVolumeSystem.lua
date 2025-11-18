local smasAudioVolumeSystem = {}

local audiomasterSMAS = require("scripts/audiomasterSMAS")

function smasAudioVolumeSystem.onInitAPI()
    registerEvent(smasAudioVolumeSystem,"onDraw")
end

function smasAudioVolumeSystem.onDraw()
    if not Misc.inMarioChallenge() then
        if GameData.SMASPlusPlus.audio.musicVolume == nil then
            GameData.SMASPlusPlus.audio.musicVolume = 60
        end
        if GameData.SMASPlusPlus.audio.sfxVolume == nil then
            GameData.SMASPlusPlus.audio.sfxVolume = 1
        end
        if (pausemenu2 and pauseplus) or (pauseplus) and (SaveData.pauseplus.selectionData["soundsettings"]) then
            SaveData.pauseplus.selectionData["soundsettings"]["music volume"] = GameData.SMASPlusPlus.audio.musicVolume
            SaveData.pauseplus.selectionData["soundsettings"]["sfx volume"] = GameData.SMASPlusPlus.audio.sfxVolume

            if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                Audio.MusicVolume(0)
            elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                Audio.MusicVolume(pauseplus.getSelectionValue("soundsettings","Music Volume"))
            end

            GameData.SMASPlusPlus.audio.musicVolume = pauseplus.getSelectionValue("soundsettings","Music Volume")
            GameData.SMASPlusPlus.audio.sfxVolume = pauseplus.getSelectionValue("soundsettings","SFX Volume")
        elseif pausemenu2 == nil and pauseplus == nil then
            if smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                Audio.MusicVolume(0)
            elseif not smasBooleans.musicMuted and not smasBooleans.overrideMusicVolume then
                Audio.MusicVolume(GameData.SMASPlusPlus.audio.musicVolume)
            end
        end
        for i = 1,91 do
            pcall(function() Audio.sounds[i].sfx.volume = math.floor(GameData.SMASPlusPlus.audio.sfxVolume * 128 + 0.5) end)
        end
        if smasExtraSounds.active then
            if Audio.sounds[43].muted then
                Audio.sounds[43].sfx.volume = 0
            end
        end
        SFX.volume.MASTER = GameData.SMASPlusPlus.audio.sfxVolume
        audiomasterSMAS.volume.MASTER = GameData.SMASPlusPlus.audio.sfxVolume
    end
end

return smasAudioVolumeSystem