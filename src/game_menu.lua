-- MIT License, Copyright (c) 2025 Kurtsley

-- game_menu.lua
-- Old fashioned game menu, game, options, and help

local gameplay = require("src.gameplay")
local state = require("src.state")
local config = require("src.config")
local popup = require("src.popup")
local strings = require("src.strings")
local file_manager = require("src.file_manager")
local lang = require("src.languages")
local gameState = state.gameState

local game_menu = {}

-- Menu Globals --
local font = love.graphics.newFont(12)
local menuWidth = 150
local menuHeight = 24
local menuYOffset = 5
local subMenuXOffset = 40
local cornerRadius = 8
local sepX = 7
local sepW = menuWidth - 5
local sepH = 5
local sepXOffset = 5
local normalBoxColor = { 1, 1, 1 }
local subItemNormalColor = { 249 / 255, 249 / 255, 249 / 255 }
local highlightBoxColor = { 245 / 255, 245 / 255, 245 / 255 }
local textColor = { 0, 0, 0 }
local sepColor = { 192 / 255, 192 / 255, 192 / 255 }
local cheatColorMine = { 0, 0, 0 }
local cheatColorSafe = { 1, 1, 1 }
-- End Globals --

local items = {}
local gameSubItems = {}
local helpSubItems = {}
local optionsSubItems = {}

local menuItems = {
    game = { x = 0, y = 0, w = 50, yOffset = 5 },
    options = { x = 50, y = 0, w = 64 },
    help = { x = 114, y = 0, w = 44 },
}

local subItems = {
    game = { x = 0, h = 205 },
    options = { x = 50, h = 54 },
    help = { x = 104, h = 28 },
}

local gameYValues = {
    y1 = 26,
    y2 = (menuHeight * 2) + 4,
    y3 = (menuHeight * 2) + 11,
    y4 = (menuHeight * 3) + 13,
    y5 = (menuHeight * 4) + 15,
    y6 = (menuHeight * 5) + 17,
    y7 = (menuHeight * 6) + 19,
    y8 = (menuHeight * 7) + 2,
    y9 = (menuHeight * 8) + 4,
    y10 = (menuHeight * 8) + 11,

}

local optionsYValues = {
    y1 = 26,
    y2 = (menuHeight * 2) + 4,
}

local helpYValues = {
    y1 = 26,
}

game_menu.helpSubMenuOpen = false
game_menu.gameSubMenuOpen = false
game_menu.optionsSubMenuOpen = false

local function toggleQMarks()
    config.toggleQMarks()
    game_menu.submenuClose("Options")
end

local function toggleSound()
    config.toggleSound()
    game_menu.submenuClose("Options")
end

local function checkMarkCheck(subitem)
    if subitem.key then
        return subitem.key == gameState.getDifficulty()
    end

    if subitem.label == "&Marks (?)" then
        return config.qMarks
    elseif subitem.label == "&Sound" then
        return config.sound
    end
end

local function withinItem(itemX, itemY, itemW, itemH)
    local mx, my = love.mouse.getPosition()

    if mx > itemX and mx <= itemX + itemW and my > itemY and my <= itemY + itemH then
        return true
    end

    return false
end

local function menuPosX(xPos, width)
    if xPos + width > GameWidth then
        return GameWidth - width
    else
        return xPos
    end
end

function game_menu.onKeyPressed(key)
    local alt = gameState.isAltPressed()
    local menuOpen = game_menu.anySubmenuOpen()

    if alt then
        if menuOpen then
            if key == "n" then
                game_menu.newGame()
                gameState.resetAlt()
            elseif key == "b" then
                game_menu.startNewGame("easy")
                gameState.resetAlt()
            elseif key == "i" then
                game_menu.startNewGame("medium")
                gameState.resetAlt()
            elseif key == "e" then
                game_menu.startNewGame("hard")
                gameState.resetAlt()
            elseif key == "m" then
                toggleQMarks()
                gameState.resetAlt()
            elseif key == "s" then
                toggleSound()
                gameState.resetAlt()
            elseif key == "t" then
                game_menu.openBestTimes()
                gameState.resetAlt()
            elseif key == "c" then
                game_menu.openCustomPopup()
                gameState.resetAlt()
            elseif key == "a" then
                game_menu.openAboutPopup()
                gameState.resetAlt()
            elseif key == "x" then
                game_menu.quit()
            end
        else
            if key == "g" then
                game_menu.openSubmenu("Game")
            elseif key == "o" then
                game_menu.openSubmenu("Options")
            elseif key == "h" then
                game_menu.openSubmenu("Help")
            else
                --gameState.resetAlt()
            end
        end
    end
end

function game_menu.onMouseReleased(button)
    if popup.shouldShow then return end

    if button ~= 1 then return false end

    if button == 1 then
        for _, item in ipairs(items) do
            if withinItem(item.x, item.y, item.w, item.h) then
                if item.onClick then
                    item.onClick(item.label)
                    return true
                end
            end
        end

        local function checkSubMenu(subItems, closeKey)
            for _, subitem in ipairs(subItems) do
                if withinItem(subitem.x, subitem.y, subitem.w, subitem.h) then
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
            game_menu.submenuClose(closeKey)
        end

        if game_menu.gameSubMenuOpen then
            if checkSubMenu(gameSubItems, "Game") then return true end
        end

        if game_menu.helpSubMenuOpen then
            if checkSubMenu(helpSubItems, "Help") then return true end
        end

        if game_menu.optionsSubMenuOpen then
            if checkSubMenu(optionsSubItems, "Options") then return true end
        end
    end

    return false
end

function game_menu.anySubmenuOpen()
    return game_menu.gameSubMenuOpen or game_menu.optionsSubMenuOpen or game_menu.helpSubMenuOpen
end

function game_menu.closeAllSubmenus()
    game_menu.submenuClose("Game")
    game_menu.submenuClose("Options")
    game_menu.submenuClose("Help")
end

function game_menu.newGame()
    game_menu.gameSubMenuOpen = false
    gameState.newGame()
end

function game_menu.startNewGame(diff)
    game_menu.gameSubMenuOpen = false
    gameplay.initGame(diff)
end

function game_menu.quit()
    gameState.quit()
end

function game_menu.updateSubmenuXPos()
    subItems.help.x = menuPosX(subItems.help.x, subItems.help.w)
    subItems.options.x = menuPosX(subItems.options.x, subItems.options.w)
end

function game_menu.load()
    local current_lang = "en"

    items = {
        {
            label = lang[current_lang].menu_titles.game,
            x = menuItems.game.x,
            y = menuItems.game.y,
            w = menuItems.game.w,
            h = menuHeight,
            labelYOffset = menuYOffset,
            normalColor = normalBoxColor,
            hoverColor = highlightBoxColor,
            onClick = function()
                game_menu.openSubmenu("Game")
            end
        },
        {
            label = lang[current_lang].menu_titles.options,
            x = menuItems.options.x,
            y = menuItems.options.y,
            w = menuItems.options.w,
            h = menuHeight,
            labelYOffset = menuYOffset,
            normalColor = normalBoxColor,
            hoverColor = highlightBoxColor,
            onClick = function()
                game_menu.openSubmenu("Options")
            end
        },
        {
            label = lang[current_lang].menu_titles.help,
            x = menuItems.help.x,
            y = menuItems.help.y,
            w = menuItems.help.w,
            h = menuHeight,
            labelYOffset = menuYOffset,
            normalColor = normalBoxColor,
            hoverColor = highlightBoxColor,
            onClick = function()
                game_menu.openSubmenu("Help")
            end
        },
    }

    helpSubItems = {
        {
            label = lang[current_lang].help_menu.about,
            x = subItems.help.x,
            y = helpYValues.y1,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.openAboutPopup
        }
    }

    optionsSubItems = {
        {
            label = lang[current_lang].options_menu.marks,
            x = subItems.options.x,
            y = optionsYValues.y1,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = toggleQMarks
        },
        {
            label = lang[current_lang].options_menu.sound,
            x = subItems.options.x,
            y = optionsYValues.y2,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = toggleSound
        }
    }

    gameSubItems = {
        {
            label = lang[current_lang].game_menu.new,
            x = subItems.game.x,
            y = gameYValues.y1,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.newGame
        },
        {
            -- Sep
            x = sepX,
            y = gameYValues.y2,
            w = sepW,
            h = sepH,
            xOffset = sepXOffset,
            color = sepColor,
            sep = true
        },
        {
            label = lang[current_lang].game_menu.beginner,
            key = "easy",
            x = subItems.game.x,
            y = gameYValues.y3,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = lang[current_lang].game_menu.intermediate,
            key = "medium",
            x = subItems.game.x,
            y = gameYValues.y4,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = lang[current_lang].game_menu.expert,
            key = "hard",
            x = subItems.game.x,
            y = gameYValues.y5,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = game_menu.startNewGame
        },
        {
            label = lang[current_lang].game_menu.custom,
            key = "custom",
            x = subItems.game.x,
            y = gameYValues.y6,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            check = checkMarkCheck,
            onClick = game_menu.openCustomPopup
        },
        {
            -- Sep
            x = sepX,
            y = gameYValues.y7,
            w = sepW,
            h = sepH,
            xOffset = sepXOffset,
            color = sepColor,
            sep = true
        },
        {
            label = lang[current_lang].game_menu.best_times,
            x = subItems.game.x,
            y = gameYValues.y8,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.openBestTimes
        },
        {
            -- Sep
            x = sepX,
            y = gameYValues.y9,
            w = sepW,
            h = sepH,
            xOffset = sepXOffset,
            color = sepColor,
            sep = true
        },
        {
            label = lang[current_lang].game_menu.exit,
            x = subItems.game.x,
            y = gameYValues.y10,
            w = menuWidth,
            h = menuHeight,
            labelXOffset = subMenuXOffset,
            labelYOffset = menuYOffset,
            cornerRadius = cornerRadius,
            normalColor = subItemNormalColor,
            hoverColor = highlightBoxColor,
            onClick = game_menu.quit
        },
    }
end

function game_menu.openAboutPopup()
    game_menu.openSubmenu("Help")
    popup.setup("About")
    popup.show("About")
end

function game_menu.openBestTimes()
    if file_manager.systemWritable then
        game_menu.submenuClose("Game")
        popup.setup("Best")
        popup.show("Best")
    else
        game_menu.submenuClose("Game")
        popup.setup("SaveError")
        popup.show("SaveError")
    end
end

function game_menu.openCustomPopup()
    game_menu.openSubmenu("Game")
    popup.setup("Custom")
    popup.show("Custom")
end

function game_menu.openSubmenu(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = not game_menu.gameSubMenuOpen
        game_menu.helpSubMenuOpen = false
        game_menu.optionsSubMenuOpen = false
    elseif menu == "Options" then
        game_menu.optionsSubMenuOpen = not game_menu.optionsSubMenuOpen
        game_menu.gameSubMenuOpen = false
        game_menu.helpSubMenuOpen = false
    elseif menu == "Help" then
        game_menu.helpSubMenuOpen = not game_menu.helpSubMenuOpen
        game_menu.gameSubMenuOpen = false
        game_menu.optionsSubMenuOpen = false
    end
end

function game_menu.submenuOpen(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = true
    elseif menu == "Options" then
        game_menu.optionsSubMenuOpen = true
    elseif menu == "Help" then
        game_menu.helpSubMenuOpen = true
    end
end

function game_menu.submenuClose(menu)
    if menu == "Game" then
        game_menu.gameSubMenuOpen = false
    elseif menu == "Options" then
        game_menu.optionsSubMenuOpen = false
    elseif menu == "Help" then
        game_menu.helpSubMenuOpen = false
    end
end

function game_menu.drawSubMenu(menu)
    if menu == "Game" then
        -- Game submenu
        love.graphics.setColor(subItemNormalColor)
        love.graphics.rectangle("fill", subItems.game.x, menuHeight, menuWidth, subItems.game.h)

        for _, subitem in ipairs(gameSubItems) do
            local hovered = withinItem(subitem.x, subitem.y, subitem.w, subitem.h)
            local color = hovered and subitem.hoverColor or subitem.normalColor
            -- Sep
            if subitem.sep then
                love.graphics.setColor(subitem.color)
                love.graphics.line(subitem.x, subitem.y + 3, subitem.w, subitem.y + 3)
            else
                -- Box
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", subitem.x, subitem.y, subitem.w, subitem.h)
                -- Text
                love.graphics.setFont(font)
                love.graphics.setColor(textColor)
                if subitem.label == "&New" then
                    love.graphics.printf("F2", subitem.x - 20, subitem.y + subitem.labelYOffset, subitem.w,
                        "right")
                end
                love.graphics.printf(strings.displayStr(subitem.label), subitem.x + subitem.labelXOffset,
                    subitem.y + subitem.labelYOffset, subitem.w, "left")
                -- Hotkey underline
                if strings.hasHotkey(subitem.label) then
                    strings.drawUnderline(subitem.label, subitem.x + subitem.labelXOffset,
                        subitem.y + subitem.labelYOffset,
                        subitem.w, font, true)
                end
                -- Check mark
                if subitem.check and subitem.check(subitem) then
                    love.graphics.line(subitem.x + 15, subitem.y + 12, subitem.x + 20, subitem.y + 17)
                    love.graphics.line(subitem.x + 20, subitem.y + 17, subitem.x + 28, subitem.y + 8)
                end
            end
        end
        -- Options submenu
    elseif menu == "Options" then
        local xPos = menuPosX(subItems.options.x, menuWidth)

        love.graphics.setColor(subItemNormalColor)
        love.graphics.rectangle("fill", xPos, menuHeight, menuWidth, subItems.options.h)

        for _, subitem in ipairs(optionsSubItems) do
            subitem.x = xPos
            local hovered = withinItem(subitem.x, subitem.y, subitem.w, subitem.h)
            local color = hovered and subitem.hoverColor or subitem.normalColor
            -- Box
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", subitem.x, subitem.y, subitem.w, subitem.h)
            -- Text
            love.graphics.setFont(font)
            love.graphics.setColor(textColor)
            love.graphics.printf(strings.displayStr(subitem.label), subitem.x + subitem.labelXOffset,
                subitem.y + subitem.labelYOffset, subitem.w, "left")
            -- Hotkey underline
            if strings.hasHotkey(subitem.label) then
                strings.drawUnderline(subitem.label, subitem.x + subitem.labelXOffset, subitem.y + subitem.labelYOffset,
                    subitem.w, font, true)
            end
            -- Check mark
            if subitem.check and subitem.check(subitem) then
                love.graphics.line(subitem.x + 15, subitem.y + 12, subitem.x + 20, subitem.y + 17)
                love.graphics.line(subitem.x + 20, subitem.y + 17, subitem.x + 28, subitem.y + 8)
            end
        end
    elseif menu == "Help" then
        -- Help submenu
        local xPos = menuPosX(subItems.help.x, menuWidth)

        love.graphics.setColor(subItemNormalColor)
        love.graphics.rectangle("fill", xPos, menuHeight, menuWidth, subItems.help.h)

        for _, subitem in ipairs(helpSubItems) do
            subitem.x = xPos
            local hovered = withinItem(subitem.x, subitem.y, subitem.w, subitem.h)
            local color = hovered and subitem.hoverColor or subitem.normalColor
            -- Box
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", subitem.x, subitem.y, subitem.w, subitem.h)
            -- Text
            love.graphics.setFont(font)
            love.graphics.setColor(textColor)
            love.graphics.printf(strings.displayStr(subitem.label), subitem.x + subitem.labelXOffset,
                subitem.y + subitem.labelYOffset, subitem.w, "left")
            -- Hotkey underline
            if strings.hasHotkey(subitem.label) then
                strings.drawUnderline(subitem.label, subitem.x + subitem.labelXOffset, subitem.y + subitem.labelYOffset,
                    subitem.w, font, true)
            end
        end
    else
        print("Unkown menu type")
    end
end

function game_menu.draw()
    -- Main menu
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, GameWidth, MenuHeight)

    -- Menu sep line
    love.graphics.setColor(highlightBoxColor)
    love.graphics.line(0, MenuHeight + 1, GameWidth, MenuHeight + 1)

    -- Cheat pixel
    if gameState.isCheating() then
        local cheatColor = CheatMineHover and cheatColorMine or cheatColorSafe
        love.graphics.setColor(cheatColor)
        love.graphics.rectangle("fill", 0, menuHeight, 1, 1)
    end

    for _, item in ipairs(items) do
        local hovered = withinItem(item.x, item.y, item.w, item.h) and not popup.shouldShow
        local color = hovered and item.hoverColor or item.normalColor
        -- Box
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
        -- Text
        love.graphics.setFont(font)
        love.graphics.setColor(textColor)
        love.graphics.printf(strings.displayStr(item.label), item.x, item.y + item.labelYOffset, item.w, "center")
        -- Underline
        if strings.hasHotkey(item.label) then
            strings.drawUnderline(item.label, item.x, item.y + item.labelYOffset, item.w, font)
        end
    end
    if game_menu.gameSubMenuOpen then
        game_menu.drawSubMenu("Game")
    end
    if game_menu.optionsSubMenuOpen then
        game_menu.drawSubMenu("Options")
    end
    if game_menu.helpSubMenuOpen then
        game_menu.drawSubMenu("Help")
    end
    love.graphics.setColor(1, 1, 1)
end

return game_menu
