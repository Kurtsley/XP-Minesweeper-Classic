-- MIT License, Copyright (c) 2025 Kurtsley

-- tilesets.lua
-- Load and export the tilesets

local cellTileSize = 16
local counterTileSize = { 16, 32 }
local faceTileSize = 28
local counterBorderTileSize = 16

local cellImage = love.graphics.newImage("assets/tilesets/WinmineXP.png")
local counterImage = love.graphics.newImage("assets/tilesets/countersmall.png")
local faceImage = love.graphics.newImage("assets/tilesets/facesfixednew.png")
local counterBorderImage = love.graphics.newImage("assets/tilesets/newbordercounter.png")
local borderImage = love.graphics.newImage("assets/tilesets/bordernew.png")

cellImage:setFilter("nearest", "nearest")
counterImage:setFilter("nearest", "nearest")
faceImage:setFilter("nearest", "nearest")
counterBorderImage:setFilter("nearest", "nearest")
borderImage:setFilter("nearest", "nearest")


local cellQuadData = {
    cell_1 = { 0, 0 },
    cell_2 = { 16, 0 },
    cell_3 = { 32, 0 },
    cell_4 = { 48, 0 },
    cell_5 = { 0, 16 },
    cell_6 = { 16, 16 },
    cell_7 = { 32, 16 },
    cell_8 = { 48, 16 },
    blank = { 0, 32 },
    tileup = { 16, 32 },
    flag = { 32, 32 },
    nomine = { 48, 32 },
    qmarkdown = { 0, 48 },
    qmarkup = { 16, 48 },
    mine = { 32, 48 },
    explode = { 48, 48 },
}

local cellQuads = {}

for name, pos in pairs(cellQuadData) do
    cellQuads[name] = love.graphics.newQuad(pos[1], pos[2], cellTileSize, cellTileSize, cellImage:getDimensions())
end

local counterQuadData = {
    counter_0 = { 0, 0 },
    counter_dash = { 16, 0 },
    counter_9 = { 32, 0 },
    counter_8 = { 48, 0 },
    counter_7 = { 0, 32 },
    counter_6 = { 16, 32 },
    counter_5 = { 32, 32 },
    counter_4 = { 48, 32 },
    counter_3 = { 0, 64 },
    counter_2 = { 16, 64 },
    counter_1 = { 32, 64 },
}

local counterQuads = {}

for name, pos in pairs(counterQuadData) do
    counterQuads[name] = love.graphics.newQuad(pos[1], pos[2], counterTileSize[1], counterTileSize[2],
        counterImage:getDimensions())
end

local faceQuadData = {
    dead = { 0, 0 },
    pressed = { 28, 0 },
    normal = { 56, 0 },
    glasses = { 0, 28 },
    surprise = { 28, 28 },
}

local faceQuads = {}

for name, pos in pairs(faceQuadData) do
    faceQuads[name] = love.graphics.newQuad(pos[1], pos[2], faceTileSize, faceTileSize, faceImage:getDimensions())
end

local counterBorderQuadData = {
    topleft = { 0, 0 },
    topmid = { 16, 0 },
    topright = { 32, 0 },
    left = { 0, 16 },
    right = { 16, 16 },
    bottomleft = { 32, 16 },
    bottom = { 0, 32 },
    bottomright = { 16, 32 },
}

local counterBorderQuads = {}

for name, pos in pairs(counterBorderQuadData) do
    counterBorderQuads[name] = love.graphics.newQuad(pos[1], pos[2], counterBorderTileSize, counterBorderTileSize,
        counterBorderImage:getDimensions())
end

local borderQuadData = {
    rightmid = { 0, 0 },
    leftmid = { 16, 0 },
    topleft = { 32, 0 },
    topbottom = { 0, 16 },
    topright = { 16, 16 },
    bottomright = { 32, 16 },
    bottomleft = { 0, 32 },
    leftright = { 16, 32 },
    blank = { 32, 32 },
}

local borderQuads = {}

for name, pos in pairs(borderQuadData) do
    borderQuads[name] = love.graphics.newQuad(pos[1], pos[2], cellTileSize, cellTileSize, borderImage:getDimensions())
end

return {
    cell = {
        image = cellImage,
        quads = cellQuads,
        size = cellTileSize,
    },
    counter = {
        image = counterImage,
        quads = counterQuads,
        size = counterTileSize
    },
    face = {
        image = faceImage,
        quads = faceQuads,
        size = faceTileSize,
    },
    counterBorder = {
        image = counterBorderImage,
        quads = counterBorderQuads,
        size = counterBorderTileSize,
    },
    border = {
        image = borderImage,
        quads = borderQuads,
        size = cellTileSize,
    }
}
