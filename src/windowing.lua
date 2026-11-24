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

local topMargin = 30
local bottomMargin = 50

local function desktopSize()
    local _, _, displayIndex = love.window.getPosition()
    local w, h = love.window.getDesktopDimensions(displayIndex)
    return w, h, displayIndex
end

function windowing.mapSize(rows, cols)
    return (cols + 2) * TileSize, (rows + 5 + 1) * TileSize + MenuHeight
end

function windowing.maxGrid(scale)
    scale = scale or config.scaleFactor
    local screenW, screenH = desktopSize()
    local maxCols = math.floor(screenW / scale / TileSize) - 2
    local maxRows = math.floor((screenH / scale - MenuHeight) / TileSize) - 6
    return maxCols, maxRows
end

function windowing.keepOnScreen()
    local x, y, displayIndex = love.window.getPosition()
    local screenW, screenH = love.window.getDesktopDimensions(displayIndex)
    local w, h = love.graphics.getDimensions()

    local newX = math.max(0, math.min(x, screenW - w))
    local newY = math.max(topMargin, math.min(y, screenH - bottomMargin - h))
    newY = math.max(0, newY)

    if newX ~= x or newY ~= y then
        love.window.setPosition(newX, newY, displayIndex)
    end
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
