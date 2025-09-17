local globals = require "globals"
local hash = require "crypto/sha256"
local rand = require "crypto/rand"

local client_id = globals.constants.client_id
local port = globals.constants.port
local redirect_uri = globals.constants.redirect_uri

local code = nil
local server = nil

local function base64_to_urlsafe(base64)
    local urlsafe = base64:gsub("%+", "-"):gsub("/", "_")

    return urlsafe:gsub("=+$", "")
end

local function exchange_code_for_token(auth_code, code_verifier, callback)
    network.post("https://api.voxelworld.ru/oauth/token",
        {
            grant_type = "authorization_code",
            client_id = client_id,
            code = auth_code,
            redirect_uri = redirect_uri,
            code_verifier = code_verifier
        },
        function(response)
            local data = json.parse(response)
            if data.access_token then
                print("Access token получен")
                globals.config.access_token = data.access_token
                globals.config.refresh_token = data.refresh_token
                globals.config.expires_in = os.time() + data.expires_in
                globals.write()
                callback(data.access_token)
            else
                print("Ошибка при получении токена:", response)
            end
        end,
        function(code, response)
            print("Ошибка HTTP при обмене кода:", code, response)
        end,
        {
            "Accept: application/json"
        }
    )
end

function start_auth()
    local function hex_to_bytes(hex)
        local t = {}
        for cc in hex:gmatch("..") do
            table.insert(t, tonumber(cc, 16))
        end
        return t
    end

    local code_verifier = rand.gen(random.random(60, 120))
    local code_challenge = base64_to_urlsafe(base64.encode(hex_to_bytes(hash.sha256(code_verifier))))

    server = network.tcp_open(port, function(sock)
        local request = sock:recv(1024, true)
        request = utf8.tostring(request)

        if not code then
            local _, start = string.find(request, "?code=")
            local _end = string.find(request, " HTTP")

            code = string.sub(request, start+1, _end-1)

            exchange_code_for_token(code, code_verifier, function (token)
                globals.config.access_token = token
            end)

            server:close()
        end
    end)

    globals.constants.document.root:add(gui.template("vw_auth_app", {
        text = "Перейдите по ссылке для входа в аккаунт VW:\nhttps://api.voxelworld.ru/oauth/authorize" ..
        "?response_type=code" ..
        "&code_challenge_method=S256" ..
        "&code_challenge=" .. code_challenge ..
        "&client_id=" .. client_id ..
        "&scope=user-info" ..
        "&redirect_uri=" .. redirect_uri
    }))
end

start_auth()
