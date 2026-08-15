local csv = {}

function csv.load(inputPath)
    local file = io.open(inputPath, "r")
    
    if not file then error("File not found at " .. path) end
    
    local String = file:read("*a")
    file:close()
    
    return String 
end

function csv.parseRow(inputString,sep, pos)
    local row = {}
    sep = sep or ","
    pos = pos or 1 

    while true do
        local s, e, field, delim = string.find(inputString, "([^%" .. sep .. "\r\n]-)([%" .. sep .. "\r\n])", pos)

        if not e then
            table.insert(row, string.sub(inputString, pos))
        end

        table.insert(row, field)
        pos = e + 1

        if delim == "\n" then
            return row, pos
        end

        if delim == "\r" then
            if string.sub(inputString, pos, pos) == "\n" then
                pos = pos + 1
            end
        end
    end

    return row, pos
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
