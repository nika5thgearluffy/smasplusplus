local smasOnlinePlay = {}

-- True if online should be enabled.
smasOnlinePlay.enabled = false

local discoveredPlayers = {}
local MY_PORT = 7777
local MY_IP = Internet.ipAddress()
local playersCount = 1

-- Register events below
registerEvent(smasOnlinePlay,"onDraw")


function smasOnlinePlay.toggle(enabled)
    if enabled then
        -- Toggle this on
        smasOnlinePlay.enabled = true
        -- Start listening
        Internet.socketStartListening(7777)
    else
        -- Toggle this off
        smasOnlinePlay.enabled = false
        -- Close socket
        Internet.socketClose()
    end
end

-- Get list of discovered players
function smasOnlinePlay.getDiscoveredPlayers()
    return discoveredPlayers
end


function smasOnlinePlay.onDraw()
    if smasOnlinePlay.enabled then
        local packet = Internet.socketReceivePacket()
        if packet ~= "" then
            local data = json.decode(packet)
            
        end

        -- Broadcast presence every 64 ticks (roughly every second at 64fps)
        if lunatime.drawtick() % 64 == 0 then
            Internet.broadcastEnable()
            local dataImg, w, h = Graphics.getPixelData(Graphics.loadImage(SaveData.SMASPlusPlus.game.pfp))
            Internet.broadcastSend(MY_PORT, json.encode({
                typeToUse = "discover",
                ip = MY_IP,
                name = SaveData.SMASPlusPlus.game.username or "Player",
                --pfp = tostring(inspect(dataImg)),
            }))
        end

        -- Check for other players broadcasting
        local data = Internet.broadcastReceive()
        if data ~= "" then
            local senderIP = Internet.broadcastGetLastSender()
            local packet = json.decode(data)

            if packet and packet.typeToUse == "discover" and senderIP ~= MY_IP then
                -- Found another player on the LAN
                if not discoveredPlayers[senderIP] then
                    discoveredPlayers[senderIP] = packet.name
                    SysManager.sendToConsole("Found player: "..packet.name.." at "..senderIP)
                    Sound.playSFX("online/online-connected.ogg")
                end
                -- Client side - send player position
                Internet.socketSendPacket(senderIP, 7777, json.encode({
                    x = player.x,
                    y = player.y,
                    character = player.character,
                    frame = player.frame,
                    speedX = player.speedX,
                    speedY = player.speedY,
                }))
            end
        end
    end
end



return smasOnlinePlay
