local module = {}

function module.gen(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""

    for _ = 1, length do
        local random_index = random.random(1, #chars)
        result = result .. chars:sub(random_index, random_index)
    end

    return result
end

return module