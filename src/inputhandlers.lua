-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- inputhandlers.lua
-- Handles the input callbacks

local board = require("src.board")
local state = require("src.state")
local gameState = state.gameState
local game_menu = require("src.game_menu")
local popup = require("src.popup")
local faceButton = require("src.face")
local helper = require("src.helper")

local inputhandlers = {}

function inputhandlers.onKeyPressed(key)
    local submenuOpen = game_menu.anySubmenuOpen()

    if popup.shouldShow then
        popup.onKeyPressed(key)
        return
    else
        game_menu.onKeyPressed(key)
    end

    if submenuOpen and gameState.isAltPressed() then
        game_menu.closeAllSubmenus()
        return
    end

    gameState.onKeyPressed(key)
end

function inputhandlers.onMousePressed(button, heldButtons)
    if popup.shouldShow then
        popup.onMousePressed(button)
    else
        if button == 1 and not game_menu.anySubmenuOpen() then
            local mouseX, mouseY = helper.getMousePosition()
            faceButton.armed = faceButton.isOver(mouseX, mouseY)
        end
        board.onMousePressed(button, heldButtons)
    end
end

function inputhandlers.onMouseReleased(button, heldButtons)
    local submenuOpen = game_menu.anySubmenuOpen()
    local menuHandled = game_menu.onMouseReleased(button)

    if not (menuHandled == true or menuHandled == "closed" or submenuOpen) then
        if popup.shouldShow then
            popup.onMouseReleased(button)
        else
            board.onMouseReleased(button, heldButtons)
        end
    end

    if button == 1 then
        faceButton.armed = false
    end
end

function inputhandlers.textinput(t)
    if popup.shouldShow then
        popup.textinput(t)
    end
end

return inputhandlers
