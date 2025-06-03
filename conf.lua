-- Conf file
function love.conf(t)
    t.window.title = "MS"
    t.window.icon = "assets/icons/icon-small.png"
    t.window.width = 288
    t.window.height = 352
    t.modules.joystick = false
    t.modules.physics = false

    t.releases = {
        title = "ms-love",
        version = "1.0.0",
        author = "Kurtsley",
        email = "kurtsley@gmail.com",
        description = "Minesweeper with Love",
        homepage = "www.example.com",
    }
end
