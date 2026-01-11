-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- tile.lua
-- Handles tile drawing, revealing, and logic

local board = require("src.board")
local state = require("src.state")
local tilesets = require("src.tilesets")
local sound = require("src.sound")

local gameState = state.gameState

local Tile = {
    row = 0,
    col = 0,
    isMine = false,
    isCovered = true,
    isFlagged = false,
    isHeld = false,
    isExploded = false,
    isBlank = false,
    isFake = false,
    isQuestion = false,
    adjacentMines = 0,
}

function Tile.new(isMine, adjacentMines, row, col)
    local newTile = {}

    for key, value in pairs(Tile) do
        newTile[key] = value
    end

    newTile.isMine = isMine or false
    newTile.adjacentMines = adjacentMines or 0
    newTile.row = row or 0
    newTile.col = col or 0

    return newTile
end

function Tile.revealTile(startRow, startCol)
    local stack = {}
    table.insert(stack, { startRow, startCol })

    while #stack > 0 do
        local pos = table.remove(stack)
        local row, col = pos[1], pos[2]
        local tile = board.grid[row][col]

        if not tile.isCovered or tile.isFlagged then
            goto continue
        end

        tile.isCovered = false

        if tile.isMine then
            tile.isExploded = true
            gameState.changeState(gameState.GAME_OVER)
            sound.play("explode")
            return
        end

        if tile.adjacentMines == 0 then
            local dirs = {
                { -1, 1 },
                { -1, 0 },
                { -1, -1 },
                { 0,  -1 },
                { 1,  -1 },
                { 1,  0 },
                { 1,  1 },
                { 0,  1 },
            }

            for _, dir in ipairs(dirs) do
                local dx, dy = dir[1], dir[2]
                local nx, ny = col + dx, row + dy

                if ny >= 1 and ny <= #board.grid and
                    nx >= 1 and nx <= #board.grid[ny] then
                    local neighbor = board.grid[ny][nx]
                    if neighbor.isCovered and not neighbor.isMine then
                        table.insert(stack, { ny, nx })
                    end
                end
            end
        end

        sound.play("pop")
        ::continue::
    end
end

function Tile.drawTile(tile, x, y)
    if tile.isCovered then
        if tile.isHeld then
            if tile.isQuestion then
                love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.qmarkdown, x, y)
            else
                love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.blank, x, y)
            end
        elseif tile.isFlagged then
            love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.flag, x, y)
        elseif tile.isQuestion then
            love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.qmarkup, x, y)
        else
            love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.tileup, x, y)
        end
    elseif tile.isExploded then
        love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.explode, x, y)
    elseif tile.isMine then
        love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.mine, x, y)
    elseif tile.isFake then
        love.graphics.draw(tilesets.cell.image, tilesets.cell.quads.nomine, x, y)
    else
        local mineCount = tile.adjacentMines
        local quadsToDraw = board.adjacentMinesLookup(mineCount)
        love.graphics.draw(tilesets.cell.image, quadsToDraw, x, y)
    end
end

return Tile
