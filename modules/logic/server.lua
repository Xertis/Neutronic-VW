local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]))[m.side]

local globals = require "globals"

events.on("server:client_connected", function (client)
    api.events.tell("neutronic_vw", "auth", client, Bytearray(255))
    globals.server.queue[client.client_id] = {
        client = client,
        time = time.uptime()
    }
    client.account.is_logged = false
end)

events.on("server:client_disconnected", function (client)
    globals.server.queue[client.client_id] = nil
end)

local function get_avatar(url, client)
    if not string.ends_with(string.lower(url), ".png") then
        return
    end

    api.events.echo("neutronic_vw", "avatar", api.bson.serialize({
        username = client.account.username,
        url = url
    }))

    globals.server.avatars[client.account.username] = url
end

local function send_all_avatars(client)
    for username, url in pairs(globals.server.avatars) do
        api.events.tell("neutronic_vw", "avatar", client, api.bson.serialize({
            username = username,
            url = url
        }))
    end
end

api.events.on("neutronic_vw", "token", function (client, bytes)
    local data = api.bson.deserialize(bytes)
    globals.server.queue[client.client_id] = nil

    network.post("https://api.voxelworld.ru/v2/one-time-token/check", {
        one_time_token = data.token
    },
    function(response)
        local info = json.parse(response).data

        if info.avatar then
            get_avatar(info.avatar, client)
        end

        if info.name ~= client.account.username then
            api.accounts.kick(client.account, "Invalid username", true)
            api.console.echo(api.console.colors.red .. string.format('[NEUTRONIC_VW] Аккаунт "%s" вошёл с другого никнейма', info.name))
            return
        end

        api.console.echo(api.console.colors.green .. string.format('[NEUTRONIC_VW] Аккаунт "%s" успешно авторизовался', info.name))
        client.account.is_logged = true
        send_all_avatars(client)
    end,
    function(code)
        print("Ошибка с кодом: " .. code)
        api.accounts.kick(client.account, "Invalid token received", true)
        api.console.echo(api.console.colors.red .. string.format('[NEUTRONIC_VW] Аккаунт "%s" отправил неверный токен', client.account.username))
    end,
        {
            "Accept: application/json"
        }
    )
end)