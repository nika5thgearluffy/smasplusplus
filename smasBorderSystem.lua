local smasBorderSystem = {}

-- Draw a dark color around the outside areas of a section. This gives a "letterbox" feel
function smasBorderSystem.drawBorder()
    local camX = camera.x
    local camY = camera.y
    local screenW = Screen.width()
    local screenH = Screen.height()
    
    -- Get level boundary
    local sec = Section(player.section)
    local boundLeft = sec.boundary.left
    local boundRight = sec.boundary.right
    local boundTop = sec.boundary.top
    local boundBottom = sec.boundary.bottom

    local levelWidth = boundRight - boundLeft
    local levelHeight = boundBottom - boundTop
    
    local blackColor = Color(0.1, 0.1, 0.1)
    
    local LARGE = 100000  -- large enough to cover any level size

    -- Left bar
    Graphics.drawBox{
        x = boundLeft - LARGE,
        y = boundTop - LARGE,
        width = LARGE,
        height = levelHeight + LARGE * 2,
        color = blackColor,
        priority = -0.1,
        sceneCoords = true
    }

    -- Right bar
    Graphics.drawBox{
        x = boundRight,
        y = boundTop - LARGE,
        width = LARGE,
        height = levelHeight + LARGE * 2,
        color = blackColor,
        priority = -0.1,
        sceneCoords = true
    }

    -- Top bar
    Graphics.drawBox{
        x = boundLeft - LARGE,
        y = boundTop - LARGE,
        width = levelWidth + LARGE * 2,
        height = LARGE,
        color = blackColor,
        priority = -0.1,
        sceneCoords = true
    }

    -- Bottom bar
    Graphics.drawBox{
        x = boundLeft - LARGE,
        y = boundBottom,
        width = levelWidth + LARGE * 2,
        height = LARGE,
        color = blackColor,
        priority = -0.1,
        sceneCoords = true
    }
end

return smasBorderSystem
