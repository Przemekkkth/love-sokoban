GameScene = Object:extend()

function GameScene:new()
    self.game = Game()
end

function GameScene:update(dt)
    self.game:update(dt)
end

function GameScene:draw()
    self.game:draw()
end