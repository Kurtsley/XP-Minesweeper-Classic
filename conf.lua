-- Conf file
function love.conf(t)
    t.window.title = "MinesweeperXP Classic"
    t.window.icon = "assets/icons/icon-small.png"
    t.window.width = 176
    t.window.height = 264
    t.modules.joystick = false
    t.modules.physics = false

    t.releases = {
        title = "ms-love",
        version = "1.1.1",
        author = "Kurtsley",
        email = "kurtsley@gmail.com",
        description = "Minesweeper with Love",
    }
end
