local smasUpdater = {}

local textplus = require("textplus")
local statusFont = textplus.loadFont("littleDialogue/font/6.ini")

smasUpdater.doUpdate = false --ONLY toggled on the start level.

smasUpdater.drawUpdateText = false
smasUpdater.drawVersionText = false

smasUpdater.doneUpdating = true --Toggled false when updating is active.

smasUpdater.updateStage = 0
smasUpdater.updateTimer = 0

smasUpdater.fadeToBlackOpacity = 0
smasUpdater.fadeToBlack = false

smasUpdater.checkFileIndicator = 1
smasUpdater.checkFileDownloadIndicator = 0

smasUpdater.tableOfFilesToCheckSizes = {}
smasUpdater.tableOfFilesToDownload = {}

smasUpdater.manifestJSON = {}
smasUpdater.currentFileIndex = 1

local manifestRetrieved = false

function smasUpdater.onInitAPI()
    registerEvent(smasUpdater,"onStart")
    registerEvent(smasUpdater,"onDraw")
    registerEvent(smasUpdater,"onDownloadComplete")
end

smasUpdater.urlStringTable = {
    [1] = {
        oldString = " ",
        newString = "%%20",
    },
    [2] = {
        oldString = "+",
        newString = "%%2B",
    },
}

function smasUpdater.stringToURLPiece(stringd)
    local stringValue = string.gsub(stringd, smasUpdater.urlStringTable[1].oldString, smasUpdater.urlStringTable[1].newString)
    local stringValue2 = string.gsub(stringValue, smasUpdater.urlStringTable[2].oldString, smasUpdater.urlStringTable[2].newString)
    
    return stringValue2
end

function smasUpdater.downloadFile(url, folder)
    if folder == nil then
        folder = ""
    end
    return Internet.downloadFile(url, Misc.episodePath()..folder)
end

function smasUpdater.checkFileSize(file)
    return File.getSize(Misc.episodePath()..file)
end

function smasUpdater.readVersionUpdateList()
    local f = io.open(Misc.episodePath().."manifest.json", "r")
    local contentsTable
    if f ~= nil then
        contentsTable = json.parse(f:read())
        f:close()
    end
    return contentsTable
end

function smasUpdater.downloadLatestUpdateConfig()
    if not Misc.inEditor() then
        smasUpdater.downloadFile("https://raw.githubusercontent.com/SpencerEverly/smasplusplus/main/manifest.json", Misc.episodePath().."manifest.json")
    end
end

function smasUpdater.restartAfterUpdating()
    if Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(false)
    end
    if not Misc.loadEpisode("Super Mario All-Stars++") then
        error("SMAS++ is not found. How is that even possible? Reinstall the game using the SMASUpdater, since something has gone terribly wrong.")
    end
end

function smasUpdater.launchAfterNoUpdate()
    if Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(false)
    end
    SysManager.loadIntroTheme()
end

local internetCheck = false

function smasUpdater.onDownloadComplete(bufferData)
    if bufferData ~= "" then
        smasUpdater.updateTimer = 0
        smasUpdater.updateStage = 2
        smasUpdater.manifestJSON = smasUpdater.readVersionUpdateList()
    end
end

function smasUpdater.onDraw()
    if smasUpdater.doUpdate and not Misc.inEditor() and not io.exists(Misc.episodePath().."dontupdate") then
        if smasUpdater.drawUpdateText then
            textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = 400, y = 290, priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2, maxWidth = 500}
            if smasUpdater.drawVersionText then
                textplus.print{text = smasUpdater.versionNumber(), pivot = vector.v2(0.5,0.5), x = 400, y = 250, priority = 10, color = Color.white, font = statusFont, xscale = 1.5, yscale = 1.5}
            end
        end
        
        if not smasUpdater.doneUpdating then
            if smasUpdater.updateStage == 0 then
                smasUpdater.updateStage = 1
            end
            
            if smasUpdater.updateStage == 1 then
                smasUpdater.updateTimer = smasUpdater.updateTimer + 1
                if smasUpdater.updateTimer == 1 then
                    UpdateMessageForUpdater = "Checking for updates..."
                end
                if smasUpdater.updateTimer == 5 then
                    smasUpdater.downloadLatestUpdateConfig()
                end
                if smasUpdater.updateTimer == 6 then
                    if Internet.downloadProgress() ~= 0 then
                        internetCheck = true
                    end
                end
                if smasUpdater.updateTimer >= 7 then
                    if Internet.downloadProgress() == 0 and smasUpdater.manifestJSON ~= nil and smasUpdater.manifestJSON.files ~= nil then
                        smasUpdater.updateStage = 2
                    end
                end
            end
            if internetCheck then
                if smasUpdater.updateStage == 2 then
                    local file = smasUpdater.manifestJSON.files[smasUpdater.currentFileIndex]
                    if file then
                        if not Internet.isDownloading() then
                            local localMD5 = File.getMD5Hash(Misc.episodePath()..file.path)
                            if localMD5 ~= file.md5 then
                                smasUpdater.downloadFile(file.url, file.path)
                            else
                                -- File matches, move to next
                                smasUpdater.currentFileIndex = smasUpdater.currentFileIndex + 1
                            end
                        end
                        -- If downloading, just wait for next frame
                    else
                        -- No more files, done
                        smasUpdater.doneUpdating = true
                        smasUpdater.updateStage = 3
                    end
                    smasUpdater.updateStage = 3
                end
            else
                smasUpdater.drawVersionText = false
                UpdateMessageForUpdater = "No internet! Skipping update..."
                smasUpdater.updateTimer = smasUpdater.updateTimer + 1
                if smasUpdater.updateTimer >= lunatime.toTicks(4) then
                    smasUpdater.launchAfterNoUpdate()
                end
            end
        else
            if smasUpdater.updateStage == 3 then
                smasUpdater.updateTimer = smasUpdater.updateTimer + 1
                if smasUpdater.updateTimer >= lunatime.toTicks(5) then
                    smasUpdater.fadeToBlack = true
                    smasUpdater.restartAfterUpdating()
                end
            end
        end
    elseif Misc.inEditor() then
        if smasUpdater.doUpdate then
            UpdateMessageForUpdater = "On the editor. Skipping update..."
            
            if smasUpdater.drawUpdateText then
                textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(290, 2), priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                if Internet.downloadFilename() ~= "" then
                    textplus.print{text = "Downloading:", pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(420, 2), priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                    textplus.print{text = Internet.downloadFilename(), pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(450, 2), priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                    textplus.print{text = tostring(Internet.downloadProgress()), pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(520, 2), priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                end
            end
            
            if not smasUpdater.doneUpdating then
                smasUpdater.updateTimer = smasUpdater.updateTimer + 1
                if smasUpdater.updateTimer >= lunatime.toTicks(4) then
                    smasUpdater.launchAfterNoUpdate()
                end
            end
        end
    else
        if smasUpdater.doUpdate then
            UpdateMessageForUpdater = "Skipping update..."
            
            if smasUpdater.drawUpdateText then
                textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(290, 2), priority = 10, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
            end
            
            if not smasUpdater.doneUpdating then
                smasUpdater.updateTimer = smasUpdater.updateTimer + 1
                if smasUpdater.updateTimer >= lunatime.toTicks(4) then
                    smasUpdater.launchAfterNoUpdate()
                end
            end
        end
    end
    if smasUpdater.fadeToBlack then
        Graphics.drawScreen{color = Color.black, priority = 10}
    end
end

return smasUpdater