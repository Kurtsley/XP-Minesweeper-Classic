-- MIT License, Copyright (c) 2025 Kurtsley

-- inputhandlers.lua
-- Handles the input callbacks

local board = require("src.board")
local state = require("src.state")
local gameState = state.gameState
local game_menu = require("src.game_menu")
local popup = require("src.popup")

local inputhandlers = {}

function inputhandlers.onKeyPressed(key)
    if popup.shouldShow then
        popup.onKeyPressed(key)
    else
        gameState.onKeyPressed(key)
    end
end

function inputhandlers.onMousePressed(button, heldButtons)
    if popup.shouldShow then
        popup.onMousePressed(button)
    else
        board.onMousePressed(button)
    end
end

function inputhandlers.onMouseReleased(button, heldButtons)
    local submenuOpen = game_menu.anySubmenuOpen()
    local menuHandled = game_menu.onMouseReleased(button)

    if menuHandled == true or menuHandled == "closed" or submenuOpen then return end

    if popup.shouldShow then
        popup.onMouseReleased(button)
    else
        board.onMouseReleased(button, heldButtons)
    end
end

function inputhandlers.textinput(t)
    if popup.shouldShow then
        popup.textinput(t)
    end
end

return inputhandlers
