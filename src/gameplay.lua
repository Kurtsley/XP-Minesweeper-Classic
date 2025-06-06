-- gameplay.lua
-- Handles all gameplay related stuff

local state = require("src.state")
local board = require("src.board")
local popup = require("src.popup")
local file_manager = require("src.file_manager")
local config = require("src.config")
local counter = require("src.counter_timer")
local sound = require("src.sound")

local timer = state.timer
local gameState = state.gameState
local difficulty = state.difficulty

local gameplay = {}

function gameplay.startNewGame(diff)
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
    else
        error("Invalid difficulty")
    end

    gameplay.gameStart()

    local map_width = (config.gridWidth + 2) * TileSize
    local map_height = (config.gridHeight + 5 + 1) * TileSize

    Face_x = (map_width / 2) - 14

    local x, y = love.window.getPosition()

    love.window.setMode(map_width, map_height + MenuHeight, {
        fullscreen = false,
        resizable = false,
        vsync = true,
        highdpi = true,
    })
    love.window.setPosition(x, y)

    gameState.changeState(gameState.NEW_GAME)
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
        sound.play("clap")
    end
end

function gameplay.gameStart()
    board.initBoard()
    gameState.resetMinecount()
    timer:reset()
    counter.init()
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
            if tile.isCovered and tile.isMine then
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
