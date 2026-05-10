-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- config.lua
-- Handles config settings

local config = {
    qMarks = false,
    sound = true,
    scaleFactor = 1,
    gridHeight = 0,
    gridWidth = 0,
    gridMines = 0,
    version = "1.4.1",
}

function config.setConfig(option, value)
    if config[option] ~= nil then
        config[option] = value
    end
end

function config.toggleScale()
    config.scaleFactor = config.scaleFactor == 1 and 2 or 1
end

function config.isScaled()
    return config.scaleFactor == 2
end

function config.setScaleFactor(value)
    if value == 1 or value == 2 then
        config.scaleFactor = value
    end
end

function config.toggleQMarks()
    config.qMarks = not config.qMarks
end

function config.toggleSound()
    config.sound = not config.sound
end

return config
