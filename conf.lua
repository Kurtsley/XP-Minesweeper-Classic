-- MIT License, Copyright (c) 2025 Kurtsley

-- Conf file

function love.conf(t)
    t.window.title = "XP Minesweeper Classic"
    t.window.icon = "assets/icons/iconsmall.png"
    t.window.width = 176
    t.window.height = 264
    t.window.vsync = true
    t.window.highdpi = false
    t.modules.joystick = false
    t.modules.physics = false

    t.releases = {
        title = "msxp-classic",
        version = "1.2.0",
        author = "Kurtsley",
        email = "kurtsley@gmail.com",
        description = "Minesweeper with Love",
    }
end
