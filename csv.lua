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
    local config = csv.parseOptions(options)

    local output = {
        headers = nil,
        rows = {}
    }
    local pos = 1

    if config.headers then
        output.headers, pos = csv.parseRow(input, config.delimiter, pos)
    end

    while true do
        local row, nextPos = csv.parseRow(input, config.delimiter, pos)

        if not row then
            break
        end

        output.rows[#output.rows + 1] = row
        pos = nextPos
    end

    return output
end

local defaultOptions = {
    delimiter = {
        defaultValue = ",",
        type = "string"
    },
    headers = {
        defaultValue = false,
        type = "boolean"
    }
}

function csv.validateOption(key, value)
    local default = defaultOptions[key]

    if not default then
        error("Unknown option: " .. key, 2)
    end

    if value == nil then
        return default.defaultValue
    end
    
    if type(value) ~= default.type then
        error(
            "Invalid type for option '" .. key ..
            "': expected " .. default.type ..
            ", got " .. type(value), 2
        )
    end
    
    return value
end

function csv.parseOptions(input)
    local options = {}

    for key in pairs(defaultOptions) do
        local value = input and input[key]
        options[key] = csv.validateOption(key, value)
    end

    if input then
        for key in pairs(input) do
            if not defaultOptions[key] then
                error("Unknown input option: '" .. key .. "'")
            end
        end
    end

    return options
end
    
return csv
