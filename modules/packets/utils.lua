local module = {}

function module.double_array_encode(arr1, arr2)
    local bytes = Bytearray()

    bytes:append(byteutil.pack(">I", #arr1))

    bytes:append(arr1)
    bytes:append(arr2)

    return bytes
end

function module.double_array_decode(bytes)
    local arr1 = Bytearray()
    local arr2 = Bytearray()

    local len1 = byteutil.unpack(">I", bytes)

    for i=5, len1+4 do
        arr1:append(bytes[i])
    end

    for i=len1+5, #bytes do
        arr2:append(bytes[i])
    end

    return arr1, arr2
end

return module