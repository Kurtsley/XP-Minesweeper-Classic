-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- file_manager.lua
-- Handles saving and loading scores

local json = require("libs.json")
local config = require("src.config")

local file_manager = {
    systemWritable = false,
}

local defaultTimes = {
    easy = 999.999,
    medium = 999.999,
    hard = 999.999
}

local saveName = "save.json"
local oldSave = "times.json"

local validDifficulties = { easy = true, medium = true, hard = true, custom = true }

local function copyDefaults()
    local t = {}
    for k, v in pairs(defaultTimes) do
        t[k] = v
    end
    return t
end

local function safeDecode(contents)
    if type(contents) ~= "string" then return nil end
    local ok, data = pcall(json.decode, contents)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function clampInt(value, min, max)
    value = math.floor(tonumber(value) or min)
    return math.max(min, math.min(max, value))
end

local function isSystemWritable()
    local testFile = "test.txt"

    love.filesystem.write(testFile, "test")
    if love.filesystem.getInfo(testFile) then
        love.filesystem.remove(testFile)
        file_manager.systemWritable = true
        return true
    end

    return false
end

function file_manager.init()
    local popup = require("src.popup")

    if not isSystemWritable() then
        popup.setup("SaveError")
        popup.show("SaveError")
    end

    local existing = love.filesystem.read(saveName)
    if not safeDecode(existing) then
        if existing and not love.filesystem.getInfo(saveName .. ".bak") then
            love.filesystem.write(saveName .. ".bak", existing)
        end
        love.filesystem.write(saveName, json.encode(file_manager.load()))
    end
end

function file_manager.isHighScore(time, difficulty)
    -- Only track the basic 3 difficulties
    if difficulty == "custom" or not file_manager.systemWritable then return end

    local times = file_manager.load()

    return time < times[difficulty]
end

function file_manager.resetScores()
    local data = file_manager.load()

    for diff, time in pairs(defaultTimes) do
        data[diff] = time
    end

    love.filesystem.write(saveName, json.encode(data))
end

function file_manager.save_times(difficulty, newTime)
    -- Only track the basic 3 difficulties
    if difficulty == "custom" then return end

    local data = file_manager.load()

    if data then
        data[difficulty] = newTime
        local encoded = json.encode(data)
        love.filesystem.write(saveName, encoded)
    end
end

function file_manager.save_difficulty(difficulty)
    local data = file_manager.load()

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
        love.filesystem.write(saveName, encoded)
    end
end

function file_manager.save_scale()
    local data = file_manager.load()

    if data then
        local scale = config.scaleFactor
        data.scale = scale or 1

        local encoded = json.encode(data)
        love.filesystem.write(saveName, encoded)
    end
end

function file_manager.save_options()
    local data = file_manager.load()

    if data then
        local marks = config.qMarks
        local sound = config.sound
        data.marks = marks == nil and false or marks
        data.sound = sound == nil and true or sound

        local encoded = json.encode(data)
        love.filesystem.write(saveName, encoded)
    end
end

function file_manager.load()
    local data = safeDecode(love.filesystem.read(saveName))
        or safeDecode(love.filesystem.read(oldSave))
        or copyDefaults()

    for diff, time in pairs(defaultTimes) do
        data[diff] = tonumber(data[diff]) or time
    end

    return data
end

function file_manager.load_options()
    local data = file_manager.load()
    local marks = false
    local sound = true

    if type(data.marks) == "boolean" then
        marks = data.marks
    end

    if type(data.sound) == "boolean" then
        sound = data.sound
    end

    config.setConfig("qMarks", marks)
    config.setConfig("sound", sound)
end

function file_manager.load_scale()
    local data = file_manager.load()

    config.setScaleFactor(data.scale or 1)
end

function file_manager.load_difficulty()
    local defaultDiff = "easy"
    local data = file_manager.load()
    local lastDiff = data.last_difficulty

    if not validDifficulties[lastDiff] then
        return defaultDiff
    end

    if lastDiff == "custom" then
        local customBoard = data.custom_board

        if type(customBoard) ~= "table" then
            return defaultDiff
        end

        local width = clampInt(customBoard.width, 9, 99)
        local height = clampInt(customBoard.height, 9, 99)
        local mines = clampInt(customBoard.mines, 10, (width - 1) * (height - 1))

        config.setConfig("gridWidth", width)
        config.setConfig("gridHeight", height)
        config.setConfig("gridMines", mines)
    end

    return lastDiff
end

return file_manager
