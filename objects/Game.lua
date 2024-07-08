Game = Object:extend()

function Game:new()
    self.player = '@'
    self.playerOnStorage = '+'
    self.box = '$'
    self.boxOnStorage = '*'
    self.storage = '.'
    self.wall = '#'
    self.empty = ' '

    self.currentLevel = 1
    self.level = nil
    self.levelMaxHeight = 0
    self.levelMaxWidth = 0
    self.levels = nil
    self.offsetX = 0
    self.offsetY = 0
    self.cellSize = 64
    self.direction = 'down'
    self.moves = 0

    self.bgImg = nil
    self.groundImg = nil
    self.wallImg = nil
    self.boxImg = nil
    self.storageBoxImg = nil

    self.nextLvlSFX = love.audio.newSource("assets/sfx/nextLvl.wav", "static")
    self.nextLvlSFX:setVolume(0.5)

    self.storageBoxSFX = love.audio.newSource("assets/sfx/storageBox.wav", "static")
    self.storageBoxSFX:setVolume(0.5)

    if love.filesystem.getInfo("assets/levels/lvl.txt") then
        local file = love.filesystem.read("assets/levels/lvl.txt")
        self.levels = split(file, "=")
    end

    self:loadLevel()
end

function Game:update(dt)
    self:handlePlayerInput()
    STORAGE_ANIM:update(dt)
end

function Game:draw()
    self:drawBG()
    for y, v in ipairs(self.level) do
        for x = 1, #v do
            self:drawObject(x - 1 + self.offsetX, y - 1 + self.offsetY, string.sub(v, x, x))
        end
    end
    self:drawStats()
end

function Game:handlePlayerInput()
    if input:released('right_arrow') or input:released('left_arrow') or input:released('up_arrow') or input:released('down_arrow') then
        local playerX
        local playerY
        
        for y, v in ipairs(self.level) do
            for x = 1, #v do
                if string.sub(v, x, x) == self.player or string.sub(v, x, x) == self.playerOnStorage then
                    playerX = x
                    playerY = y
                    break
                end
            end
        end

        local dx = 0
        local dy = 0
        if input:released('left_arrow') then
            dx = -1
            self.direction = 'left'
        elseif input:released('right_arrow') then
            dx = 1
            self.direction = 'right'
        elseif input:released('up_arrow') then
            dy = -1
            self.direction = 'up'
        elseif input:released('down_arrow') then
            dy = 1
            self.direction = 'down'
        end

        local current = self.level[playerY]:sub(playerX, playerX)
        --    current = self.level[player][playerX]
        local adjacent = self.level[playerY + dy]:sub(playerX + dx, playerX + dx)
        --    adjacent = self.level[playerY + dy][playerX + dx]

        local beyond 
        if self.level[playerY + dy + dy] then
            beyond = self.level[playerY + dy + dy]:sub(playerX + dx + dx, playerX + dx + dx)
            --beyond = self.level[playerY + dy + dy][playerX + dx + dx]
        end

        local nextAdjacent = {
            [self.empty] = self.player,
            [self.storage] = self.playerOnStorage,
        }
        
        local nextCurrent = {
            [self.player] = self.empty,
            [self.playerOnStorage] = self.storage,
        }
        
        local nextBeyond = {
            [self.empty] = self.box,
            [self.storage] = self.boxOnStorage,
        }
        
        local nextAdjacentPush = {
            [self.box] = self.player,
            [self.boxOnStorage] = self.playerOnStorage,
        }        

        if nextAdjacent[adjacent] then
            self.level[playerY] = self.level[playerY]:sub(1, playerX - 1) .. nextCurrent[current] .. self.level[playerY]:sub(playerX + 1)
            --self.level[playerY] = self.level[playerY][1 .. playerX - 1] + nextCurrent[current] + self.level[playerY][playerX + 1 .. end]
            self.level[playerY + dy] = self.level[playerY + dy]:sub(1, playerX + dx - 1) .. nextAdjacent[adjacent] .. self.level[playerY + dy]:sub(playerX + dx + 1)
            --self.level[playerY + dy] = self.level[playerY + dy][1 .. playerX + dx - 1] + nextAdjacent[adjacent] + self.level[playerY + dy][playerX + dx + 1 .. end]
            self.moves = self.moves + 1
        elseif nextBeyond[beyond] and nextAdjacentPush[adjacent] then
            self.level[playerY] = self.level[playerY]:sub(1, playerX - 1) .. nextCurrent[current] .. self.level[playerY]:sub(playerX + 1)
            self.level[playerY + dy] = self.level[playerY + dy]:sub(1, playerX + dx - 1) .. nextAdjacentPush[adjacent] .. self.level[playerY + dy]:sub(playerX + dx + 1)
            self.level[playerY + dy + dy] = self.level[playerY + dy + dy]:sub(1, playerX + dx + dx - 1) .. nextBeyond[beyond] .. self.level[playerY + dy + dy]:sub(playerX + dx + dx + 1)
            self.moves = self.moves + 1
            self.storageBoxSFX:stop()
            self.storageBoxSFX:play()
        end
        
        local complete = true
        for y, v in ipairs(self.level) do
            for x = 1, #v do
                if string.sub(v, x, x) == self.box then
                    complete = false
                end
            end
        end

        if complete then
            self.nextLvlSFX:play()
            self:nextLevel()
        end
    end

    if input:released('restart') then
        self:restartLevel()
    elseif input:released('next_level') then
        self:nextLevel()
    elseif input:released('previous_level') then
        self:previousLevel()
    end
end

function Game:loadLevel()
    self.level = split(self.levels[self.currentLevel], "\r\n")
    self.direction = 'down'
    self.levelMaxHeight = #self.level
    self.cellSize = 64
    local levelMaxWidth = 0
    for y, v in ipairs(self.level) do
        if #v > levelMaxWidth then
            levelMaxWidth = #v
        end
    end
    self.levelMaxWidth = levelMaxWidth
    if self.levelMaxHeight > 12 then
        self.cellSize = 32
    elseif self.levelMaxWidth > 16 then
        self.cellSize = 32
    end

    local cellsWidth = SCREEN_WIDTH / self.cellSize
    local cellHeight = SCREEN_HEIGHT / self.cellSize
    if cellsWidth - self.levelMaxWidth > 0 then
        self.offsetX = (cellsWidth - self.levelMaxWidth) / 2
    else
        self.offsetX = 0
    end
    
    if cellHeight - self.levelMaxHeight > 0 then
        self.offsetY = (cellHeight - self.levelMaxHeight) / 2
    else
        self.offsetY = 0
    end

    self.moves = 0
    self:chooseTileset()
end

function Game:drawBG()
    local cellsWidth = SCREEN_WIDTH / self.cellSize
    local cellHeight = SCREEN_HEIGHT / self.cellSize
    for x = 1, cellsWidth do
        for y = 1, cellHeight do
            love.graphics.draw(SPRITESHEET_IMG, self.bgImg, (x - 1) * self.cellSize, (y - 1) * self.cellSize, 0, self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
        end
    end
end

function Game:drawObject(x, y, object)
    love.graphics.draw(SPRITESHEET_IMG, self.groundImg, x * self.cellSize, y * self.cellSize, 0, self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)

    if object == self.player then
        self:drawPlayer(x, y)
    elseif object == self.playerOnStorage then
        self:drawPlayerOnStorage(x, y)
    elseif object == self.box then
        self:drawBox(x, y)
    elseif object == self.boxOnStorage then
        self:drawBoxStorageOnBox(x, y)
    elseif object == self.storage then
        self:drawStorage(x, y)
    elseif object == self.wall then
        self:drawWall(x, y)
    elseif object == self.empty then
        self:drawGround(x, y)
    end
    
end

function Game:drawBox(x, y)
    love.graphics.draw(SPRITESHEET_IMG, self.boxImg, x * self.cellSize, y * self.cellSize, 0, self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
end

function Game:drawBoxStorageOnBox(x, y)
    love.graphics.draw(SPRITESHEET_IMG, self.storageBoxImg, x * self.cellSize, y * self.cellSize, 0, self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
end

function Game:drawPlayer(x, y) 
    if self.direction == "up" then
        love.graphics.draw(SPRITESHEET_IMG, PLAYER_UP_IMG, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
    elseif self.direction == "down" then
        love.graphics.draw(SPRITESHEET_IMG, PLAYER_DOWN_IMG, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
    elseif self.direction == "left" then
        love.graphics.draw(SPRITESHEET_IMG, PLAYER_LEFT_IMG, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
    elseif self.direction == "right" then
        love.graphics.draw(SPRITESHEET_IMG, PLAYER_RIGHT_IMG, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
    end
end

function Game:drawStorage(x, y) 
    STORAGE_ANIM:draw(SPRITESHEET_IMG, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
end

function Game:drawPlayerOnStorage(x, y)
    self:drawStorage(x, y)
    self:drawPlayer(x, y)
end

function Game:drawWall(x, y)
    love.graphics.draw(SPRITESHEET_IMG, self.wallImg, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
end

function Game:drawGround(x, y)
    love.graphics.draw(SPRITESHEET_IMG, self.groundImg, x * self.cellSize, y * self.cellSize, 0,  self.cellSize / IMAGE_SIZE, self.cellSize / IMAGE_SIZE)
end

function Game:drawStats()
    love.graphics.setFont(FONT)
    local font = love.graphics.getFont()
    local fontHeight = font:getHeight()
    local lvlTxt = tostring(self.currentLevel).." / "..tostring(#self.levels).." level "
    local lvlTxtWidth = font:getWidth(lvlTxt)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print(lvlTxt, SCREEN_WIDTH, 0, 0, 1, 1, lvlTxtWidth)

    local moveTxt = "Moves: "..tostring(self.moves)
    local moveTxtWidth = font:getWidth(moveTxt)
    love.graphics.print(moveTxt, SCREEN_WIDTH, 40, 0, 1, 1, moveTxtWidth, 0)

    love.graphics.setColor(1, 1, 1)
end

function Game:nextLevel()
    self.currentLevel = self.currentLevel + 1
    if self.currentLevel > #self.levels then
        self.currentLevel = 1
    end
    self:loadLevel()
end

function Game:previousLevel()
    self.currentLevel = self.currentLevel - 1
    if self.currentLevel < 1 then
        self.currentLevel = #self.levels
    end
    self:loadLevel()
end

function Game:restartLevel()
    self:loadLevel()
end

function Game:chooseTileset() 
    if self.currentLevel < 25 then
        self.bgImg = BG0_IMG
        self.groundImg = GROUND0_IMG
        self.wallImg = WALL0_IMG
        self.boxImg = BOX0_IMG
        self.storageBoxImg = BOX6_IMG
    elseif self.currentLevel >= 25 and self.currentLevel < 50 then
        self.bgImg = BG1_IMG
        self.groundImg = GROUND1_IMG
        self.wallImg = WALL1_IMG
        self.boxImg = BOX1_IMG
        self.storageBoxImg = BOX7_IMG
    elseif self.currentLevel >= 50 and self.currentLevel < 75 then
        self.bgImg = BG2_IMG
        self.groundImg = GROUND2_IMG
        self.wallImg = WALL2_IMG
        self.boxImg = BOX2_IMG
        self.storageBoxImg = BOX8_IMG
    else
        self.bgImg = BG3_IMG
        self.groundImg = GROUND3_IMG
        self.wallImg = WALL3_IMG
        self.boxImg = BOX4_IMG
        self.storageBoxImg = BOX9_IMG        
    end
end