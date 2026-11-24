-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- gameplay.lua
-- Handles all gameplay related stuff

local state = require("src.state")
local board = require("src.board")
local popup = require("src.popup")
local file_manager = require("src.file_manager")
local config = require("src.config")
local counter = require("src.counter_timer")
local sound = require("src.sound")
local windowing = require("src.windowing")

local timer = state.timer
local gameState = state.gameState
local difficulty = state.difficulty

local gameplay = {}

function gameplay.initGame(diff)
    if diff == "easy" then
        gameState.setDifficulty(difficulty.EASY)
        config.setConfig("gridHeight", EasyRows)
        config.setConfig("gridWidth", EasyCols)
        config.setConfig("gridMines", EasyMines)
    elseif diff == "medium" then
        gameState.setDifficulty(difficulty.MEDIUM)
        config.setConfig("gridHeight", MedRows)
        config.setConfig("gridWidth", MedCols)
        config.setConfig("gridMines", MedMines)
    elseif diff == "hard" then
        gameState.setDifficulty(difficulty.HARD)
        config.setConfig("gridHeight", HardRows)
        config.setConfig("gridWidth", HardCols)
        config.setConfig("gridMines", HardMines)
    elseif diff == "custom" then
        gameState.setDifficulty(difficulty.CUSTOM)

        local maxCols, maxRows = windowing.maxGrid(1)
        local width = math.max(9, math.min(config.gridWidth, 99, maxCols))
        local height = math.max(9, math.min(config.gridHeight, 99, maxRows))
        local mines = math.max(10, math.min(config.gridMines, (width - 1) * (height - 1)))
        config.setConfig("gridWidth", width)
        config.setConfig("gridHeight", height)
        config.setConfig("gridMines", mines)
    else
        error("Invalid difficulty")
    end

    local map_width, map_height = windowing.mapSize(config.gridHeight, config.gridWidth)

    Face_x = (map_width / 2) - 14

    local x, y, displayIndex = love.window.getPosition()

    windowing.setModeSafe(map_width, map_height, config.scaleFactor)
    love.window.setPosition(x, y, displayIndex)
    windowing.keepOnScreen()

    GameWidth, GameHeight = map_width, map_height

    gameState.newGame()
end

function gameplay.playGame()
    if gameState.is(gameState.GAME_OVER) or gameState.is(gameState.VICTORY) then
        return
    end

    if board.checkVictory() then
        local newTime = timer:getTime()
        local diff = gameState.getDifficulty()

        if file_manager.isHighScore(newTime, diff) then
            popup.setup("HighScore")
            popup.show("HighScore")
        end
        gameState.changeState(gameState.VICTORY)
        gameplay.victory()
        sound.play("clap")
    end
end

function gameplay.newGame()
    if not InitGame then
        board.initBoard()
        gameState.resetMinecount()
        timer:reset()
        counter.init()
        popup.load()
        file_manager.save_difficulty(gameState.getDifficulty())
        InitGame = true
    end
end

function gameplay.victory()
    gameState.mineCountVictory()

    for r = 1, #board.grid do
        for c = 1, #board.grid[r] do
            local tile = board.grid[r][c]
            if tile.isCovered and not tile.isFlagged then
                tile.isFlagged = true
            end
        end
    end
end

function gameplay.gameOver()
    for r = 1, #board.grid do
        for c = 1, #board.grid[r] do
            local tile = board.grid[r][c]
            if tile.isCovered and tile.isMine and not tile.isFlagged then
                tile.isCovered = false
            end
            if tile.isFlagged and not tile.isMine then
                tile.isCovered = false
                tile.isFlagged = false
                tile.isFake = true
            end
        end
    end
end

return gameplay
