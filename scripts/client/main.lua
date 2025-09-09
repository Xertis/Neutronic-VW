local config_path = pack.shared_file("neutronic_vw", "config.json")
if not file.exists(config_path) then
    file.write(config_path, file.read("neutronic_vw:default_config.json"))
end

local globals = require "globals"
local config = json.parse(file.read(config_path))

globals.config.client_id = config.client_id
globals.config.access_token = config.access_token
globals.config.app_token = config.app_token

if #config.access_token < 5 then
    require "get_access_token"
end