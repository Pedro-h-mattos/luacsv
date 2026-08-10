local csv = {}

function csv.load(inputPath)
    local file = io.open(path, "r")
    
    if not file then error("File not found at " .. path) end
    
    local string = file:read("*a")
    file:close()
    
    return string
end

function csv.parse(input, sep, pos)
    local row = {} 
    pos = pos or 1
    sep = sep or ","

    while true do
        local s, e, field, delimiter = string.find(input, "([^%"..sep.."\r\n]-)([%"..sep.."\r\n])", pos)
        
        if not e then
            table.insert(row, string.sub(input, pos))
            return row, #input + 1
        end

        table.insert(row, field)
        pos = e + 1

        if delimiter == "\n" then
            return row, pos

        elseif delimiter == "\r" then
           if string.sub(input, pos, pos) == "\n" then
            pos = pos + 1
           end

           return row, pos
        end
    end
end

local defaultOptions = {
    headers = {
        defaultValue = true,
        type = "boolean"
    },
    trimWhitespace = {
        defaultValue = true,
        type = "boolean"
    }
}

function csv.validateOption(inputKey, inputValue)
    local default = defaultOptions[inputKey]

    if not default then
        error("Unknown input option: '" .. inputKey .. "'")
    end

    if inputValue == nil then
        return default.defaultValue
    end
    
    if type(inputValue) ~= default.type then
        error(
            "Invalid value type for input option '" .. inputKey ..
            "': expected " .. default.type .. ", got " .. type(inputValue)
        )
    end
    
    return inputValue
end

function csv.parseOptions(inputOptions)
    inputOptions = inputOptions or {}

    local parsedOptions = {}
    
    for key, value in pairs(inputOptions) do
        parsedOptions[key] = csv.validateOption(key, value)
    end

    for key, value in pairs(defaultOptions) do
        if parsedOptions[key] == nil then
            parsedOptions[key] = csv.validateOption(key, nil)
        end
    end

    return parsedOptions
end

return csv