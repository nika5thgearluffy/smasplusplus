local smasOnlinePlay = {}

-- True if online should be activated. This is only true when a session is active.
smasOnlinePlay.onlineActivated = false



-- Register events below
registerEvent(smasOnlinePlay,"onDraw")



function smasOnlinePlay.onDraw()
    if smasOnlinePlay.onlineActivated then
        
    end
end



return smasOnlinePlay
