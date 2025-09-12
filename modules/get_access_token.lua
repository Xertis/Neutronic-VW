local globals = require "globals"

local client_id = globals.config.client_id
local client_secret = globals.config.app_token

local redirect_uri = "http://localhost:8080/callback"
local code = nil
local server = nil

local function exchange_code_for_token(auth_code, callback)
    network.post("https://api.voxelworld.ru/oauth/token",
        {
            grant_type = "authorization_code",
            client_id = client_id,
            client_secret = client_secret,
            code = auth_code,
            redirect_uri = redirect_uri
        },
        function(response)
            local data = json.parse(response)
            if data.access_token then
                print("Access token получен")
                globals.config.access_token = data.access_token
                globals.write()
                callback(data.access_token)
            else
                print("Ошибка при получении токена:", response)
            end
        end,
        function(code)
            print("Ошибка HTTP при обмене кода:", code)
        end
    )
end

function start_auth()
    server = network.tcp_open(8080, function(sock)
        local request = sock:recv(1024, true)
        request = utf8.tostring(request)

        local _, start = string.find(request, "?code=")
        local _end = string.find(request, "&")

        code = string.sub(request, start+1, _end-1)
        server:close()
        exchange_code_for_token(code, function (token)
            globals.config.access_token = token
        end)
    end)

    events.on("quartz:server_list_opened", function (document)
        document.root:add(gui.template("vw_auth_app", {
            text = "Перейдите по ссылке для входа в аккаунт VW: https://api.voxelworld.ru/oauth/authorize" ..
            "?response_type=code" ..
            "&client_id=" .. client_id ..
            "&scope=user-info" ..
            "&redirect_uri=" .. redirect_uri ..
            "&state=xyz123"
        }))
    end)
end

start_auth()
