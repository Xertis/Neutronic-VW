require "init"

local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[1]) )[m.side]

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
        function(code)
            print(code)
        end,
        {
            "Authorization: Bearer " .. globals.config.access_token,
        }
    )
    end
)