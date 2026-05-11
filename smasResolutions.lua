local smasResolutions = {}

local CRTShader = Shader()
CRTShader:compileFromFile(nil, "shaders/crt.frag")
local filterBuffer = Graphics.CaptureBuffer(800,600)

registerEvent(smasResolutions,"onStart")
registerEvent(smasResolutions,"onDraw")
registerEvent(smasResolutions,"onFramebufferResize")

function smasResolutions.changeCRTSetting(onMainMenu)
    if onMainMenu == nil then
        onMainMenu = false
    end
    Routine.run(function()
        SaveData.SMASPlusPlus.options.enableCRTFilter = not SaveData.SMASPlusPlus.options.enableCRTFilter
        Routine.waitFrames(1, true)
        if onMainMenu then
            if SaveData.SMASPlusPlus.options.enableCRTFilter then
                SaveData.pauseplus.selectionData["screensettings"]["enable crt display"] = true
            else
                SaveData.pauseplus.selectionData["screensettings"]["enable crt display"] = false
            end
        end
    end)
end

function smasResolutions.changeResolution(onMainMenu, shouldResizeWindow)
    if onMainMenu == nil then
        onMainMenu = false
    end
    if shouldResizeWindow == nil then
        shouldResizeWindow = false
    end
    Routine.run(function()
        -- Wait one frame, since it won't update unless we do so
        Routine.waitFrames(1, true)

        -- Now set the resolution
        if SaveData.SMASPlusPlus.options.resolution == "fullscreen" then
            Screen.changeResolution(800,600)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 1
            end
        elseif SaveData.SMASPlusPlus.options.resolution == "widescreen" then
            Screen.changeResolution(1066,600)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 2
            end
        elseif SaveData.SMASPlusPlus.options.resolution == "ultrawide" then
            Screen.changeResolution(1424,600)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 3
            end
        elseif SaveData.SMASPlusPlus.options.resolution == "steamdeck" then
            Screen.changeResolution(960,600)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 4
            end
        elseif SaveData.SMASPlusPlus.options.resolution == "dynamicwidescreen" then
            Screen.changeResolution(1280,720)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 5
            end
        elseif SaveData.SMASPlusPlus.options.resolution == "snes" then
            Screen.changeResolution(512,448)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 6
            end
        else
            Screen.changeResolution(800,600)
            if onMainMenu then
                SaveData.pauseplus.selectionData["screensettings"]["switch resolution"] = 1
            end
        end

        -- And set the window size after changing the resolution if set to do so.
        if shouldResizeWindow then
            Window.setSize(Window.getWidthFromResolution(Screen.width()), Window.getHeightFromResolution(Screen.height()))
        end
    end)
end

function smasResolutions.onStart()
    local width,height = Graphics.getMainFramebufferSize()
    if camera.width ~= width and camera.height ~= height then
        smasResolutions.changeResolution(false, false)
    end
end

function smasResolutions.onDraw()
    --CRT Filter
    if SaveData.SMASPlusPlus.options.enableCRTFilter then
        if not SaveData.SMASPlusPlus.game.onePointThreeModeActivated then
            filterBuffer:captureAt(10)
            Graphics.drawScreen{texture = filterBuffer, shader = CRTShader, uniforms = {iResolution = vector.v3(Screen.getScreenSize()[1],Screen.getScreenSize()[2])}, priority = 10}
        end
    end
end

function smasResolutions.onFramebufferResize(fbWidth, fbHeight)
    -- Recapture the CRT filter buffer
    filterBuffer = Graphics.CaptureBuffer(fbWidth, fbHeight)
end

return smasResolutions