function love.load()
    Object = require 'libraries/classic'
    Input = require 'libraries/boipushy/Input'
    Timer = require 'libraries/hump/timer'
    anim8 = require 'libraries/anim8'
    require 'utils/Utils'
    require 'utils/Spritesheet'

    input = Input()
    input:bind('left', 'left_arrow')
    input:bind('right', 'right_arrow')
    input:bind('up', 'up_arrow')
    input:bind('down', 'down_arrow')
    input:bind('escape', 'escape')
    input:bind('r', 'restart')
    input:bind('n', 'next_level')
    input:bind('b', 'previous_level')
    input:bind('m', "mute")
    input:bind('c', 'go_to_control_scene')
    input:bind('backspace', 'go_to_menu_scene')

    SCREEN_WIDTH = love.graphics.getWidth()
    SCREEN_HEIGHT = love.graphics.getHeight()
    FONT = love.graphics.newFont("assets/fonts/juniory.ttf", 36)
    MUSIC = love.audio.newSource("assets/music/music_level_sokoban.wav", "stream")
    MUSIC:setVolume(0.25)
    MUSIC:setLooping(true)
    MUSIC:play()

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local object_files = {}
    recursiveEnumerate('rooms', object_files)
    requireFiles(object_files)

    current_room = nil
    gotoRoom('MenuScene')
end

function love.update(dt)
    if current_room then current_room:update(dt) end

    if input:released('escape') then 
        love.event.quit()
    elseif input:released('mute') then
        if MUSIC:getVolume() == 0.25 then
            MUSIC:setVolume(0.0)
        else
            MUSIC:setVolume(0.25)
        end
    elseif input:released('go_to_control_scene') then
        gotoRoom('ControlScene')
    elseif input:released('go_to_menu_scene') then 
        gotoRoom('MenuScene')
    end
end

function love.draw()
    if current_room then current_room:draw() end
end

-- Room --
function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end

-- Load --
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == "file" then
            table.insert(file_list, file)
        elseif fileInfo.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end
