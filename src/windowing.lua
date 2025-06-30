-- MIT License, Copyright (c) 2025 Kurtsley

-- windowing.lua
-- Game window centering and placement

local windowing = {}

function windowing.centerWindow()
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    local centerX = (screenWidth - GameWidth) / 2
    local centerY = math.max(0, (screenHeight - GameHeight) / 2)

    love.window.setPosition(centerX, centerY)
end

function windowing.setModeSafe(width, height)
    local currentW, currentH = love.graphics.getDimensions()

    if currentW ~= width or currentH ~= height then
        love.window.setMode(width, height, {
            fullscreen = false,
            resizable = false,
            vsync = true,
            highdpi = false,
        })
    end
end

return windowing
