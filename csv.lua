local csv = {}

csv.open = function(path)
    local file, err = io.open(path, "r")

    if not file then
        error("File not found at '" .. path .. "': " .. err, 2)
    end

    local String = file:read("*a")
    file:close()
    
    return String 
end

csv.parseRow = function(input, delimiter, pos)
    local row = {}
    local field = {}

    while pos <= #input do
        local char = input:sub(pos, pos)

        if char == delimiter then
            row[#row + 1] = table.concat(field)
            field = {}
            pos = pos + 1

        elseif char == "\n" then
            row[#row + 1] = table.concat(field)
            return row, pos + 1

        else
            field[#field + 1] = char
            pos = pos + 1
        end
    end

    if #field > 0 then
        row[#row + 1] = table.concat(field)
    end
    
    return #row > 0 and row or nil, pos
end

csv.parse = function(path, options)
    local input = csv.open(path)

    local rows = {}
    local pos = 1

    options = csv.parseOptions(options)
    local delimiter = options.delimiter

    while true do
        local row, nextPos = csv.parseRow(input, delimiter, pos)

        if not row then
            break
        end

        rows[#rows + 1] = row
        pos = nextPos
    end

    return rows
end

local defaultOptions = {
    delimiter = {
        defaultValue = ",",
        type = "string"
    },
    header = {
        defaultValue = false,
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
            "Invalid option '" .. inputKey ..
            "': expected " .. default.type .. ", got " .. type(inputValue)
        )
    end
    
    return inputValue
end

function csv.parseOptions(inputOptions)
    local parsedOptions = {}
    
    if inputOptions then
        for key, value in pairs(inputOptions) do
            parsedOptions[key] = csv.validateOption(key, value)
        end
    end

    for key, value in pairs(defaultOptions) do
        if parsedOptions[key] == nil then
            parsedOptions[key] = csv.validateOption(key, nil)
        end
    end

    return parsedOptions
end

return csv
