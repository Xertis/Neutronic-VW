require "init"
local globals = require "globals"

events.on("quartz:server_list_opened", function (document)
    globals.constants.document = document
end)

if #globals.config.access_token < 5 then
    require "get_access_token"
elseif os.time() >= globals.config.expires_in then
    network.post("https://api.voxelworld.ru/oauth/token",
        {
            grant_type = "refresh_token",
            client_id = globals.constants.client_id,
            refresh_token = globals.config.refresh_token
        },
        function(response)
            local data = json.parse(response)

            if data.access_token then
                print("Access token обновлён")
                globals.config.access_token = data.access_token
                globals.config.refresh_token = data.refresh_token
                globals.config.expires_in = os.time() + data.expires_in
                globals.write()
            else
                print("Ошибка при обновлении токена:", response)
            end
        end,
        function(code, response)
            print("Код:", code, "токен просрочен")
            require "get_access_token"
        end,
        {
            "Accept: application/json"
        }
    )
end