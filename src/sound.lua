-- MIT License, Copyright (c) 2025-2026 Kurtsley

-- sound.lua
-- All sound logic

local config = require("src.config")

local sound = {}

local sources = {}

function sound.load()
    sources.pop = love.audio.newSource("assets/sound/pop.wav", "static")
    sources.explode = love.audio.newSource("assets/sound/explode.wav", "static")
    sources.clap = love.audio.newSource("assets/sound/applause.wav", "static")
end

function sound.play(name)
    if config.sound then
        sources[name]:play()
    end
end

return sound
