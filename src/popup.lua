-- popup.lua
-- Shows a popup at victory or best times, or even the about page

local file_manager = require("src.file_manager")
local config = require("src.config")
local state = require("src.state")
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

local highlightTimer = 0
local caretVisible = true
local highlightBoxVisible = true

local aboutPopupShown = false
local bestTimesPopupShown = false
local customPopupShown = false
local highScorePopupShown = false

local popupImage

function popup.onMouseReleased(button)
    if button == 1 then
        if popup.shouldShow then
            for _, btn in ipairs(buttons) do
                if popup.within(btn.x, btn.y, btn.w, btn.h) then
                    if btn.onClick then
                        btn.onClick()
                        break
                    end
                end
            end
        end
    end
end

function popup.onMousePressed(button)
    if button == 1 then
        if customPopupShown then
            for _, box in ipairs(inputBoxes) do
                box.active = false
            end
            for _, box in ipairs(inputBoxes) do
                if popup.within(box.x, box.y, box.w, box.h) then
                    box.active = true
                    box.firstClick = true
                    break
                end
            end
        end
    end
end

function popup.onKeyPressed(key)
    if popup.inputActive() then
        for _, box in ipairs(inputBoxes) do
            if box.active then
                if key == "backspace" then
                    box.text = box.text:sub(1, -2)
                end
            end
        end
        if key == "return" or key == "escape" then
            for _, box in ipairs(inputBoxes) do
                box.active = false
            end
        end
    else
        if key == "return" then
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
    for _, box in ipairs(inputBoxes) do
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
    popupImage = love.graphics.newImage("assets/images/popupdark.png")
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
    for _, box in ipairs(inputBoxes) do
        if box.active then return true end
    end

    return false
end

function popup.commitCustomInputs()
    local gameplay = require("src.gameplay")
    local width, height, mines

    for _, box in ipairs(inputBoxes) do
        local num = tonumber(box.text)
        if box.label == "Height:" then
            height = popup.clamp(num or 9, 9, 99) -- Should be 24
        elseif box.label == "Width:" then
            width = popup.clamp(num or 9, 9, 99)  -- Should be 30
        elseif box.label == "Mines:" then
            mines = num or 10                     -- Should be 667
        end
    end

    local maxMines = (width - 1) * (height - 1)
    mines = popup.clamp(mines, 10, maxMines)

    config.setConfig("gridHeight", height)
    config.setConfig("gridWidth", width)
    config.setConfig("gridMines", mines)

    gameplay.startNewGame("custom")
end

function popup.within(btnX, btnY, btnW, btnH)
    local mx, my = love.mouse.getPosition()

    if mx > btnX and mx <= btnX + btnW and my > btnY and my <= btnY + btnH then
        return true
    end

    return false
end

function popup.show(state)
    bestTimesPopupShown = false
    aboutPopupShown = false
    customPopupShown = false
    highScorePopupShown = false

    if state == "About" then
        aboutPopupShown = true
    elseif state == "Best" then
        bestTimesPopupShown = true
    elseif state == "Custom" then
        customPopupShown = true
    elseif state == "HighScore" then
        highScorePopupShown = true
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

function popup.onClickCancel()
    popup.hide()
end

function popup.setup(state)
    state = state or nil

    local difficulty = gameState.getDifficulty()

    local buttonY = (GameHeight / 2) + 35

    local OKCentered = { (GameWidth / 2) - 30, buttonY }
    local OKRight = { (GameWidth / 2) + 6, buttonY }
    local resetPosition = { (GameWidth / 2) - 66, buttonY }
    local cancelPosition = resetPosition

    local OKbtnX, OKbtnY

    if state == "About" or state == "HighScore" then
        OKbtnX, OKbtnY = OKCentered[1], OKCentered[2]
    else
        OKbtnX, OKbtnY = OKRight[1], OKRight[2]
    end

    local resetBtnX, resetBtnY = resetPosition[1], resetPosition[2]
    local cancelBtnX, cancelBtnY = cancelPosition[1], cancelPosition[2]

    buttons = {
        {
            label = "OK",
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
            label = "Reset",
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
            label = "Cancel",
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
        {
            label = "Height:",
            text = tostring(config.gridHeight),
            active = false,
            firstClick = false,
            maxDigits = 2,
            x = inputX,
            y = inputY,
            w = 40,
            h = 22,
        },
        {
            label = "Width:",
            text = tostring(config.gridWidth),
            active = false,
            firstClick = false,
            maxDigits = 2,
            x = inputX,
            y = inputY + inputYOffset,
            w = 40,
            h = 22,
        },
        {
            label = "Mines:",
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


    if state == "HighScore" then
        local newTime = timer:getTime()
        local roundTime = tonumber(string.format("%.3f", newTime))

        local diffCalc = {
            easy = "Beginner",
            medium = "Intermediate",
            hard = "Expert",
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

        file_manager.save(difficulty, roundTime)
    elseif state == "About" then
        local aboutLabel = "By Kurtsley - 2025\n\nMade with Love2d\nhttps://love2d.org/"

        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 50 }
        local x, y = labelPos[1], labelPos[2]

        popup.content = {
            label = aboutLabel,
            x = x,
            y = y,
            buttons = { buttons[1] },
        }
    elseif state == "Best" then
        local labelPos = { (GameWidth / 2) - 70, (GameHeight / 2) - 54 }
        local x, y = labelPos[1], labelPos[2]

        local times = file_manager.load()

        local bestTimesLabel = string.format("%-13s %7.3f\n%-13s %7.3f\n%-13s %7.3f", "Easy: ", times.easy,
            "Intermediate: ", times.medium, "Expert: ", times.hard
        )

        popup.content = {
            label = bestTimesLabel,
            x = x,
            y = y,
            buttons = { buttons[1], buttons[2] }
        }
    elseif state == "Custom" then
        popup.content = {
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

    local textColor = { 0, 0, 0 }
    local inputBoxActiveColor = { 1, 1, 1 }
    local smallFont = love.graphics.newFont(10)
    local medFont = love.graphics.newFont(14)
    local bigFont = love.graphics.newFont(20)

    love.graphics.draw(popupImage, (GameWidth / 2) - (popupWidth / 2), (GameHeight / 2) - (popupHeight / 2))
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", (GameWidth / 2) - (popupWidth / 2), (GameHeight / 2) - (popupHeight / 2), popupWidth,
        popupHeight)

    if highScorePopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(smallFont)
        love.graphics.printf(string.format("You have the fastest time for %s level.", popup.content.label), popup
            .content
            .x, popup.content.y,
            popupWidth - 40,
            "center")
        love.graphics.setFont(bigFont)
        love.graphics.printf(string.format("%.3f", popup.content.time), popup.content.x, popup.content.y + 32,
            popupWidth - 40,
            "center")
    elseif aboutPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(smallFont)
        love.graphics.printf(popup.content.label, popup.content.x, popup.content.y, popupWidth - 40, "center")
    elseif bestTimesPopupShown then
        love.graphics.setColor(textColor)
        love.graphics.setFont(smallFont)
        love.graphics.printf("Fastest Mine Sweepers", popup.content.x, popup.content.y, popupWidth - 40, "center")
        love.graphics.printf(popup.content.label, popup.content.x, popup.content.y + 22, popupWidth - 40, "center")
    elseif customPopupShown then
        -- Input boxes
        for _, inputBox in ipairs(popup.content.inputBoxes) do
            love.graphics.setColor(textColor)
            love.graphics.setFont(smallFont)
            love.graphics.printf(inputBox.label, inputBox.x - 40, inputBox.y + 4, popupWidth - 40, "left")
            if inputBox.active then
                love.graphics.setColor(inputBoxActiveColor)
            else
                love.graphics.setColor(234 / 255, 234 / 255, 234 / 255)
            end
            love.graphics.rectangle("fill", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", inputBox.x, inputBox.y, inputBox.w, inputBox.h)
            -- Input text
            love.graphics.setColor(textColor)
            love.graphics.setFont(medFont)
            -- First click highlight box
            if inputBox.active and inputBox.firstClick and highlightBoxVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                love.graphics.rectangle("fill", textX, inputBox.y + 3, textWidth, medFont:getHeight())
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(inputBox.text, inputBox.x, inputBox.y + 3, inputBox.w, "center")
            -- Text caret
            if inputBox.active and not inputBox.firstClick and caretVisible then
                local textWidth = medFont:getWidth(inputBox.text)
                local textX = inputBox.x + (inputBox.w - textWidth) / 2
                local caretX = textX + textWidth
                local caretY = inputBox.y + 3
                love.graphics.setColor(textColor)
                love.graphics.line(caretX, caretY, caretX, caretY + medFont:getHeight())
            end
        end
    end

    for _, btn in ipairs(popup.content.buttons) do
        local hovered = popup.within(btn.x, btn.y, btn.w, btn.h)
        local color = hovered and btn.hoverColor or btn.normalColor

        love.graphics.setColor(color)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, btn.cornerRadius, btn.cornerRadius)
        love.graphics.setFont(smallFont)
        love.graphics.printf(btn.label, btn.x, btn.y + 6, btn.w, "center")
    end

    love.graphics.setColor(1, 1, 1)
end

return popup
