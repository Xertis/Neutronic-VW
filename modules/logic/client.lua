require "init"

local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]))[m.side]

local globals = require "globals"

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