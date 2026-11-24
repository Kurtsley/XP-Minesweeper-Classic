-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- face.lua
-- Handles face button logic, state, and drawing

local tilesets = require("src.tilesets")
local popup = require("src.popup")
local config = require("src.config")
local helper = require("src.helper")
local state = require("src.state")
local gameState = state.gameState

local faceButton = {
    state = "normal",
    pressed = false,
    armed = false,
    x = Face_x,
    y = Face_y,
    size = 28
}

function faceButton:setState(newState)
    self.state = newState
end

function faceButton:setPressed(value)
    self.pressed = value
end

function faceButton.isOver(x, y)
    return x >= Face_x and x < Face_x + faceButton.size and
        y >= Face_y and y < Face_y + faceButton.size
end

function faceButton:update()
    local game_menu = require("src.game_menu")

    if gameState.is(gameState.GAME_OVER) then
        faceButton:setState("dead")
    elseif gameState.is(gameState.VICTORY) then
        faceButton:setState("glasses")
    else
        faceButton:setState("normal")
    end

    if popup.shouldShow then
        self.pressed = false
        return
    end

    local mouseX, mouseY = helper.getMousePosition()

    if faceButton.isOver(mouseX, mouseY) then
        self.pressed = self.armed and love.mouse.isDown(1) or false
    elseif self.armed then
        self.pressed = false
    else
        self.pressed = false

        local rows = config.gridHeight
        local cols = config.gridWidth

        if not (gameState.is(gameState.GAME_OVER) or gameState.is(gameState.VICTORY) or game_menu.anySubmenuOpen()) then
            if mouseX >= Board_start_x and mouseX < Board_start_x + cols * tilesets.cell.size and
                mouseY >= Board_start_y and mouseY < Board_start_y + rows * tilesets.cell.size then
                if love.mouse.isDown(1) then
                    faceButton:setState("surprise")
                end
            end
        end
    end
end

function faceButton:draw()
    if self.pressed then
        love.graphics.draw(tilesets.face.image, tilesets.face.quads.pressed, Face_x, Face_y)
    elseif self.state == "surprise" then
        love.graphics.draw(tilesets.face.image, tilesets.face.quads.surprise, Face_x, Face_y)
    elseif self.state == "glasses" then
        love.graphics.draw(tilesets.face.image, tilesets.face.quads.glasses, Face_x, Face_y)
    elseif self.state == "dead" then
        love.graphics.draw(tilesets.face.image, tilesets.face.quads.dead, Face_x, Face_y)
    else
        love.graphics.draw(tilesets.face.image, tilesets.face.quads.normal, Face_x, Face_y)
    end
end

return faceButton
