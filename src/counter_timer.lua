-- counter.lua
-- Timer and mine counter stuff

local tilesets = require("src.tilesets")
local state = require("src.state")

local gameState = state.gameState
local difficulty = state.difficulty

local counterTimer = {}

local counter_y = 48
local mineCounter_x1 = 23
local mineCounter_x2 = 39
local mineCounter_x3 = 55

local function digitQuadsLookup(digit)
    if digit == 1 then
        return tilesets.counter.quads.counter_1
    elseif digit == 2 then
        return tilesets.counter.quads.counter_2
    elseif digit == 3 then
        return tilesets.counter.quads.counter_3
    elseif digit == 4 then
        return tilesets.counter.quads.counter_4
    elseif digit == 5 then
        return tilesets.counter.quads.counter_5
    elseif digit == 6 then
        return tilesets.counter.quads.counter_6
    elseif digit == 7 then
        return tilesets.counter.quads.counter_7
    elseif digit == 8 then
        return tilesets.counter.quads.counter_8
    elseif digit == 9 then
        return tilesets.counter.quads.counter_9
    else
        return tilesets.counter.quads.counter_0
    end
end

function counterTimer.drawCounter(value, x1, x2, x3, y)
    local xcoords = { x1, x2, x3 }
    value = tonumber(value) or 0

    if value < 0 then
        local absValue = math.abs(value)
        local str = string.format("%02d", absValue)
        love.graphics.draw(tilesets.counter.image, tilesets.counter.quads.counter_dash, x1, y)

        for i = 1, #str do
            local digit = tonumber(str:sub(i, i))
            love.graphics.draw(tilesets.counter.image, digitQuadsLookup(digit), xcoords[i + 1], y)
        end
    else
        local str = string.format("%03d", value)

        for i = 1, #str do
            local digit = tonumber(str:sub(i, i))
            love.graphics.draw(tilesets.counter.image, digitQuadsLookup(digit), xcoords[i], y)
        end
    end
end

function counterTimer.resetTimer()
    return 0
end

function counterTimer.drawMineCounter(mineCount)
    counterTimer.drawCounter(mineCount, mineCounter_x1, mineCounter_x2, mineCounter_x3, counter_y)
end

function counterTimer.drawTimer(timer)
    local timer_x1 = GameWidth - 72
    local timer_x2 = GameWidth - 56
    local timer_x3 = GameWidth - 40

    local timeElapsedSeconds = math.ceil(timer)
    counterTimer.drawCounter(timeElapsedSeconds, timer_x1, timer_x2, timer_x3, counter_y)
end

return counterTimer
