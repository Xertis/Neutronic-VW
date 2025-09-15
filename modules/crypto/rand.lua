local module = {}

function module.pseudorand(length)
    local charset = "abcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}

    local seed = collectgarbage("count") * 1000 + os.clock() * 1000 + math.round(time.uptime() * 1000)

    for i = 1, length do
        seed = (seed * 9301 + 49297) % 233280
        local index = math.floor(seed / 233280 * #charset) + 1
        table.insert(result, charset:sub(index, index))
    end

    return table.concat(result)
end

return module