-- MIT License, Copyright (c) 2025 Kurtsley

-- popup.lua
-- Shows a popup at victory or best times, or even the about page

local file_manager = require("src.file_manager")
local config = require("src.config")
local state = require("src.state")
local strings = require("src.strings")
local lang = require("src.languages")
local gameState = state.gameState
local timer = state.timer

local g = love.graphics

local popupWidth = 164
local popupHeight = 160
local popupTitle
local popupXOffset = 10
local popupYOffset = 5

local popup = {
    shouldShow = false,
    content = {},
}

local buttons = {}
local inputBoxes = {}
local linkButtons = {}

local highlightTimer = 0
local caretVisible = true
local highlightBoxVisible = true

local aboutPopupShown = false
local bestTimesPopupShown = false
local customPopupShown = false
local highScorePopupShown = false
local saveErrorPopupShown = false

local shadowOffset = 6
local questionMarkXOffset = 34

local questionMarkRad = 16
local cornerRad = 6
local buttonXOffset = 12
local buttonW, buttonH = 70, 24
local topBarHeight = 24
local bottomGrayH = 44
local cancelXOffset = 34
local messageTextOffset = 62
local shadowOffset = 6
local buttonW, buttonH = 60, 22

-- Colors
local topBarColor = { 236 / 255, 246 / 255, 249 / 255 }
local backgroundColor = { 240 / 255, 240 / 255, 240 / 255 }
local textColor = { 0, 0, 0 }
local shadowColor = { 0, 0, 0, 0.2 }
local buttonBorderColor = { 220 / 255, 220 / 255, 220 / 255 }
local buttonBorderHoverColor = { 0, 120 / 255, 212 / 255 }
local buttonBackgroundColor = { 253 / 255, 253 / 255, 253 / 255 }
local buttonBackgroundHoverColor = { 224 / 255, 238 / 255, 249 / 255 }
local bottomGray = { 240 / 255, 240 / 255, 240 / 255 }
local cancelRed = { 240 / 255, 56 / 255, 36 / 255 }
local disabledGray = { 150 / 255, 150 / 255, 150 / 255 }
local inputBoxBackground = { 1, 1, 1 }

local smallFont = g.newFont(10)
local medFont = g.newFont(14)
local bigFont = g.newFont(20)

local popupImage
local alt

local function within(btnX, btnY, btnW, btnH)
    local mx, my = love.mouse.getPosition()

    if mx > btnX and mx <= btnX + btnW and my > btnY and my <= btnY + btnH then
        return true
    end

    return false
end

local function clearInputBoxes()
    for _, box in pairs(inputBoxes) do
        box.active = false
    end
end

function popup.onMouseReleased(button)
    if button == 1 then
        if popup.shouldShow then
            for _, btn in ipairs(buttons) do
                if within(btn.x, btn.y, btn.w, btn.h) then
                    if btn.onClick then
                        btn.onClick()
                        break
                    end
                end
            end
            if aboutPopupShown then
                for _, link in ipairs(linkButtons) do
                    if within(link.x, link.y, link.w, link.h) then
                        if link.onClick then
                            if link.link then
                                link.onClick(link.link)
                            end
                        end
                    end
                end
            end
        end
    end
end

function popup.onMousePressed(button)
    if button == 1 then
        if customPopupShown then
            clearInputBoxes()
            for _, box in pairs(inputBoxes) do
                if within(box.x, box.y, box.w, box.h) then
                    box.active = true
                    box.firstClick = true
                    break
                end
            end
        end
    end
end

function popup.onKeyPressed(key)
    if bestTimesPopupShown then
        if key == "r" then
            popup.onClickReset()
        end
    end
    if customPopupShown then
        if key == "lalt" or key == "ralt" then
            alt = not alt
        end
        if alt then
            if key == "h" then
                clearInputBoxes()
                inputBoxes.height.active = true
                inputBoxes.height.firstClick = true
            elseif key == "w" then
                clearInputBoxes()
                inputBoxes.width.active = true
                inputBoxes.width.firstClick = true
            elseif key == "m" then
                clearInputBoxes()
                inputBoxes.mines.active = true
                inputBoxes.mines.firstClick = true
            end
        end
    end
    if popup.inputActive() then
        for _, box in pairs(inputBoxes) do
            if box.active then
                if key == "backspace" then
                    box.text = box.text:sub(1, -2)
                end
            end
        end
        if key == "return" or key == "escape" or key == "kpenter" then
            for _, box in pairs(inputBoxes) do
                box.active = false
            end
        end
    else
        if key == "return" or key == "kpenter" then
            for _, btn in ipairs(buttons) do
                if btn.label == "OK" then
                    if btn.onClick then
                        btn.onClick()
                        break
                    end
                end
            end
        elseif key == "escape" then
            for _, btn in ipairs(buttons) do
                if btn.label == "Cancel" then
                    if btn.onClick then
                        btn.onClick()
                        break
                    end
                end
            end
        end
    end
end

function popup.textinput(t)
    for _, box in pairs(inputBoxes) do
        if box.active and t:match("%d") then
            if box.firstClick then
                box.text = t
                box.firstClick = false
            else
                if #box.text < box.maxDigits then
                    box.text = box.text .. t
                end
            end
        end
    end
end

function popup.load()
    popupImage = g.newImage("assets/images/popupdark.png")
end

function popup.update(dt)
    highlightTimer = highlightTimer + dt
    if highlightTimer >= 0.5 then
        highlightTimer = 0
        caretVisible = not caretVisible
        highlightBoxVisible = not highlightBoxVisible
    end
end

function popup.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function popup.inputActive()
    for _, box in pairs(inputBoxes) do
        if box.active then return true end
    end

    return false
end

function popup.commitCustomInputs()
    local gameplay = require("src.gameplay")
    local width, height, mines

    for _, box in pairs(inputBoxes) do
        local num = tonumber(box.text)
        if box.label == lang[Current_lang].custom_labels.height then
            height = popup.clamp(num or 9, 9, 99)
        elseif box.label == lang[Current_lang].custom_labels.width then
            width = popup.clamp(num or 9, 9, 99)
        elseif box.label == lang[Current_lang].custom_labels.mines then
            mines = num or 10
        end
    end

    local maxMines = (width - 1) * (height - 1)
    mines = popup.clamp(mines, 10, maxMines)

    config.setConfig("gridHeight", height)
    config.setConfig("gridWidth", width)
    config.setConfig("gridMines", mines)

    gameplay.initGame("custom")
end

function popup.show(state)
    bestTimesPopupShown = false
    aboutPopupShown = false
    customPopupShown = false
    highScorePopupShown = false
    saveErrorPopupShown = false

    if state == "About" then
        aboutPopupShown = true
    elseif state == "Best" then
        bestTimesPopupShown = true
    elseif state == "Custom" then
        customPopupShown = true
    elseif state == "HighScore" then
        highScorePopupShown = true
    elseif state == "SaveError" then
        saveErrorPopupShown = true
    end

    popup.shouldShow = true
end

function popup.hide()
    popup.shouldShow = false
end

function popup.onClickReset()
    file_manager.resetScores()
    popup.hide()
end

function popup.onClickOK()
    if highScorePopupShown then
        popup.hide()
        popup.setup("Best")
        popup.show("Best")
        return
    end

    if customPopupShown then
        popup.commitCustomInputs()
    end

    popup.hide()
end

local function clickLink(link)
    love.system.openURL(link)
end

function popup.onClickCancel()
    popup.hide()
end

function popup.setup(state)
    alt = false
    state = state or nil

    local difficulty = gameState.getDifficulty()

    local buttonY = (GameHeight / 2) - (popup.content.h / 2) + popup.content.h - (buttonH + 10)

    local OKCentered = { (GameWidth / 2) - 30, buttonY }
    local OKRight = { (GameWidth / 2) + 6, buttonY }
    local resetPosition = { (GameWidth / 2) - 66, buttonY }
    local cancelPosition = resetPosition

    local OKbtnX, OKbtnY

    if state == "About" or state == "HighScore" or state == "SaveError" then
        OKbtnX, OKbtnY = OKCentered[1], OKCentered[2]
    else
        OKbtnX, OKbtnY = OKRight[1], OKRight[2]
    end

    local resetBtnX, resetBtnY = resetPosition[1], resetPosition[2]
    local cancelBtnX, cancelBtnY = cancelPosition[1], cancelPosition[2]

    buttons = {
        {
            label = lang[Current_lang].buttons.ok,
            x = OKbtnX,
            y = OKbtnY,
            w = buttonW,
            h = buttonH,
            cornerRadius = 4,
            onClick = popup.onClickOK
        },
        {
            label = lang[Current_lang].buttons.reset,
            x = resetBtnX,
            y = resetBtnY,
            w = buttonW,
            h = buttonH,
            cornerRadius = 4,
            onClick = popup.onClickReset
        },
        {
            label = lang[Current_lang].buttons.cancel,
            x = cancelBtnX,
            y = cancelBtnY,
            w = buttonW,
            h = buttonH,
            cornerRadius = 4,
            onClick = popup.onClickCancel
        }
    }

    local inputX = (GameWidth / 2) - 18
    local inputY = (GameHeight / 2) - 40
    local inputYOffset = 26

    inputBoxes = {
        height = {
            label = lang[Current_lang].custom_labels.height,
            text = tostring(config.gridHeight),
            active = false,
            firstClick = false,
            maxDigits = 2,
            x = inputX,
            y = inputY,
            w = 40,
            h = 22,
        },
        width = {
            label = lang[Current_lang].custom_labels.width,
            text = tostring(config.gridWidth),
            active = false,
            firstClick = false,
            maxDigits = 2,
            x = inputX,
            y = inputY + inputYOffset,
            w = 40,
            h = 22,
        },
        mines = {
            label = lang[Current_lang].custom_labels.mines,
            text = tostring(config.gridMines),
            active = false,
            firstClick = false,
            maxDigits = 3,
            x = inputX,
            y = inputY + (inputYOffset * 2),
            w = 40,
            h = 22,
        },
    }

    local linkH = smallFont:getHeight()
    local linkColor = { 0, 0, 238 / 255 }
    local linkHoverColor = { 0, 102 / 255, 1 }

    local sourceLabel = "Source on Github"
    local sourceLink = "https://github.com/Kurtsley/XP-Minesweeper-Classic"
    local sourceLinkW = smallFont:getWidth(sourceLabel)
    local sourceLinkX = (GameWidth / 2) - (sourceLinkW / 2)
    local sourceLinkY = (GameHeight / 2) - 10


    linkButtons = {
        {
            label = sourceLabel,
            link = sourceLink,
            x = sourceLinkX,
            y = sourceLinkY,
            w = sourceLinkW,
            h = linkH,
            color = linkColor,
            hover = linkHoverColor,
            onClick = clickLink,
        }
    }

    if state == "HighScore" then
        local newTime = timer:getTime()
        local roundTime = tonumber(string.format("%.3f", newTime))
        popupTitle = "High Score"

        local diffCalc = {
            easy = lang[Current_lang].high_score_labels.easy,
            medium = lang[Current_lang].high_score_labels.medium,
            hard = lang[Current_lang].high_score_labels.hard,
        }

        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 50 }

        local label = diffCalc[difficulty] or "None"
        local x, y = labelPos[1], labelPos[2]

        popup.content = {
            label = label,
            x = x,
            y = y,
            time = roundTime,
            buttons = { buttons[1] },
        }

        file_manager.save_times(difficulty, roundTime)
    elseif state == "About" then
        local aboutLabel = string.format("Version %s\nCopyright (c) 2025 Kurtsley", config.version)
        local aboutW = smallFont:getWidth(aboutLabel)
        local aboutX = (GameWidth / 2) - (aboutW / 2)
        local aboutY = (GameHeight / 2) - 38

        popupTitle = "About"

        popup.content = {
            label = aboutLabel,
            x = aboutX,
            y = aboutY,
            h = 130,
            buttons = { buttons[1] },
            linkButtons = linkButtons,
        }
    elseif state == "SaveError" then
        local saveErrorLabel = lang[Current_lang].dialogs.save_error_body
        local saveErrorW = smallFont:getWidth(saveErrorLabel)
        local saveErrorX = (GameWidth / 2) - (saveErrorW / 2)
        local saveErrorY = (GameHeight / 2) - 54

        popupTitle = "Error"

        popup.content = {
            label = saveErrorLabel,
            x = saveErrorX,
            y = saveErrorY,
            h = 130,
            buttons = { buttons[1] },
        }
    elseif state == "Best" then
        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 54 }
        local x, y = labelPos[1], labelPos[2]

        local times = file_manager.load()

        local bestTimesLabel = string.format("%-13s %7.3f\n%-13s %7.3f\n%-13s %7.3f",
            lang[Current_lang].best_times_labels.easy, times.easy,
            lang[Current_lang].best_times_labels.intermediate, times.medium, lang[Current_lang].best_times_labels.expert,
            times.hard
        )

        popupTitle = "Mine Sweepers"

        popup.content = {
            label = bestTimesLabel,
            x = x,
            y = y,
            h = 130,
            buttons = { buttons[1], buttons[2] }
        }
    elseif state == "Custom" then
        popup.content = {
            inputBoxes = inputBoxes,
            h = 160,
            buttons = {
                buttons[1],
                buttons[3]
            },
        }
        popupTitle = "Custom Field"
    else
        error("Unkown popup state")
    end
end

function popup.drawNew()
    if not popup.shouldShow then return end

    local centerX = (GameWidth / 2) - (popupWidth / 2)
    local centerY = (GameHeight / 2) - (popup.content.h / 2)

    -- Shadow
    g.setColor(shadowColor)
    -- Lowering the window by one because the shadow blends into the tiles...
    g.rectangle("fill", centerX, centerY + 1, popupWidth + shadowOffset, popup.content.h + shadowOffset, cornerRad,
        cornerRad)
    -- Top bar
    g.setFont(smallFont)
    g.setColor(topBarColor)
    g.rectangle("fill", centerX, centerY, popupWidth, topBarHeight, cornerRad, cornerRad)
    g.rectangle("fill", centerX, centerY + (topBarHeight / 2), popupWidth, topBarHeight / 2)
    -- Title
    g.setColor(textColor)
    local labelWidth = smallFont:getWidth(popupTitle)
    g.printf(popupTitle, centerX + popupXOffset, centerY + popupYOffset, labelWidth, "left")
    -- Body
    g.setColor(backgroundColor)
    g.rectangle("fill", centerX, centerY + topBarHeight, popupWidth, popup.content.h - topBarHeight, cornerRad,
        cornerRad)
    g.rectangle("fill", centerX, centerY + topBarHeight, popupWidth, topBarHeight)

    if highScorePopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(string.format(lang[Current_lang].dialogs.high_score, popup.content.label), popup
            .content
            .x, popup.content.y,
            popupWidth - 40,
            "center")
        g.setFont(bigFont)
        g.printf(string.format("%.3f", popup.content.time), popup.content.x, popup.content.y + 32,
            popupWidth - 40,
            "center")
    elseif aboutPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(popup.content.label, popup.content.x, popup.content.y, popupWidth - 40, "center")
        for _, link in ipairs(popup.content.linkButtons) do
            local hovered = within(link.x, link.y, link.w, link.h)
            local color = hovered and link.hover or link.color
            g.setColor(color)
            g.printf(link.label, link.x, link.y, link.w, "center")
        end
    elseif bestTimesPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(lang[Current_lang].dialogs.best_times_title, popup.content.x, popup.content.y,
            popupWidth - 40, "center")
        g.printf(popup.content.label, popup.content.x, popup.content.y + 22, popupWidth - 40, "center")
    elseif saveErrorPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(lang[Current_lang].dialogs.save_error_title, popup.content.x + 3, popup.content.y,
            popupWidth - 24, "center")
        g.printf(popup.content.label, popup.content.x + 3, popup.content.y + 22, popupWidth - 24, "center")
    elseif customPopupShown then
        -- Input boxes
        for _, inputBox in pairs(popup.content.inputBoxes) do
            g.setColor(textColor)
            g.setFont(smallFont)
            g.printf(strings.displayStr(inputBox.label), inputBox.x - 40, inputBox.y + 4, popupWidth - 40,
                "left")
            -- Underline
            if strings.hasHotkey(inputBox.label) then
                strings.drawUnderline(inputBox.label, inputBox.x - 40, inputBox.y + 4, inputBox.w, smallFont, true, false,
                    alt)
            end
            g.setColor(inputBoxBackground)
            g.rectangle("fill", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            g.setColor(0, 0, 0)
            g.rectangle("line", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            -- Input text
            g.setColor(textColor)
            g.setFont(medFont)
            -- First click highlight box
            if inputBox.active and inputBox.firstClick and highlightBoxVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                g.rectangle("fill", textX, inputBox.y + 3, textWidth, medFont:getHeight())
                g.setColor(1, 1, 1)
            end
            g.printf(inputBox.text, inputBox.x, inputBox.y + 3, inputBox.w, "center")
            -- Text caret
            if inputBox.active and not inputBox.firstClick and caretVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                local caretX = textX + textWidth
                local caretY = inputBox.y + 3
                g.setColor(textColor)
                g.line(caretX, caretY, caretX, caretY + medFont:getHeight())
            end
        end
    end

    for _, btn in ipairs(popup.content.buttons) do
        local hovered = within(btn.x, btn.y, btn.w, btn.h)
        local bgColor = hovered and buttonBackgroundHoverColor or buttonBackgroundColor
        g.setColor(bgColor)
        g.rectangle("fill", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        local borderColor = hovered and buttonBorderHoverColor or buttonBorderColor
        g.setColor(borderColor)
        g.rectangle("line", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        -- Text
        g.setFont(smallFont)
        g.setColor(textColor)
        g.printf(strings.displayStr(btn.label), btn.x, btn.y + 6, btn.w, "center")

        if strings.hasHotkey(btn.label) then
            strings.drawUnderline(btn.label, btn.x - 8, btn.y + 6, btn.w, smallFont, false, true)
        end
    end

    g.setColor(1, 1, 1)
end

function popup.draw()
    if not popup.shouldShow then return end

    local textColor = { 0, 0, 0 }
    local inputBoxActiveColor = { 1, 1, 1 }

    g.draw(popupImage, (GameWidth / 2) - (popupWidth / 2), (GameHeight / 2) - (popupHeight / 2))
    g.setColor(0, 0, 0)
    g.rectangle("line", (GameWidth / 2) - (popupWidth / 2), (GameHeight / 2) - (popupHeight / 2), popupWidth,
        popupHeight)

    if highScorePopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(string.format(lang[Current_lang].dialogs.high_score, popup.content.label), popup
            .content
            .x, popup.content.y,
            popupWidth - 40,
            "center")
        g.setFont(bigFont)
        g.printf(string.format("%.3f", popup.content.time), popup.content.x, popup.content.y + 32,
            popupWidth - 40,
            "center")
    elseif aboutPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(popup.content.label, popup.content.x, popup.content.y, popupWidth - 40, "center")
        for _, link in ipairs(popup.content.linkButtons) do
            local hovered = within(link.x, link.y, link.w, link.h)
            local color = hovered and link.hover or link.color
            g.setColor(color)
            g.printf(link.label, link.x, link.y, link.w, "center")
        end
    elseif bestTimesPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(lang[Current_lang].dialogs.best_times_title, popup.content.x, popup.content.y,
            popupWidth - 40, "center")
        g.printf(popup.content.label, popup.content.x, popup.content.y + 22, popupWidth - 40, "center")
    elseif saveErrorPopupShown then
        g.setColor(textColor)
        g.setFont(smallFont)
        g.printf(lang[Current_lang].dialogs.save_error_title, popup.content.x + 3, popup.content.y,
            popupWidth - 24, "center")
        g.printf(popup.content.label, popup.content.x + 3, popup.content.y + 22, popupWidth - 24, "center")
    elseif customPopupShown then
        -- Input boxes
        for _, inputBox in pairs(popup.content.inputBoxes) do
            g.setColor(textColor)
            g.setFont(smallFont)
            g.printf(strings.displayStr(inputBox.label), inputBox.x - 40, inputBox.y + 4, popupWidth - 40,
                "left")
            -- Underline
            if strings.hasHotkey(inputBox.label) then
                strings.drawUnderline(inputBox.label, inputBox.x - 40, inputBox.y + 4, inputBox.w, smallFont, true, false,
                    alt)
            end
            if inputBox.active then
                g.setColor(inputBoxActiveColor)
            else
                g.setColor(234 / 255, 234 / 255, 234 / 255)
            end
            g.rectangle("fill", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            g.setColor(0, 0, 0)
            g.rectangle("line", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            -- Input text
            g.setColor(textColor)
            g.setFont(medFont)
            -- First click highlight box
            if inputBox.active and inputBox.firstClick and highlightBoxVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                g.rectangle("fill", textX, inputBox.y + 3, textWidth, medFont:getHeight())
                g.setColor(1, 1, 1)
            end
            g.printf(inputBox.text, inputBox.x, inputBox.y + 3, inputBox.w, "center")
            -- Text caret
            if inputBox.active and not inputBox.firstClick and caretVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                local caretX = textX + textWidth
                local caretY = inputBox.y + 3
                g.setColor(textColor)
                g.line(caretX, caretY, caretX, caretY + medFont:getHeight())
            end
        end
    end

    for _, btn in ipairs(popup.content.buttons) do
        local hovered = within(btn.x, btn.y, btn.w, btn.h)
        local color = hovered and btn.hoverColor or btn.normalColor

        g.setColor(color)
        g.rectangle("fill", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        g.setColor(0, 0, 0)
        g.rectangle("line", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        g.setFont(smallFont)
        g.printf(strings.displayStr(btn.label), btn.x, btn.y + 6, btn.w, "center")

        if strings.hasHotkey(btn.label) then
            strings.drawUnderline(btn.label, btn.x - 8, btn.y + 6, btn.w, smallFont, false, true)
        end
    end

    g.setColor(1, 1, 1)
end

return popup
