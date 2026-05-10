-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- helper.lua
-- Stores helper functions

local config = require("src.config")
local helper = {}

function helper.round(value)
    return math.floor(value + 0.5)
end

function helper.getMousePosition()
    local x, y = love.mouse.getPosition()
    local scale = config.scaleFactor or 1
    return x / scale, y / scale
end

return helper
