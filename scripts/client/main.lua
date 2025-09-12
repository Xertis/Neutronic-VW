require "init"
local globals = require "globals"

if #globals.config.access_token < 5 then
    require "get_access_token"
end