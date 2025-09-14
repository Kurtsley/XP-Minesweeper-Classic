-- MIT License, Copyright (c) 2025 Kurtsley

-- state.lua
-- Handles all gamestates and counts

local config = require("src.config")
local file_manager = require("src.file_manager")

local gameState = {
    NEW_GAME  = "new_game",
    PLAYING   = "playing",
    GAME_OVER = "game_over",
    VICTORY   = "victory",
}

local difficulty = {
    EASY = "easy",
    MEDIUM = "medium",
    HARD = "hard",
    CUSTOM = "custom",
}

local startingMines = 10

local timer = {}

local currentState = gameState.NEW_GAME
local currentDiff = file_manager.load_difficulty()
local mineCount = startingMines

local altPressed = false

function timer:update(dt)
    if gameState.is(gameState.PLAYING) then
        self.timer = self.timer + dt
    end
end

function timer:reset()
    self.timer = 0
end

function timer:getTime()
    return self.timer
end

function gameState.changeState(newState)
    currentState = newState
end

function gameState.get()
    return currentState
end

function gameState.is(state)
    return currentState == state
end

function gameState.setDifficulty(difficulty)
    currentDiff = difficulty
end

function gameState.getDifficulty()
    return currentDiff
end

function gameState.isDifficulty(difficulty)
    return currentDiff == difficulty
end

function gameState.decrementMinecount()
    mineCount = math.max(-99, mineCount - 1)
end

function gameState.incrementMinecount()
    mineCount = math.min(999, mineCount + 1)
end

function gameState.getMineCount()
    return mineCount
end

function gameState.resetMinecount()
    mineCount = config.gridMines
end

function gameState.mineCountVictory()
    mineCount = 0
end

function gameState.quit()
    love.event.quit()
end

function gameState.newGame()
    InitGame = false
    gameState.changeState(gameState.NEW_GAME)
end

function gameState.isAltPressed()
    return altPressed
end

function gameState.toggleAlt()
    altPressed = not altPressed
end

function gameState.resetAlt()
    altPressed = false
end

function gameState.onKeyPressed(key)
    if key == "escape" then
        gameState.quit()
    elseif key == "f2" then
        gameState.newGame()
    elseif key == "lalt" or key == "ralt" then
        gameState.toggleAlt()
    end
end

return {
    gameState = gameState,
    timer = timer,
    difficulty = difficulty,
}
