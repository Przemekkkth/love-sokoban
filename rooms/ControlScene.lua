ControlScene = Object:extend()

function ControlScene:new()
end

function ControlScene:update(dt)

end

function ControlScene:draw()
    love.graphics.setFont(FONT)
    local font = love.graphics.getFont()
    local fontHeight = font:getHeight()
    local title = "Controls"
    love.graphics.print(title, SCREEN_WIDTH / 2, 50, 0, 1, 1, font:getWidth(title) / 2, font:getHeight(title) / 2)

    love.graphics.print("left arrow - move left",       20, 100)
    love.graphics.print("right arrow - move right",     20, 150)
    love.graphics.print("up arrow - move up",           20, 200)
    love.graphics.print("down arrow - move down",       20, 250)
    love.graphics.print("down arrow - move down",       20, 250)
    love.graphics.print("r - restart level",            20, 300)
    love.graphics.print("n - next level",               20, 350)
    love.graphics.print("p - previous level",           20, 400)
    love.graphics.print("backspace - go to menu scene", 20, 450)
    love.graphics.print("c - go to control scene",      20, 500)
    love.graphics.print("m - mute/unmute music",        20, 550)
    love.graphics.print("escape - quit game",           20, 600)

    local backTxt = "Press 'backspace' to return"
    love.graphics.print(backTxt, SCREEN_WIDTH / 2, 650, 0, 1, 1, font:getWidth(backTxt) / 2, font:getHeight(backTxt) / 2)
end