-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- windowing.lua
-- Game window centering and placement

local config = require("src.config")
local windowing = {}

function windowing.centerWindow()
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    local centerX = (screenWidth - (GameWidth * config.scaleFactor)) / 2
    local centerY = math.max(0, (screenHeight - (GameHeight * config.scaleFactor)) / 2)

    love.window.setPosition(centerX, centerY)
end

function windowing.setModeSafe(width, height, scale)
    scale = scale or config.scaleFactor
    local physicalWidth = width * scale
    local physicalHeight = height * scale
    local currentW, currentH = love.graphics.getDimensions()

    if currentW ~= physicalWidth or currentH ~= physicalHeight then
        love.window.setMode(physicalWidth, physicalHeight, {
            fullscreen = false,
            resizable = false,
            vsync = true,
            highdpi = false,
        })
    end
end

return windowing
