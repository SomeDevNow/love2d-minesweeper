local resize = require "lib.resize"
local grid_info = require "src.grid_info"
local grid_draw = require "src.grid_draw"
local game_start = false
local WINDOW_WIDTH = 320
local WINDOW_HEIGHT = 320
local TO_RGB = 1/255

local scale = resize:new(WINDOW_WIDTH, WINDOW_HEIGHT)
local draw_grid

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    grid_info.init_grids()
    draw_grid = grid_draw:new(grid_info, love.graphics.newImage("assets/spritesheet.png"))

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
    love.graphics.setColor(1,1,1)
    draw_grid:draw()

    if scale then scale:draw_end() end
end

function love.resize(w, h)
    if scale then scale:resize(w, h) end
end

function love.mousepressed(x, y, button)
    local mouse_pos_x, mouse_pos_y = x, y
    local grid_pos = {x = math.floor((((mouse_pos_x-scale:get_offset_x())/scale:get_scale()) - 16)/16), y = math.floor((((mouse_pos_y-scale:get_offset_y())/scale:get_scale()) - 16)/16)}
    if button == 1 then
        if not game_start then
            if grid_pos.x >= 1 and grid_pos.x <= 16 and grid_pos.y >= 1 and grid_pos.y <= 16 then
                draw_grid:update()
                grid_info.grid = grid_info.init(grid_pos.x, grid_pos.y)
                grid_info.clear_blanks(grid_pos.x, grid_pos.y)
                game_start = true
            end
        elseif game_start then
            grid_info.grid_revealed = grid_info.update(grid_pos.x, grid_pos.y)
        end
    end
    if button == 2 then
        grid_info.grid_flagged = grid_info.flag_grid(grid_pos.x, grid_pos.y)
    end
    draw_grid:set_grid_info(grid_info)
end