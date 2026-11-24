-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- fonts.lua
-- loads all fonts

local fonts = {}

local config = require("src.config")

local fontPath = "assets/fonts/Roboto-Regular.ttf"

local loadedScale

function fonts.load()
    local scale = config.scaleFactor or 1
    if loadedScale == scale then return end
    loadedScale = scale

    love.graphics.setDefaultFilter("nearest", "nearest")

    fonts.menu = love.graphics.newFont(fontPath, 12, "normal", scale)
    fonts.small = love.graphics.newFont(fontPath, 10, "normal", scale)
    fonts.medium = love.graphics.newFont(fontPath, 14, "normal", scale)
    fonts.large = love.graphics.newFont(fontPath, 20, "normal", scale)
end

return fonts
