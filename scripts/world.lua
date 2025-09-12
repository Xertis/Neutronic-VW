local m = _G["$Multiplayer"]

function on_world_open()
    if m.side == "server" then
        require "logic/server"
    elseif m.side == "client" then
        require "logic/client"
    end
end