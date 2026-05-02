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

smasUpdater.manifestJSON = nil
smasUpdater.currentFileIndex = 1
smasUpdater.updateURL = "https://raw.githubusercontent.com/nika5thgearluffy/smasplusplus/main/manifest.json"

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
        contentsTable = json.decode(f:read("*all"))
        f:close()
    end
    return contentsTable
end

function smasUpdater.downloadLatestUpdateConfig()
    if not Misc.inEditor() then
        smasUpdater.downloadFile(smasUpdater.updateURL, Misc.episodePath().."manifest.json")
    end
end

function smasUpdater.restartAfterUpdating()
    Routine.wait(5, true)
    if Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(false)
    end
    Level.load("SMAS - Start.lvlx")
end

function smasUpdater.launchAfterNoUpdate()
    Routine.wait(5, true)
    if Misc.isRunningWhenUnfocused() then
        Misc.setRunWhenUnfocused(false)
    end
    SysManager.loadIntroTheme()
end

local internetCheck = false

function smasUpdater.onDownloadComplete(bufferData, url, filename)
    if filename == "manifest.json" then
        internetCheck = true
        smasUpdater.updateTimer = 0
        smasUpdater.updateStage = 2
        smasUpdater.manifestJSON = smasUpdater.readVersionUpdateList()
    end
    if smasUpdater.updateStage == 3 then
        smasUpdater.currentFileIndex = smasUpdater.currentFileIndex + 1
    end
end

function smasUpdater.onDraw()
    if smasUpdater.doUpdate and not Misc.inEditor() and not io.exists(Misc.episodePath().."dontupdate") then
        if smasUpdater.drawUpdateText then
            textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(290, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2, maxWidth = 800}
            if Internet.downloadFilename() ~= "" then
                textplus.print{text = "Downloading:", pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(420, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                textplus.print{text = Internet.downloadFilename(), pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(450, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
                textplus.print{text = tostring(Internet.downloadProgress()).."%", pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(480, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
            end
            if smasUpdater.updateStage == 3 then
                textplus.print{text = tostring(smasUpdater.currentFileIndex).."/"..tostring(#smasUpdater.manifestJSON.files), pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(540, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
            end
        end

        smasUpdater.updateTimer = smasUpdater.updateTimer + 1
        
        if not smasUpdater.doneUpdating then
            if smasUpdater.updateStage == 0 then
                smasUpdater.updateStage = 1
            end
            
            if smasUpdater.updateStage == 1 then
                if smasUpdater.updateTimer == 1 then
                    UpdateMessageForUpdater = "Checking for updates..."
                    smasUpdater.downloadLatestUpdateConfig()
                end
            end
            if internetCheck and smasUpdater.updateStage >= 2 then
                if smasUpdater.updateStage == 2 then
                    UpdateMessageForUpdater = "Cleaning up files for new update..."
                    -- Handle deleted files first
                    if smasUpdater.manifestJSON.deleted then
                        for _, path in ipairs(smasUpdater.manifestJSON.deleted) do
                            -- Sanitize path to prevent directory traversal
                            if not path:find("%.%.") and not path:find("^/") and not path:find("^%a:") then
                                local fullPath = Misc.episodePath()..path
                                if io.exists(fullPath) then
                                    os.remove(fullPath)
                                end
                            end
                        end
                        smasUpdater.updateStage = 3
                    else
                        smasUpdater.updateStage = 3
                    end
                end
                if smasUpdater.updateStage == 3 then
                    UpdateMessageForUpdater = "Downloading the latest update... this will take a while."
                    local file = smasUpdater.manifestJSON.files[smasUpdater.currentFileIndex]
                    if file then
                        if not Internet.isDownloading() then
                            local localMD5 = File.getMD5Hash(Misc.episodePath()..file.path)
                            if localMD5 ~= file.md5 then
                                smasUpdater.downloadFile(file.url, Misc.episodePath()..file.path)
                            else
                                -- File matches, move to next
                                smasUpdater.currentFileIndex = smasUpdater.currentFileIndex + 1
                            end
                        end
                        -- If downloading, just wait for next frame
                    else
                        -- No more files, done
                        UpdateMessageForUpdater = "Update complete! Restarting game..."
                        GameData.SMASPlusPlus.game.updateDownloaded = true
                        smasUpdater.updateTimer = 0
                        smasUpdater.updateStage = 4
                        smasUpdater.doneUpdating = true
                    end
                end
            elseif not internetCheck and smasUpdater.updateStage == 1 and not Internet.isDownloading() then
                smasUpdater.drawVersionText = false
                UpdateMessageForUpdater = "No internet! Skipping update..."
                if smasUpdater.updateTimer == 1 then
                    Routine.run(smasUpdater.launchAfterNoUpdate)
                end
            end
        else
            if smasUpdater.updateStage == 4 then
                if smasUpdater.updateTimer == 1 then
                    Routine.run(smasUpdater.restartAfterUpdating)
                end
            end
        end
    elseif Misc.inEditor() then
        UpdateMessageForUpdater = "On the editor. Skipping update..."
        
        if smasUpdater.drawUpdateText then
            textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(290, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
        end
        
        if not smasUpdater.doneUpdating then
            if smasUpdater.updateTimer == 1 then
                Routine.run(smasUpdater.launchAfterNoUpdate)
            end
        end
    else
        if smasUpdater.doUpdate then
            UpdateMessageForUpdater = "Skipping update..."

            if smasUpdater.drawUpdateText then
                textplus.print{text = UpdateMessageForUpdater, pivot = vector.v2(0.5,0.5), x = Screen.calculateCameraDimensions(400, 1), y = Screen.calculateCameraDimensions(290, 2), priority = 5, color = Color.white, font = statusFont, xscale = 2, yscale = 2}
            end

            smasUpdater.updateTimer = smasUpdater.updateTimer + 1
            
            if not smasUpdater.doneUpdating then
                if smasUpdater.updateTimer == 1 then
                    Routine.run(smasUpdater.launchAfterNoUpdate)
                end
            end
        end
    end
    if smasUpdater.fadeToBlack then
        Graphics.drawScreen{color = Color.black, priority = 10}
    end
end

return smasUpdater