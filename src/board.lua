-- board.lua
-- Handle board logic and creation

local tilesets = require("src.tilesets")
local state = require("src.state")
local gameState = state.gameState
local difficulty = state.difficulty
local faceButton = require("src.face")
local config = require("src.config")
local level_builder = require("src.level_builder")
local sound = require("src.sound")

local board = {}

function board.initBoard()
    local Tile = require("src.tile")

    board.grid = {}

    local rows = 0
    local cols = 0

    if gameState.isDifficulty(difficulty.EASY) then
        rows = EasyRows
        cols = EasyCols
    elseif gameState.isDifficulty(difficulty.MEDIUM) then
        rows = MedRows
        cols = MedCols
    elseif gameState.isDifficulty(difficulty.HARD) then
        rows = HardRows
        cols = HardCols
    elseif gameState.isDifficulty(difficulty.CUSTOM) then
        rows = config.gridHeight
        cols = config.gridWidth
    end

    for r = 1, rows do
        board.grid[r] = {}
        for c = 1, cols do
            board.grid[r][c] = Tile.createTile(false, 0, r, c)
        end
    end
end

function board.getAdjacentTiles(row, col)
    local adjacentTiles = {}

    local dirs = {
        { -1, 1 },
        { -1, 0 },
        { -1, -1 },
        { 0,  -1 },
        { 1,  -1 },
        { 1,  0 },
        { 1,  1 },
        { 0,  1 },
    }

    for _, dir in ipairs(dirs) do
        local dx, dy = dir[1], dir[2]
        local nx, ny = col + dx, row + dy

        if ny >= 1 and ny <= #board.grid and nx >= 1 and nx <= #board.grid[ny] then
            table.insert(adjacentTiles, board.grid[ny][nx])
        end
    end

    return adjacentTiles
end

function board.adjacentMinesLookup(count)
    if count == 1 then
        return tilesets.cell.quads.cell_1
    elseif count == 2 then
        return tilesets.cell.quads.cell_2
    elseif count == 3 then
        return tilesets.cell.quads.cell_3
    elseif count == 4 then
        return tilesets.cell.quads.cell_4
    elseif count == 5 then
        return tilesets.cell.quads.cell_5
    elseif count == 6 then
        return tilesets.cell.quads.cell_6
    elseif count == 7 then
        return tilesets.cell.quads.cell_7
    elseif count == 8 then
        return tilesets.cell.quads.cell_8
    else
        return tilesets.cell.quads.blank
    end
end

function board.countAdjacentMines(row, col)
    local mineCount = 0

    local adjacentTiles = board.getAdjacentTiles(row, col)

    for _, tile in ipairs(adjacentTiles) do
        if tile.isMine then
            mineCount = mineCount + 1
        end
    end

    return mineCount
end

function board.isInSafeZone(row, col, safeRow, safeCol)
    return math.abs(row - safeRow) <= 1 and math.abs(col - safeCol) <= 1
end

function board.addMinesExcluding(safeRow, safeCol)
    local rows = 0
    local cols = 0
    local minesToStart = 0

    rows = config.gridHeight
    cols = config.gridWidth
    minesToStart = config.gridMines

    while minesToStart ~= 0 do
        local row = math.random(1, rows)
        local col = math.random(1, cols)

        if not board.grid[row][col].isMine and
            not board.isInSafeZone(row, col, safeRow, safeCol) then
            board.grid[row][col].isMine = true
            minesToStart = minesToStart - 1
        end
    end

    for r = 1, rows do
        for c = 1, cols do
            local tile = board.grid[r][c]
            local x = Board_start_x + (c - 1) * tilesets.cell.size
            local y = Board_start_y + (r - 1) * tilesets.cell.size
            local col = math.floor((x - Board_start_x) / tilesets.cell.size) + 1
            local row = math.floor((y - Board_start_y) / tilesets.cell.size) + 1
            local adjacentMines = board.countAdjacentMines(row, col)
            if adjacentMines > 0 then
                tile.adjacentMines = adjacentMines
            else
                tile.isBlank = true
            end
        end
    end
end

function board.gridInteraction()
    local game_menu = require("src.game_menu")
    local popup = require("src.popup")

    if (game_menu.gameSubMenuOpen or game_menu.helpSubMenuOpen or game_menu.optionsSubMenuOpen or
            gameState.is(gameState.GAME_OVER) or popup.shouldShow) then
        return
    end

    local mouseX, mouseY = love.mouse.getPosition()

    -- Clear all held tiles for multi-hold
    for r = 1, #board.grid do
        for c = 1, #board.grid[r] do
            local tile = board.grid[r][c]
            tile.isHeld = false
        end
    end

    for r = 1, #board.grid do
        for c = 1, #board.grid[r] do
            local tile = board.grid[r][c]
            local adjacentTiles = board.getAdjacentTiles(r, c)

            local tileX = Board_start_x + (c - 1) * tilesets.cell.size
            local tileY = Board_start_y + (r - 1) * tilesets.cell.size
            local tileWidth = tilesets.cell.size
            local tileHeight = tilesets.cell.size

            if mouseX > tileX and mouseX <= tileX + tileWidth and
                mouseY > tileY and mouseY <= tileY + tileHeight then
                if (love.mouse.isDown(1) and love.mouse.isDown(2)) or love.mouse.isDown(3) then
                    for _, tile in ipairs(adjacentTiles) do
                        if not tile.isFlagged then
                            tile.isHeld = true
                        end
                    end
                end
                if (love.mouse.isDown(1) or love.mouse.isDown(3)) and not tile.isFlagged then
                    tile.isHeld = true
                else
                    tile.isHeld = false
                end
            end
        end
    end
end

function board.checkVictory()
    for r = 1, #board.grid do
        for c = 1, #board.grid[r] do
            local tile = board.grid[r][c]
            if not tile.isMine and tile.isCovered then
                return false
            end
        end
    end

    return true
end

function board.onMousePressed(button)
    local game_menu = require("src.game_menu")
    local popup = require("src.popup")

    if gameState.is(gameState.GAME_OVER) or gameState.is(gameState.VICTORY) or game_menu.gameSubMenuOpen or popup.shouldShow then
        return
    end

    local mouseX, mouseY = love.mouse.getPosition()

    local col = math.floor((mouseX - Board_start_x) / tilesets.cell.size) + 1
    local row = math.floor((mouseY - Board_start_y) / tilesets.cell.size) + 1

    if row >= 1 and row <= #board.grid and col >= 1 and col <= #board.grid[1] then
        local tile = board.grid[row][col]

        if tile then
            if tile.isCovered then
                if button == 2 then
                    if config.qMarks then
                        if tile.isFlagged then
                            tile.isFlagged = false
                            tile.isQuestion = true
                            gameState.incrementMinecount()
                        elseif tile.isQuestion then
                            tile.isQuestion = false
                        else
                            tile.isFlagged = true
                            gameState.decrementMinecount()
                        end
                    else
                        if tile.isFlagged then
                            tile.isFlagged = false
                            gameState.incrementMinecount()
                        else
                            tile.isFlagged = true
                            gameState.decrementMinecount()
                        end
                        tile.isQuestion = false
                    end
                end
            end
        end
    end
end

function board.onMouseReleased(button, heldButtons)
    local Tile = require("src.tile")

    local mouseX, mouseY = love.mouse.getPosition()

    if button == 1 then
        if mouseX >= Face_x and mouseX <= Face_x + faceButton.size and
            mouseY >= Face_y and mouseY <= Face_y + faceButton.size then
            gameState.changeState(gameState.NEW_GAME)
        end
    end

    if gameState.is(gameState.GAME_OVER) or gameState.is(gameState.VICTORY) then
        return
    end

    local col = math.floor((mouseX - Board_start_x) / tilesets.cell.size) + 1
    local row = math.floor((mouseY - Board_start_y) / tilesets.cell.size) + 1

    if row >= 1 and row <= #board.grid and col >= 1 and col <= #board.grid[1] then
        local tile = board.grid[row][col]
        local adjacentTiles = board.getAdjacentTiles(row, col)

        if tile then
            if not tile.isCovered and tile.adjacentMines > 0 then
                if (button == 1 and heldButtons[2]) or (button == 2 and heldButtons[1]) or button == 3 then
                    local flaggedTiles = 0
                    for _, adTile in ipairs(adjacentTiles) do
                        if adTile.isFlagged then
                            flaggedTiles = flaggedTiles + 1
                        end
                    end

                    if tile.adjacentMines == flaggedTiles then
                        for _, adTile in ipairs(adjacentTiles) do
                            if not adTile.isFlagged then
                                Tile.revealTile(adTile.row, adTile.col)
                                sound.play("pop")
                            end
                        end
                    end
                end
            elseif tile.isCovered and not tile.isFlagged then
                if button == 1 and not heldButtons[2] then
                    if gameState.is(gameState.NEW_GAME) then
                        board.addMinesExcluding(row, col)
                        gameState.changeState(gameState.PLAYING)
                    end
                    Tile.revealTile(row, col)
                    sound.play("pop")
                end
            end
        end
    end
end

function board.drawBoard()
    local Tile = require("src.tile")

    local rows = 0
    local cols = 0

    rows = config.gridHeight
    cols = config.gridWidth

    level_builder.drawMap(rows, cols)

    for r = 1, rows do
        for c = 1, cols do
            local x = Board_start_x + (c - 1) * tilesets.cell.size
            local y = Board_start_y + (r - 1) * tilesets.cell.size
            Tile.drawTile(board.grid[r][c], x, y)
        end
    end
end

return board
