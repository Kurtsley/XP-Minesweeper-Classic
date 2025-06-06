-- sound.lua
-- All sound logic

local sound = {}

local sources = {}

function sound.load()
    sources.pop = love.audio.newSource("assets/sound/pop.wav", "static")
    sources.explode = love.audio.newSource("assets/sound/explode.wav", "static")
    sources.clap = love.audio.newSource("assets/sound/applause.wav", "static")
end

function sound.play(name)
    sources[name]:play()
end

return sound
