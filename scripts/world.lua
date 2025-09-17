local m = _G["$Multiplayer"]
local api = {}

local globals = require "globals"

function on_world_open()
    if m.side == "server" then
        api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]))[m.side]
        require "logic/server"
    elseif m.side == "client" then
        require "logic/client"
    end
end

events.on("server:client_pipe_start", function (client)
    local cur_time = time.uptime()

    local client_info = globals.server.queue[client.client_id]
    if not client_info then return end

    if client_info.time+15 < cur_time then
        api.accounts.kick(client.account, "Authorization timeout exceeded")
        api.console.echo(api.console.colors.red .. string.format('[NEUTRONIC_VW] Аккаунт "%s" превысил время ожидания', client.account.username))
        globals.server.queue[client.client_id] = nil
    end
end)