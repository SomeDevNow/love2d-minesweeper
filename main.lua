local resize = require "lib.resize"
local grid_info = require "src.grid_info"
local grid_draw = require "src.grid_draw"
local minesweper_spritesheet
local game_start = false
local restart_game = true
local WINDOW_WIDTH = 320
local WINDOW_HEIGHT = 320
local TO_RGB = 1/255

local scale = resize:new(WINDOW_WIDTH, WINDOW_HEIGHT)
local draw_grid

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    minesweper_spritesheet = love.graphics.newImage("assets/spritesheet.png")

    grid_info.init_grids()
    draw_grid = grid_draw:new(grid_info, love.graphics.newImage("assets/spritesheet.png"))
    draw_grid:set_grid_info(grid_info)

    if scale then scale:resize(love.graphics.getWidth(), love.graphics.getHeight()) end
end

function love.update()
    
end

function love.draw()
    if scale then scale:draw_start() end

    love.graphics.setColor(176*TO_RGB, 176*TO_RGB, 184*TO_RGB)
    love.graphics.rectangle("fill", 0, 0, 320, 320)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 28, 28, 264, 264)
    love.graphics.setColor(1, 1, 1)

    draw_grid:draw()

    if restart_game then
        love.graphics.setColor(0,0,0,0.4)
        love.graphics.rectangle("fill", 0,0,320, 320)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 142, 146, 32, 32)
        love.graphics.setColor(1,1,1)

        love.graphics.draw(minesweper_spritesheet, love.graphics.newQuad(32, 32, 32, 32, minesweper_spritesheet), love.math.newTransform(144, 144))
    end

    if scale then scale:draw_end() end
end

function love.resize(w, h)
    if scale then scale:resize(w, h) end
end

function love.mousepressed(x, y, button)
    virtual_mouse_x, virtual_mouse_y = (x-scale:get_offset_x())/scale:get_scale(), (y-scale:get_offset_y())/scale:get_scale()
    local grid_pos = {x = math.floor(((virtual_mouse_x) - 16)/16), y = math.floor(((virtual_mouse_y) - 16)/16)}
    
    if not restart_game then
        if grid_pos.x >= 1 and grid_pos.x <= 16 and grid_pos.y >= 1 and grid_pos.y <= 16 then
            if button == 1 then
                if not game_start then
                    if grid_pos.x >= 1 and grid_pos.x <= 16 and grid_pos.y >= 1 and grid_pos.y <= 16 then
                        draw_grid:start()

                        grid_info.grid = grid_info.init(grid_pos.x, grid_pos.y)
                        grid_info.clear_blanks(grid_pos.x, grid_pos.y)

                        game_start = true
                    end
                elseif game_start then
                    grid_info.grid_revealed, restart_game = grid_info.update(grid_pos.x, grid_pos.y)
                end
            elseif button == 2 then
                grid_info.grid_flagged = grid_info.change_flag_state(grid_pos.x, grid_pos.y)
            end
        end
    end

    if restart_game then
        if button == 1 and virtual_mouse_x >= 144 and virtual_mouse_x <= 192 and virtual_mouse_y >= 144 and virtual_mouse_y <= 192 then
            restart()
        end
    end
    draw_grid:set_grid_info(grid_info)
end

function restart()
    grid_info.init_grids()
    draw_grid:set_grid_info(grid_info)
    draw_grid:restart()
    restart_game = false
    game_start = false
end