-- MIT License, Copyright (c) 2025 Kurtsley

-- Main.lua

local init = require("src.init")
init.loadAllModules()

local counterTimer = require("src.counter_timer")
local state = require("src.state")
local gameplay = require("src.gameplay")
local faceButton = require("src.face")
local board = require("src.board")
local input = require("src.input")
local inputHandlers = require("src.inputhandlers")
local game_menu = require("src.game_menu")
local popup = require("src.popup")
local file_manager = require("src.file_manager")
local sound = require("src.sound")
local windowing = require("src.windowing")

local gameState = state.gameState
local timer = state.timer

--[[ Globals ]] --
MenuHeight = 24
Face_x = 0
Face_y = 26 + MenuHeight
EasyRows = 9
EasyCols = 9
EasyMines = 10
MedRows = 16
MedCols = 16
MedMines = 40
HardRows = 16
HardCols = 30
HardMines = 99
Board_start_x = 16
Board_start_y = 80 + MenuHeight
GameWidth = 0
GameHeight = 0
TileSize = 16
InitGame = false
CheatMineHover = false
Current_lang = "en"
------------------

function love.keypressed(key)
    input.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    input.mousepressed(button)
end

function love.mousereleased(x, y, button, istouch, presses)
    input.mousereleased(button)
end

function love.textinput(t)
    input.textinput(t)
end

local states = {
    [gameState.NEW_GAME] = gameplay.newGame,
    [gameState.PLAYING] = gameplay.playGame,
    [gameState.GAME_OVER] = gameplay.gameOver,
    [gameState.VICTORY] = gameplay.victory,
}

function love.load()
    math.randomseed(os.time())
    GameWidth, GameHeight = love.graphics.getDimensions()

    if love.system.getOS() == "Windows" or love.system.getOS() == "Linux" then
        local ok, icon = pcall(love.image.newImageData, "assets/icons/iconsmall.png")
        if ok and icon then
            love.window.setIcon(icon)
        end
    end

    sound.load()
    game_menu.load()
    popup.load()
    file_manager.init()
    gameplay.initGame(gameState.getDifficulty())
    windowing.centerWindow()

    input.registerKeyPress(inputHandlers.onKeyPressed)
    input.registerMousePress(inputHandlers.onMousePressed)
    input.registerMouseRelease(inputHandlers.onMouseReleased)
    input.registerTextInput(inputHandlers.textinput)
end

function love.update(dt)
    states[gameState.get()]()
    timer:update(dt)
    faceButton:update()
    board.update()
    popup.update(dt)
end

function love.draw()
    love.graphics.push()
    -- Drawing this color to cover up shifting tiles
    love.graphics.clear(192 / 255, 192 / 255, 192 / 255)
    board.draw()
    counterTimer.draw(gameState.getMineCount(), timer:getTime())
    faceButton:draw()
    game_menu.draw()
    popup.drawNew()

    love.graphics.pop()
end
