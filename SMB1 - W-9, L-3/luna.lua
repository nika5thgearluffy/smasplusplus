local level_dependencies_normal= require("level_dependencies_normal")

local oldGravity = 0
local oldJumpHeight = 0

function onLoadSection1()
    Defines.gravity = Defines.gravity - 9
    Defines.jumpheight = Defines.jumpheight + 10
end

function onLoadSection0()
    Defines.gravity = oldGravity
    Defines.jumpheight = oldJumpHeight
end