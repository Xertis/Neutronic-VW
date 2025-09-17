local config_path = pack.shared_file("neutronic_vw", "conf.json")
if not file.exists(config_path) then
    file.write(config_path, file.read("neutronic_vw:default_config.json"))
end

local globals = require "globals"
local config = json.parse(file.read(config_path))

globals.config.access_token = config.access_token
globals.config.refresh_token = config.refresh_token
globals.config.expires_in = tonumber(config.expires_in)