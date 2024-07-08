MenuScene = Object:extend()

function MenuScene:new()
    self.avatar = love.graphics.newImage('assets/sprites/avatar.png')
end

function MenuScene:update(dt)
    if input:released('next_level') then
        gotoRoom('GameScene')
    end
end

function MenuScene:draw()
    love.graphics.setFont(FONT)
    love.graphics.draw(self.avatar, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 4, 0, 1, 1, self.avatar:getWidth() / 2, self.avatar:getHeight() / 2)

    local font = love.graphics.getFont()
    local fontHeight = font:getHeight()
    local startTxt = "Press 'n' to start"
    local startTxtWidth = font:getWidth(startTxt)

    local backTxt = "Press 'backspace' to return"
    local backTxtWidth = font:getWidth(backTxt)

    local controlTxt = "Press 'c' to go to the ControlScene"
    local controlTxtWidth = font:getWidth(controlTxt)

    love.graphics.print(startTxt,   SCREEN_WIDTH / 2, 350, 0, 1, 1, startTxtWidth   / 2, fontHeight / 2)
    love.graphics.print(backTxt,    SCREEN_WIDTH / 2, 450, 0, 1, 1, backTxtWidth    / 2, fontHeight / 2)
    love.graphics.print(controlTxt, SCREEN_WIDTH / 2, 550, 0, 1, 1, controlTxtWidth / 2, fontHeight / 2)
end