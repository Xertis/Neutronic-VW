require "init"

local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]))[m.side]

local globals = require "globals"

local MAX_IMAGE_SIZE = 2^32-1

api.events.on("neutronic_vw", "auth", function ()
    network.post("https://api.voxelworld.ru/v2/one-time-token/generate",
        {},
        function(response)
            local token = json.parse(response).one_time_token

            api.events.send("neutronic_vw", "token", api.bson.serialize({
                token = token
            }))
        end,
        function(code, response)
            if code == 401 then
                gui.alert("Произошла ошибка во время генерации одноразового токена, вероятно, вы не вошли в аккаунт VoxelWorld")
            else
                gui.alert("Произошла ошибка во время генерации одноразового токена\nКод ошибки: " .. code)
            end
            print(code, response)
        end,
        {
            "Authorization: Bearer " .. globals.config.access_token,
            "Accept: application/json"
        }
    )
    end
)

api.events.on("neutronic_vw", "avatar", function (bytes)
    local data = api.bson.deserialize(bytes)

    local username = data.username
    local url = data.url

    if not string.ends_with(string.lower(url), ".png") then
        return
    end

    network.get_binary(
        url,
        function (avatar_bytes)
            if #avatar_bytes > MAX_IMAGE_SIZE then
                return
            end

            local avatar_id = "NEUTRONIC_VW_AVATAR_" .. username

            local status, err = pcall(assets.load_texture,
                avatar_bytes,
                avatar_id
            )

            if not status then
                print(err)
                return
            end

            globals.client.avatars[username] = avatar_id
        end
    )
end)

events.on("quartz:pause_opened", function (document)
    for name, avatar_id in pairs(globals.client.avatars) do
        pcall(function ()
            document["player_icon_" .. name].src = avatar_id
        end)
    end
end)