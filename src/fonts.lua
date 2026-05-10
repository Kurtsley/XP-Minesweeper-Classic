-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- fonts.lua
-- loads all fonts

local fonts = {}

local fontPath = "assets/fonts/Roboto-Regular.ttf"

function fonts.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    fonts.menu = love.graphics.newFont(fontPath, 12)
    fonts.small = love.graphics.newFont(fontPath, 10)
    fonts.medium = love.graphics.newFont(fontPath, 14)
    fonts.large = love.graphics.newFont(fontPath, 20)
end

return fonts
