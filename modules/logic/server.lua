local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]) )[m.side]

events.on("server:client_connected", function (client)
    api.events.tell("neutronic_vw", "auth", client, Bytearray(255))
    client.account.is_logged = false
end)

api.events.on("neutronic_vw", "token", function (client, bytes)
    local data = api.bson.deserialize(bytes)

    network.post("https://api.voxelworld.ru/v2/one-time-token/check", {
        one_time_token = data.token
    },
    function(response)
        local info = json.parse(response).data

        if info.name ~= client.account.username then
            api.accounts.kick(client.account, "Invalid username")
            api.console.echo(api.console.colors.red .. string.format('[NEUTRONIC_VW] Аккаунт "%s" вошёл с другого никнейма', info.name))
            return
        end

        api.console.echo(api.console.colors.green .. string.format('[NEUTRONIC_VW] Аккаунт "%s" успешно авторизовался', info.name))
        client.account.is_logged = true
    end,
    function(code)
        api.accounts.kick(client.account, "Invalid token received")
        api.console.echo(api.console.colors.red .. string.format('[NEUTRONIC_VW] Аккаунт "%s" отправил неверный токен', client.account.name))
    end
    )
end)