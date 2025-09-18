-- MIT License, Copyright (c) 2025 Kurtsley

-- strings.lua
-- Handles formatting of strings and hotkeys

local state = require("src.state")
local gameState = state.gameState

local strings = {}

function strings.hasHotkey(str)
    return string.find(str, "&")
end

function strings.displayStr(str)
    if strings.hasHotkey(str) then
        local newStr = string.gsub(str, "&", "")
        return newStr
    else
        return str
    end
end

function strings.drawUnderline(str, x, y, w, font, sub, but, localAlt)
    local alt = (localAlt == nil) and gameState.isAltPressed() or localAlt

    if alt or but then
        for i = 1, #str do
            if str:sub(i, i) == "&" then
                local hotkeyCharIndex = i + 1
                local textX = sub and x or (x + (w - font:getWidth(str)))

                local preText = str:sub(1, hotkeyCharIndex - 1):gsub("&", "")
                local offsetX = font:getWidth(preText)

                local charWidth = font:getWidth(str:sub(hotkeyCharIndex, hotkeyCharIndex))

                love.graphics.line(textX + offsetX, y + font:getHeight() - 1, textX + offsetX + charWidth,
                    y + font:getHeight() - 1)
            end
        end
    end
end

return strings
