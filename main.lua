
local resize = require "lib.resize"
local grid_info = require "src.grid_info"
local grid_draw = require "src.grid_draw"
local minesweper_spritesheet
local game_start = false
local restart_game_win = false
local restart_game_lose = false
local font
local dig_area_audio, dig_audio, lose_audio, flag_audio, win_audio
local WINDOW_WIDTH = 320
local WINDOW_HEIGHT = 320
local TO_RGB = 1/255

local scale = resize:new(WINDOW_WIDTH, WINDOW_HEIGHT)
local draw_grid

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    minesweper_spritesheet = love.graphics.newImage("assets/art/spritesheet.png")

    font = love.graphics.newFont("assets/fonts/monogram.ttf", 32)

    dig_area_audio = love.audio.newSource("assets/audio/dig-area.mp3", "static")
    dig_audio = love.audio.newSource("assets/audio/dig.mp3", "static")
    lose_audio = love.audio.newSource("assets/audio/lose.mp3", "static")
    flag_audio = love.audio.newSource("assets/audio/place-flag.mp3", "static")
    win_audio = love.audio.newSource("assets/audio/win.mp3", "static")

    dig_area_audio:setVolume(0.6)
    lose_audio:setVolume(0.4)

    grid_info.init_grids()
    draw_grid = grid_draw:new(grid_info, minesweper_spritesheet)
    draw_grid:set_grid_info(grid_info)

    if scale then scale:resize(love.graphics.getWidth(), love.graphics.getHeight()) end
end

function love.update()
    restart_game_win = grid_info.check_for_win(win_audio)
    if restart_game_win or restart_game_lose then
        local mouse_x, mouse_y = love.mouse.getPosition()
        local virtual_mouse_x, virtual_mouse_y = (mouse_x-scale:get_offset_x())/scale:get_scale(), (mouse_y-scale:get_offset_y())/scale:get_scale()
        
        if love.mouse.isDown(1) and virtual_mouse_x >= 144 and virtual_mouse_x <= 192 and virtual_mouse_y >= 144 and virtual_mouse_y <= 192 then
            restart()
        end
    end
end

function love.draw()
    if scale then scale:draw_start() end

    love.graphics.setFont(font)

    love.graphics.setColor(176*TO_RGB, 176*TO_RGB, 184*TO_RGB)
    love.graphics.rectangle("fill", 0, 0, 320, 320)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 28, 28, 264, 264)
    love.graphics.setColor(1, 1, 1)

    draw_grid:draw()

    if not restart_game_lose and not restart_game_win then
        grid_info.draw()
    end

    if restart_game_lose then
        draw_grid:draw_game_over()

        love.graphics.setColor(0,0,0,0.4)
        love.graphics.rectangle("fill", 0,0,320, 320)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 142, 146, 32, 32)
        love.graphics.setColor(1,1,1)

        love.graphics.draw(minesweper_spritesheet, love.graphics.newQuad(32, 32, 32, 32, minesweper_spritesheet), love.math.newTransform(144, 144))
    end

    if restart_game_win then
        draw_grid:draw_game_over()

        love.graphics.setColor(0,0,0,0.4)
        love.graphics.rectangle("fill", 0, 0, 320, 320)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 142, 162, 32, 32)
        love.graphics.setColor(1,1,1)
        
        love.graphics.setColor(0,0,0)
        love.graphics.print("You Win!", 74, 98, 0, 2, 2)
        love.graphics.setColor(1,1,1)
        love.graphics.print("You Win!", 76, 96, 0, 2, 2)

        love.graphics.draw(minesweper_spritesheet, love.graphics.newQuad(32, 32, 32, 32, minesweper_spritesheet), love.math.newTransform(144, 160))
    end

    if scale then scale:draw_end() end
end

function love.mousepressed(x, y, button)
    virtual_mouse_x, virtual_mouse_y = (x-scale:get_offset_x())/scale:get_scale(), (y-scale:get_offset_y())/scale:get_scale()
    local grid_pos = {x = math.floor(((virtual_mouse_x) - 16)/16), y = math.floor(((virtual_mouse_y) - 16)/16)}
    
    if not restart_game_win and not restart_game_lose then
        if grid_pos.x >= 1 and grid_pos.x <= 16 and grid_pos.y >= 1 and grid_pos.y <= 16 then
            if button == 1 then
                if not game_start then
                    if grid_pos.x >= 1 and grid_pos.x <= 16 and grid_pos.y >= 1 and grid_pos.y <= 16 then
                        draw_grid:start()

                        grid_info.grid = grid_info.init(grid_pos.x, grid_pos.y)
                        grid_info.clear_blanks(grid_pos.x, grid_pos.y, dig_area_audio)
                        draw_grid:set_grid_info(grid_info)

                        game_start = true
                    end
                elseif game_start then
                    grid_info.grid_revealed, restart_game_lose = grid_info.update(grid_pos.x, grid_pos.y, dig_area_audio, dig_audio, lose_audio)
                end
            elseif button == 2 then
                grid_info.grid_flagged = grid_info.change_flag_state(grid_pos.x, grid_pos.y, flag_audio)
            end
        end
    end

    if restart_game_win or restart_game_lose then
        if button == 1 and virtual_mouse_x >= 144 and virtual_mouse_x <= 192 and virtual_mouse_y >= 144 and virtual_mouse_y <= 192 then
            restart()
        end
    end
    draw_grid:set_grid_info(grid_info)
end

function love.resize(w, h)
    if scale then scale:resize(w, h) end
end

function restart()
    grid_info.init_grids()
    draw_grid:set_grid_info(grid_info)
    draw_grid:restart()
    grid_info.game_over = false
    grid_info.win_audio_played = false
    restart_game_win = false
    restart_game_lose = false
    game_start = false
end