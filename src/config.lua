-- MIT License, Copyright (c) 2025 Kurtsley

-- config.lua
-- Handles config settings

local config = {
    qMarks = false,
    sound = true,
    gridHeight = 0,
    gridWidth = 0,
    gridMines = 0,
    version = "1.3.1",
}

function config.setConfig(option, value)
    if config[option] ~= nil then
        config[option] = value
    end
end

function config.toggleQMarks()
    config.qMarks = not config.qMarks
end

function config.toggleSound()
    config.sound = not config.sound
end

return config
