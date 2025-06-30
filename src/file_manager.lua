-- MIT License, Copyright (c) 2025 Kurtsley

-- file_manager.lua
-- Handles saving and loading scores

local json = require("libs.json")
local config = require("src.config")

local file_manager = {}

local defaultTimes = {
    easy = 999.999,
    medium = 999.999,
    hard = 999.999
}

function file_manager.init()
    if not love.filesystem.getInfo("times.json") then
        local times   = defaultTimes

        local endoded = json.encode(times)
        love.filesystem.write("times.json", endoded)
    end
end

function file_manager.isHighScore(time, difficulty)
    -- Only track the basic 3 difficulties
    if difficulty == "custom" then return end

    local times = file_manager.load()

    if times then
        if time < times[difficulty] then
            return true
        end
    end

    return false
end

function file_manager.resetScores()
    local times = defaultTimes

    for diff, time in pairs(times) do
        file_manager.save_times(diff, time)
    end
end

function file_manager.save_times(difficulty, newTime)
    -- Only track the basic 3 difficulties
    if difficulty == "custom" then return end

    local data = file_manager.load() or {}

    if data then
        data[difficulty] = newTime
        local encoded = json.encode(data)
        love.filesystem.write("times.json", encoded)
    end
end

function file_manager.save_difficulty(difficulty)
    local data = file_manager.load() or {}

    if data then
        data.last_difficulty = difficulty

        if difficulty == "custom" then
            data.custom_board = {
                width = config.gridWidth,
                height = config.gridHeight,
                mines = config.gridMines,
            }
        else
            data.custom_board = nil
        end

        local encoded = json.encode(data)
        love.filesystem.write("times.json", encoded)
    end
end

function file_manager.load()
    if love.filesystem.getInfo("times.json") then
        local contents = love.filesystem.read("times.json")

        if contents then
            local times = json.decode(contents)
            return times
        end
    end
end

function file_manager.load_difficulty()
    local defaultDiff = "easy"

    if love.filesystem.getInfo("times.json") then
        local contents = love.filesystem.read("times.json")

        if contents then
            local data = json.decode(contents)
            local lastDiff = data.last_difficulty or defaultDiff
            local customBoard = data.custom_board

            if lastDiff == "custom" and customBoard then
                config.setConfig("gridWidth", customBoard.width)
                config.setConfig("gridHeight", customBoard.height)
                config.setConfig("gridMines", customBoard.mines)
            end

            return lastDiff
        end
    end

    return defaultDiff
end

return file_manager
