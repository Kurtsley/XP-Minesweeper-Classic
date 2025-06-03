-- game_menu.lua
-- Old fashioned game menu, game and help

local gameplay = require("src.gameplay")
local state = require("src.state")
local config = require("src.config")
local popup = require("src.popup")
local gameState = state.gameState

local game_menu = {}

local gameX, gameY, gameW
local helpX, helpY, helpW
local gamesubX, gamesubY, gamesubW, gamesubH
local helpsubX, helpsubY, helpsubW, helpsubH
local normalBoxColor, highlightBoxColor, textColor
local subItemNormalColor
local sepColor
local font
local items = {}
local gameSubItems = {}
local helpSubItems = {}

game_menu.helpSubMenuOpen = false
game_menu.gameSubMenuOpen = false

function game_menu.withinItem(itemX, itemY, itemW, itemH)
    local mx, my = love.mouse.getPosition()

    if mx > itemX and mx <= itemX + itemW and my > itemY and my <= itemY + itemH then
        return true
    end

    return false
end

function game_menu.onMouseReleased(button)
    if popup.shouldShow then return end

    if button == 1 then
        if game_menu.gameSubMenuOpen then
            for _, subitem in ipairs(gameSubItems) do
                if game_menu.withinItem(subitem.x, subitem.y, subitem.w, subitem.h) then
                    if subitem.onClick then
                        if subitem.key then
                            subitem.onClick(subitem.key)
                        else
                            subitem.onClick()
                        end
                    end
                    return true
                end
            end

            game_menu.submenuClose("Game")
            return "closed"
        end

        if game_menu.helpSubMenuOpen then
            for _, subitem in ipairs(helpSubItems) do
                if game_menu.withinItem(subitem.x, subitem.y, subitem.w, subitem.h) then
                    if subitem.onClick then
                        subitem.onClick()
                    end
                    return true
                end
            end

            game_menu.submenuClose("Help")
            return "closed"
        end

        for _, item in ipairs(items) do
            if game_menu.withinItem(item.x, item.y, item.w, item.h) then
                if item.onClick then
                    item.onClick(item.label)
                    return true
                end
            end
        end
    end

    return false
end

function game_menu.newGame()
    game_menu.gameSubMenuOpen = false
    gameState.changeState(gameState.NEW_GAME)
end

function game_menu.startNewGame(diff)
    game_menu.gameSubMenuOpen = false
    gameplay.startNewGame(diff)
end

function game_menu.quit()
    gameState.quit()
end

function game_menu.load()
    -- Main
    gameX, gameY, gameW = 2, 0, 40
    helpX, helpY, helpW = 42, 0, 40
    -- Game submenu
    gamesubX, gamesubY, gamesubW, gamesubH = 0, MenuHeight, 150, (MenuHeight * 9) + 22
    -- Help submenu
    helpsubX, helpsubY, helpsubW, helpsubH = 42, 24, 150, MenuHeight + 4

    normalBoxColor = { 1, 1, 1 }
    subItemNormalColor = { 249 / 255, 249 / 255, 249 / 255 }
    highlightBoxColor = { 245 / 255, 245 / 255, 245 / 255 }
    textColor = { 0, 0, 0 }
    sepColor = { 192 / 255, 192 / 255, 192 / 255 }

    font = love.graphics.newFont(12)

    items = {
        {
            label = "Game",
            x = gameX,
            y = gameY,
            w = gameW,
            h = MenuHeight,
            labelYOffset = 5,
            normalColor = normalBoxColor,
            hoverColor = highlightBoxColor,
            onClick = function()
                game_menu.toggleSubmenu("Game")
            end
        },
        {
            label = "Help",
            x = helpX,
            y = helpY,
            w = helpW,
            h = MenuHeight,
            labelYOffset = 5,
            normalColor = normalBoxColor,
            hoverColor = highlightBoxColor,
            onClick = function()
                game_menu.toggleSubmenu("Help")
            end
        },
    }

    helpSubItems = {
        {
            label = "About",
            x = helpsubX,
            y = helpsubY + 2,
            w = helpsubW,
            h = helpsubH - 2,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.toggleAboutMenu
        }
    }

    gameSubItems = {
        {
            label = "New",
            x = gamesubX,
            y = MenuHeight + 2,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.newGame
        },
        {
            -- Sep
            x = gamesubX + 5,
            y = (MenuHeight * 2) + 4,
            w = gamesubW - 5,
            h = 5,
            xOffset = 5,
            color = sepColor,
            sep = true
        },
        {
            label = "Beginner",
            key = "easy",
            x = gamesubX,
            y = (MenuHeight * 2) + 11,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = game_menu.checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = "Intermediate",
            key = "medium",
            x = gamesubX,
            y = (MenuHeight * 3) + 13,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = game_menu.checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = "Expert",
            key = "hard",
            x = gamesubX,
            y = (MenuHeight * 4) + 15,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = game_menu.checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = "Custom...",
            key = "custom",
            x = gamesubX,
            y = (MenuHeight * 5) + 17,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = game_menu.checkMarkCheck,
            onClick = game_menu.openCustomPopup
        },
        {
            -- Sep
            x = gamesubX + 5,
            y = (MenuHeight * 6) + 19,
            w = gamesubW - 5,
            h = 5,
            xOffset = 5,
            color = sepColor,
            sep = true
        },
        {
            label = "Marks",
            x = gamesubX,
            y = (MenuHeight * 7) + 2,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = game_menu.checkMarkCheck,
            onClick = game_menu.toggleQMarks
        },
        {
            -- Sep
            x = gamesubX + 5,
            y = (MenuHeight * 8) + 4,
            w = gamesubW - 5,
            h = 5,
            xOffset = 5,
            color = sepColor,
            sep = true
        },
        {
            label = "Best Times...",
            x = gamesubX,
            y = (MenuHeight * 8) + 11,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.openBestTimes
        },
        {
            -- Sep
            x = gamesubX + 5,
            y = (MenuHeight * 9) + 13,
            w = gamesubW - 5,
            h = 5,
            xOffset = 5,
            color = sepColor,
            sep = true
        },
        {
            label = "Exit",
            x = gamesubX,
            y = (MenuHeight * 9) + 20,
            w = gamesubW,
            h = MenuHeight,
            labelXOffset = 40,
            labelYOffset = 5,
            cornerRadius = 8,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.quit
        },
    }
end

function game_menu.checkMarkCheck(subitem)
    if subitem.key then
        return subitem.key == gameState.getDifficulty()
    end

    return config.qMarks
end

function game_menu.toggleAboutMenu()
    game_menu.toggleSubmenu("Help")
    popup.setup("About")
    popup.show("About")
end

function game_menu.openBestTimes()
    game_menu.submenuClose("Game")
    popup.setup("Best")
    popup.show("Best")
end

function game_menu.openCustomPopup()
    game_menu.toggleSubmenu("Game")
    popup.setup("Custom")
    popup.show("Custom")
end

function game_menu.toggleQMarks()
    config.toggleQMarks()
    game_menu.submenuClose("Game")
end

function game_menu.toggleSubmenu(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = not game_menu.gameSubMenuOpen
        game_menu.helpSubMenuOpen = false
    else
        game_menu.helpSubMenuOpen = not game_menu.helpSubMenuOpen
        game_menu.gameSubMenuOpen = false
    end
end

function game_menu.submenuOpen(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = true
    else
        game_menu.helpSubMenuOpen = true
    end
end

function game_menu.submenuClose(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = false
    else
        game_menu.helpSubMenuOpen = false
    end
end

function game_menu.drawSubMenu(menu)
    if menu == "Game" then
        -- Game submenu
        love.graphics.setColor(subItemNormalColor)
        love.graphics.rectangle("fill", gamesubX, gamesubY, gamesubW, gamesubH)

        for _, subitem in ipairs(gameSubItems) do
            local hovered = game_menu.withinItem(subitem.x, subitem.y, subitem.w, subitem.h)
            local color = hovered and subitem.hoverColor or subitem.normalColor
            -- Sep
            if subitem.sep then
                love.graphics.setColor(subitem.color)
                love.graphics.line(subitem.x, subitem.y + 3, subitem.w, subitem.y + 3)
            else
                -- Box
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", subitem.x, subitem.y, subitem.w, subitem.h, subitem.cornerRadius,
                    subitem.cornerRadius)
                -- Text
                love.graphics.setFont(font)
                love.graphics.setColor(textColor)
                love.graphics.printf(subitem.label, subitem.x + subitem.labelXOffset,
                    subitem.y + subitem.labelYOffset, subitem.w, "left")
                -- Check mark
                if subitem.check and subitem.check(subitem) then
                    love.graphics.line(subitem.x + 15, subitem.y + 12, subitem.x + 20, subitem.y + 17)
                    love.graphics.line(subitem.x + 20, subitem.y + 17, subitem.x + 28, subitem.y + 8)
                end
            end
        end
    else
        -- Help submenu
        love.graphics.setColor(subItemNormalColor)
        love.graphics.rectangle("fill", helpsubX, helpsubY, helpsubW, helpsubH)

        for _, subitem in ipairs(helpSubItems) do
            local hovered = game_menu.withinItem(subitem.x, subitem.y, subitem.w, subitem.h)
            local color = hovered and subitem.hoverColor or subitem.normalColor
            -- Box
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", subitem.x, subitem.y, subitem.w, subitem.h, subitem.cornerRadius,
                subitem.cornerRadius)
            -- Text
            love.graphics.setFont(font)
            love.graphics.setColor(textColor)
            love.graphics.printf(subitem.label, subitem.x + subitem.labelXOffset,
                subitem.y + subitem.labelYOffset, subitem.w, "left")
        end
    end
end

function game_menu.draw()
    -- Main menu
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, GameWidth, MenuHeight)

    -- Menu sep line
    love.graphics.setColor(highlightBoxColor)
    love.graphics.line(0, MenuHeight + 1, GameWidth, MenuHeight + 1)

    for _, item in ipairs(items) do
        local hovered = game_menu.withinItem(item.x, item.y, item.w, item.h)
        local color = hovered and item.hoverColor or item.normalColor
        -- Box
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
        --Text
        love.graphics.setFont(font)
        love.graphics.setColor(textColor)
        love.graphics.printf(item.label, item.x, item.y + item.labelYOffset, item.w, "center")
    end
    if game_menu.gameSubMenuOpen then
        game_menu.drawSubMenu("Game")
    end
    if game_menu.helpSubMenuOpen then
        game_menu.drawSubMenu("Help")
    end
    love.graphics.setColor(1, 1, 1)
end

function game_menu.update()
end

return game_menu
