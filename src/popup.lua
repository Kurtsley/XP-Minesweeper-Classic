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

local popupWidth = 176
local popupHeight = 160

local popup = {
    shouldShow = false,
    content = {},
}

local buttons = {}
local inputBoxes = {}
local linkButtons = {}
local xButton = {}

local shadowColor = { 0, 0, 0, 0.2 }
local buttonBorderColor = { 220 / 255, 220 / 255, 220 / 255 }
local buttonBorderHoverColor = { 0, 120 / 255, 212 / 255 }
local buttonBackgroundColor = { 1, 1, 1 }
local buttonBackgroundHoverColor = { 224 / 255, 238 / 255, 249 / 255 }
local backgroundColor = { 240 / 255, 240 / 255, 240 / 255 }
local topBarColor = { 236 / 255, 246 / 255, 249 / 255 }
local cancelRed = { 240 / 255, 56 / 255, 36 / 255 }
local shadowOffset = 6
local cornerRad = 6
local topBarHeight = 24
local titleOffset = 5
local cancelXOffset = 34


local highlightTimer = 0
local caretVisible = true
local highlightBoxVisible = true

local aboutPopupShown = false
local bestTimesPopupShown = false
local customPopupShown = false
local highScorePopupShown = false
local saveErrorPopupShown = false

local centerX, centerY

local smallFont = love.graphics.newFont(10)
local medFont = love.graphics.newFont(14)
local bigFont = love.graphics.newFont(20)

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
            if within(xButton.x, xButton.y, xButton.w, xButton.h) then
                if xButton.onClick then
                    xButton.onClick()
                    return
                end
            end
            for _, btn in ipairs(buttons) do
                if within(btn.x, btn.y + topBarHeight, btn.w, btn.h) then
                    if btn.onClick then
                        btn.onClick()
                        break
                    end
                end
            end
            if aboutPopupShown then
                for _, link in ipairs(linkButtons) do
                    if within(link.x, link.y + topBarHeight, link.w, link.h) then
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
                if within(box.x, box.y + topBarHeight, box.w, box.h) then
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
    popupImage = love.graphics.newImage("assets/images/newpopup.png")

    local screenW, screenH = love.graphics.getDimensions()
    centerX = (screenW / 2) - (popupWidth / 2)
    centerY = (screenH / 2) - (popupHeight / 2)

    xButton = {
        x = centerX + popupWidth - cancelXOffset,
        y = centerY,
        w = cancelXOffset,
        h = topBarHeight,
        onClick = popup.onClickCancel
    }
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

    local buttonY = (GameHeight / 2) + 35

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
            w = 60,
            h = 26,
            cornerRadius = 8,
            normalColor = { 234 / 255, 234 / 255, 234 / 255 },
            hoverColor = { 208 / 255, 208 / 255, 208 / 255 },
            onClick = popup.onClickOK
        },
        {
            label = lang[Current_lang].buttons.reset,
            x = resetBtnX,
            y = resetBtnY,
            w = 60,
            h = 26,
            cornerRadius = 8,
            normalColor = { 234 / 255, 234 / 255, 234 / 255 },
            hoverColor = { 208 / 255, 208 / 255, 208 / 255 },
            onClick = popup.onClickReset
        },
        {
            label = lang[Current_lang].buttons.cancel,
            x = cancelBtnX,
            y = cancelBtnY,
            w = 60,
            h = 26,
            cornerRadius = 8,
            normalColor = { 234 / 255, 234 / 255, 234 / 255 },
            hoverColor = { 208 / 255, 208 / 255, 208 / 255 },
            onClick = popup.onClickCancel
        }
    }

    local inputX = (GameWidth / 2) - 18
    local inputY = (GameHeight / 2) - 61
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

        local diffCalc = {
            easy = lang[Current_lang].high_score_labels.easy,
            medium = lang[Current_lang].high_score_labels.medium,
            hard = lang[Current_lang].high_score_labels.hard,
        }

        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 50 }

        local title = "High Score"
        local label = diffCalc[difficulty] or "None"
        local x, y = labelPos[1], labelPos[2]

        popup.content = {
            title = title,
            label = label,
            x = x,
            y = y,
            time = roundTime,
            buttons = { buttons[1] },
        }

        file_manager.save_times(difficulty, roundTime)
    elseif state == "About" then
        local aboutTitle = "About"
        local aboutLabel = string.format("Version %s\nCopyright (c) 2025 Kurtsley", config.version)
        local aboutW = smallFont:getWidth(aboutLabel)
        local aboutX = (GameWidth / 2) - (aboutW / 2)
        local aboutY = (GameHeight / 2) - 48

        popup.content = {
            title = aboutTitle,
            label = aboutLabel,
            x = aboutX,
            y = aboutY,
            buttons = { buttons[1] },
            linkButtons = linkButtons,
        }
    elseif state == "SaveError" then
        local saveErrorTitle = "Error"
        local saveErrorLabel = lang[Current_lang].dialogs.save_error_body
        local saveErrorW = smallFont:getWidth(saveErrorLabel)
        local saveErrorX = (GameWidth / 2) - (saveErrorW / 2)
        local saveErrorY = (GameHeight / 2) - 54

        popup.content = {
            title = saveErrorTitle,
            label = saveErrorLabel,
            x = saveErrorX,
            y = saveErrorY,
            buttons = { buttons[1] },
        }
    elseif state == "Best" then
        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 54 }
        local x, y = labelPos[1], labelPos[2]

        local times = file_manager.load()

        local bestTimesTitle = "Fastest"
        local bestTimesLabel = string.format("%-13s %7.3f\n%-13s %7.3f\n%-13s %7.3f",
            lang[Current_lang].best_times_labels.easy, times.easy,
            lang[Current_lang].best_times_labels.intermediate, times.medium, lang[Current_lang].best_times_labels.expert,
            times.hard
        )

        popup.content = {
            title = bestTimesTitle,
            label = bestTimesLabel,
            x = x,
            y = y,
            buttons = { buttons[1], buttons[2] }
        }
    elseif state == "Custom" then
        local title = "Custom"
        popup.content = {
            title = title,
            inputBoxes = inputBoxes,
            buttons = {
                buttons[1],
                buttons[3]
            },
        }
    else
        error("Unkown popup state")
    end
end

function popup.draw()
    if not popup.shouldShow then return end

    local cancelColor, XColor

    local textColor = { 0, 0, 0 }
    local inputBoxActiveColor = { 1, 1, 1 }

    love.graphics.setColor(shadowColor)
    love.graphics.rectangle("fill", (GameWidth / 2) - (popupWidth / 2) + shadowOffset,
        (GameHeight / 2) - (popupHeight / 2) + shadowOffset, popupWidth,
        popupHeight + topBarHeight, cornerRad, cornerRad)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(popupImage, (GameWidth / 2) - (popupWidth / 2), (GameHeight / 2) - (popupHeight / 2))
    -- Cancel X
    local closeXCenter = centerX + popupWidth - cancelXOffset + (cancelXOffset / 2)
    local closeYCenter = centerY + (topBarHeight / 2)
    local hoveredX = within(centerX + popupWidth - cancelXOffset, centerY, cancelXOffset, topBarHeight)

    cancelColor = hoveredX and cancelRed or topBarColor
    XColor = hoveredX and backgroundColor or textColor

    love.graphics.setColor(cancelColor)
    love.graphics.rectangle("fill", centerX + popupWidth - cancelXOffset, centerY, cancelXOffset, topBarHeight, cornerRad,
        cornerRad)
    love.graphics.rectangle("fill", centerX + popupWidth - cancelXOffset, centerY, topBarHeight, topBarHeight)
    love.graphics.rectangle("fill", centerX + popupWidth - cancelXOffset, centerY + (topBarHeight / 2), cancelXOffset,
        topBarHeight / 2)
    love.graphics.setColor(XColor)
    love.graphics.line(closeXCenter - 5, closeYCenter - 5, closeXCenter + 5, closeYCenter + 5)
    love.graphics.line(closeXCenter + 5, closeYCenter - 5, closeXCenter - 5, closeYCenter + 5)

    if highScorePopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(medFont)
        love.graphics.print(popup.content.title, centerX + titleOffset * 2, centerY + titleOffset)
        love.graphics.setFont(smallFont)
        love.graphics.printf(string.format(lang[Current_lang].dialogs.high_score, popup.content.label), popup
            .content
            .x, popup.content.y + topBarHeight,
            popupWidth - 40,
            "center")
        love.graphics.setFont(bigFont)
        love.graphics.printf(string.format("%.3f", popup.content.time), popup.content.x,
            popup.content.y + 32 + topBarHeight,
            popupWidth - 40,
            "center")
    elseif aboutPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(medFont)
        love.graphics.print(popup.content.title, centerX + titleOffset * 2, centerY + titleOffset)
        love.graphics.setFont(smallFont)
        love.graphics.printf(popup.content.label, popup.content.x, popup.content.y + topBarHeight, popupWidth - 40,
            "center")
        for _, link in ipairs(popup.content.linkButtons) do
            local hovered = within(link.x, link.y + topBarHeight, link.w, link.h)
            local color = hovered and link.hover or link.color
            love.graphics.setColor(color)
            love.graphics.printf(link.label, link.x, link.y + topBarHeight, link.w, "center")
        end
    elseif bestTimesPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(medFont)
        love.graphics.print(popup.content.title, centerX + titleOffset * 2, centerY + titleOffset)
        love.graphics.setFont(smallFont)
        love.graphics.printf(lang[Current_lang].dialogs.best_times_title, popup.content.x, popup.content.y + topBarHeight,
            popupWidth - 40, "center")
        love.graphics.printf(popup.content.label, popup.content.x, popup.content.y + 22 + topBarHeight, popupWidth - 40,
            "center")
    elseif saveErrorPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(medFont)
        love.graphics.print(popup.content.title, centerX + titleOffset * 2, centerY + titleOffset)
        love.graphics.setFont(smallFont)
        love.graphics.printf(lang[Current_lang].dialogs.save_error_title, popup.content.x + 3,
            popup.content.y + topBarHeight,
            popupWidth - 24, "center")
        love.graphics.printf(popup.content.label, popup.content.x + 3, popup.content.y + 22 + topBarHeight,
            popupWidth - 24, "center")
    elseif customPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(medFont)
        love.graphics.print(popup.content.title, centerX + titleOffset * 2, centerY + titleOffset)
        -- Input boxes
        for _, inputBox in pairs(popup.content.inputBoxes) do
            love.graphics.setColor(textColor)
            love.graphics.setFont(smallFont)
            love.graphics.printf(strings.displayStr(inputBox.label), inputBox.x - 40, inputBox.y + 4 + topBarHeight,
                popupWidth - 40,
                "left")
            -- Underline
            if strings.hasHotkey(inputBox.label) then
                strings.drawUnderline(inputBox.label, inputBox.x - 40, inputBox.y + 4 + topBarHeight, inputBox.w,
                    smallFont, true, false,
                    alt)
            end
            if inputBox.active then
                love.graphics.setColor(inputBoxActiveColor)
            else
                love.graphics.setColor(234 / 255, 234 / 255, 234 / 255)
            end
            love.graphics.rectangle("fill", inputBox.x, inputBox.y + topBarHeight, inputBox.w, inputBox.h)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", inputBox.x, inputBox.y + topBarHeight, inputBox.w, inputBox.h)
            -- Input text
            love.graphics.setColor(textColor)
            love.graphics.setFont(medFont)
            -- First click highlight box
            if inputBox.active and inputBox.firstClick and highlightBoxVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                love.graphics.rectangle("fill", textX, inputBox.y + 3 + topBarHeight, textWidth, medFont:getHeight())
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(inputBox.text, inputBox.x, inputBox.y + 3 + topBarHeight, inputBox.w, "center")
            -- Text caret
            if inputBox.active and not inputBox.firstClick and caretVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                local caretX = textX + textWidth
                local caretY = inputBox.y + 3 + topBarHeight
                love.graphics.setColor(textColor)
                love.graphics.line(caretX, caretY, caretX, caretY + medFont:getHeight())
            end
        end
    end

    for _, btn in ipairs(popup.content.buttons) do
        local hovered = within(btn.x, btn.y + topBarHeight, btn.w, btn.h)
        local bgColor = hovered and buttonBackgroundHoverColor or buttonBackgroundColor

        love.graphics.setColor(bgColor)
        love.graphics.rectangle("fill", btn.x, btn.y + topBarHeight, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        local borderColor = hovered and buttonBorderHoverColor or buttonBorderColor
        love.graphics.setColor(borderColor)
        love.graphics.rectangle("line", btn.x, btn.y + topBarHeight, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(textColor)
        love.graphics.printf(strings.displayStr(btn.label), btn.x, btn.y + 6 + topBarHeight, btn.w, "center")

        if strings.hasHotkey(btn.label) then
            strings.drawUnderline(btn.label, btn.x - 8, btn.y + 6 + topBarHeight, btn.w, smallFont, false, true)
        end
    end

    love.graphics.setColor(1, 1, 1)
end

return popup
