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

function gameState.onKeyPressed(key)
    if key == "escape" then
        gameState.quit()
    end
end

return {
    gameState = gameState,
    timer = timer,
    difficulty = difficulty,
}
