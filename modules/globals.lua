local globals = {}

globals.config = {
    access_token = "",
    refresh_token = "",
    expires_in = 0
}

globals.constants = {
    client_id = 16,
    port = 9090,
    document = {}
}

globals.server = {
    queue = {}
}

globals.constants.redirect_uri = string.format("http://localhost:%s/neutronic", globals.constants.port)

function globals.write()
    local config_path = pack.shared_file("neutronic_vw", "conf.json")
    file.write(config_path, json.tostring(globals.config))
end

return globals