local globals = {}

globals.config = {
    access_token = ""
}

function globals.write()
    local config_path = pack.shared_file("neutronic_vw", "config.json")
    file.write(config_path, json.tostring(globals.config))
end

return globals