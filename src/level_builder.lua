-- level_builder.lua
-- Handles building of levels

local tilesets = require("src.tilesets")
local config = require("src.config")

local level_builder = {}

local tileSize = 16

function level_builder.buildMap(rows, cols)
    local TOPLEFT = "topleft"
    local TOPRIGHT = "topright"
    local LEFTEDGE = "leftedge"
    local TOP = "topmid"
    local RIGHTEDGE = "rightedge"
    local BOTTOM = "bottommid"
    local BOTTOMLEFT = "bottomleft"
    local BOTTOMRIGHT = "bottomright"
    local BLANK = "blank"
    local MIDMID = "midmid"
    local LEFTMID = "leftmid"
    local RIGHTMID = "rightmid"

    local COUNTERTOPLEFT = "ctopleft"
    local COUNTERTOP = "ctopmid"
    local COUNTERTOPRIGHT = "ctopright"
    local COUNTERLEFT = "cleft"
    local COUNTERRIGHT = "cright"
    local COUNTERBOTTOMLEFT = "cbottomleft"
    local COUNTERBOTTOM = "cbottom"
    local COUNTERBOTTOMRIGHT = "cbottomright"

    local gridHeight = rows
    local gridWidth = cols
    local uiOffset = 5

    local totalWidth = gridWidth + 2
    local totalHeight = gridHeight + uiOffset + 1

    local uiMap = {}

    for y = 1, totalHeight do
        uiMap[y] = {}
        for x = 1, totalWidth do
            -- All blank to start
            uiMap[y][x] = { type = BLANK }
            -- Top
            if y == 1 then
                uiMap[y][x] = { type = TOP }
            end
            -- Bottom
            if y == totalHeight then
                uiMap[y][x] = { type = BOTTOM }
            end
            -- Left
            if x == 1 then
                if y == 1 then
                    uiMap[y][x] = { type = TOPLEFT }
                elseif y == totalHeight then
                    uiMap[y][x] = { type = BOTTOMLEFT }
                else
                    uiMap[y][x] = { type = LEFTEDGE }
                end
            end
            -- Right
            if x == totalWidth then
                if y == 1 then
                    uiMap[y][x] = { type = TOPRIGHT }
                elseif y == totalHeight then
                    uiMap[y][x] = { type = BOTTOMRIGHT }
                else
                    uiMap[y][x] = { type = RIGHTEDGE }
                end
            end
            -- Middle
            if y == uiOffset then
                if x == 1 then
                    uiMap[y][x] = { type = LEFTMID }
                elseif x == totalWidth then
                    uiMap[y][x] = { type = RIGHTMID }
                else
                    uiMap[y][x] = { type = MIDMID }
                end
            end
            -- Counter left
            if x > 1 and x <= uiOffset then
                if y == 2 then
                    if x == 2 then
                        uiMap[y][x] = { type = COUNTERTOPLEFT }
                    elseif x == uiOffset then
                        uiMap[y][x] = { type = COUNTERTOPRIGHT }
                    else
                        uiMap[y][x] = { type = COUNTERTOP }
                    end
                elseif y == 3 then
                    if x == 2 then
                        uiMap[y][x] = { type = COUNTERLEFT }
                    elseif x == uiOffset then
                        uiMap[y][x] = { type = COUNTERRIGHT }
                    end
                elseif y == 4 then
                    if x == 2 then
                        uiMap[y][x] = { type = COUNTERBOTTOMLEFT }
                    elseif x == uiOffset then
                        uiMap[y][x] = { type = COUNTERBOTTOMRIGHT }
                    else
                        uiMap[y][x] = { type = COUNTERBOTTOM }
                    end
                end
            end
            -- Counter right
            if x > totalWidth - uiOffset and x <= totalWidth - 1 then
                if y == 2 then
                    if x == totalWidth - uiOffset + 1 then
                        uiMap[y][x] = { type = COUNTERTOPLEFT, side = "right" }
                    elseif x == totalWidth - 1 then
                        uiMap[y][x] = { type = COUNTERTOPRIGHT, side = "right" }
                    else
                        uiMap[y][x] = { type = COUNTERTOP, side = "right" }
                    end
                elseif y == 3 then
                    if x == totalWidth - uiOffset + 1 then
                        uiMap[y][x] = { type = COUNTERLEFT, side = "right" }
                    elseif x == totalWidth - 1 then
                        uiMap[y][x] = { type = COUNTERRIGHT, side = "right" }
                    end
                elseif y == 4 then
                    if x == totalWidth - uiOffset + 1 then
                        uiMap[y][x] = { type = COUNTERBOTTOMLEFT, side = "right" }
                    elseif x == totalWidth - 1 then
                        uiMap[y][x] = { type = COUNTERBOTTOMRIGHT, side = "right" }
                    else
                        uiMap[y][x] = { type = COUNTERBOTTOM, side = "right" }
                    end
                end
            end
        end
    end

    return uiMap
end

function level_builder.drawTile(type, x, y, side)
    -- Must shift right counter border over by one to
    -- try to match the left side, ugh...
    local xOffset = 0
    if side == "right" then
        xOffset = 1
    end
    -- Counter border
    if type == "ctopleft" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.topleft, x + xOffset, y)
    elseif type == "ctopmid" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.topmid, x + xOffset, y)
    elseif type == "ctopright" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.topright, x + xOffset, y)
    elseif type == "cleft" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.left, x + xOffset, y)
    elseif type == "cright" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.right, x + xOffset, y)
    elseif type == "cbottomleft" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.bottomleft, x + xOffset, y)
    elseif type == "cbottom" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.bottom, x + xOffset, y)
    elseif type == "cbottomright" then
        love.graphics.draw(tilesets.counterBorder.image, tilesets.counterBorder.quads.bottomright, x + xOffset, y)
        -- Border
    elseif type == "topleft" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.topleft, x, y)
    elseif type == "topright" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.topright, x, y)
    elseif type == "leftedge" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.leftedge, x, y)
    elseif type == "topmid" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.topmid, x, y)
    elseif type == "rightedge" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.rightedge, x, y)
    elseif type == "bottommid" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.bottommid, x, y)
    elseif type == "bottomleft" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.bottomleft, x, y)
    elseif type == "bottomright" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.bottomright, x, y)
    elseif type == "blank" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.blank, x, y)
    elseif type == "midmid" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.midmid, x, y)
    elseif type == "leftmid" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.leftmid, x, y)
    elseif type == "rightmid" then
        love.graphics.draw(tilesets.border.image, tilesets.border.quads.rightmid, x, y)
    end
end

function level_builder.drawMap(rows, cols)
    local uiMap = level_builder.buildMap(rows, cols)

    for y, row in ipairs(uiMap) do
        for x, cell in ipairs(row) do
            local drawX = (x - 1) * tileSize
            local drawY = (y - 1) * tileSize + MenuHeight

            if cell then
                level_builder.drawTile(cell.type, drawX, drawY, cell.side)
            end
        end
    end
end

return level_builder
