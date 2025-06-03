-- config.lua
-- Handles config settings

local config = {
    qMarks = false,
    gridHeight = 0,
    gridWidth = 0,
    gridMines = 0,
}

function config.setConfig(option, value)
    if config[option] ~= nil then
        config[option] = value
    end
end

function config.toggleQMarks()
    config.qMarks = not config.qMarks
end

return config
