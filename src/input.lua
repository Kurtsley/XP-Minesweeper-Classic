-- MIT License, Copyright (c) 2025 Kurtsley

-- input.lua
-- Handle all mouse or touch inputs

local input = {}

input.mousePressedCallbacks = {}
input.mouseReleasedCallbacks = {}
input.keyPressedCallbacks = {}
input.textInputCallbacks = {}
input.heldButtons = {}

function input.registerTextInput(callback)
    table.insert(input.textInputCallbacks, callback)
end

function input.registerKeyPress(callback)
    table.insert(input.keyPressedCallbacks, callback)
end

function input.registerMousePress(callback)
    table.insert(input.mousePressedCallbacks, callback)
end

function input.registerMouseRelease(callback)
    table.insert(input.mouseReleasedCallbacks, callback)
end

function input.textinput(t)
    for _, callback in ipairs(input.textInputCallbacks) do
        callback(t)
    end
end

function input.keypressed(key)
    for _, callback in ipairs(input.keyPressedCallbacks) do
        callback(key)
    end
end

function input.mousepressed(button)
    input.heldButtons[button] = true
    for _, callback in ipairs(input.mousePressedCallbacks) do
        callback(button, input.heldButtons)
    end
end

function input.mousereleased(button)
    local heldBefore = {}
    for k, v in pairs(input.heldButtons) do
        heldBefore[k] = v
    end
    input.heldButtons[button] = nil

    for _, callback in ipairs(input.mouseReleasedCallbacks) do
        callback(button, input.heldButtons)
    end
end

return input
