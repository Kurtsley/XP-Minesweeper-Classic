-- init.lua
-- Load all modules

local M = {}

function M.loadAllModules()
    require("src.state")
    require("src.counter_timer")
    require("src.tile")
    require("src.board")
    require("src.tilesets")
    require("src.face")
    require("src.gameplay")
    require("src.input")
    require("src.inputhandlers")
    require("src.game_menu")
    require("src.config")
    require("src.game_menu")
    require("src.file_manager")
    require("src.level_builder")
    require("src.sound")
end

return M
