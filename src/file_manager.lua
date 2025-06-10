-- MIT License, Copyright (c) 2025 Kurtsley

-- file_manager.lua
-- Handles saving and loading scores

local json = require("libs.json")

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
        file_manager.save(diff, time)
    end
end

function file_manager.save(difficulty, newTime)
    -- Only track the basic 3 difficulties
    if difficulty == "custom" then return end

    local times = file_manager.load()

    if times then
        times[difficulty] = newTime

        local endoded = json.encode(times)
        love.filesystem.write("times.json", endoded)
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

return file_manager
