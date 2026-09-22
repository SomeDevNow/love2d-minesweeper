local resize = require "lib.resize"
local grid_info = require "src.grid_info"
local grid_draw = require "src.grid_draw"
local WINDOW_WIDTH = 320
local WINDOW_HEIGHT = 320
local TO_RGB = 1/255

local scale = resize:new(WINDOW_WIDTH, WINDOW_HEIGHT)
local grid = grid_info.init()
local draw_grid

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    draw_grid = grid_draw:new(grid, love.graphics.newImage("assets/spritesheet.png"))
    if scale then scale:resize(love.graphics.getWidth(), love.graphics.getHeight()) end
end

function love.update()

end

function love.draw()
    if scale then scale:draw_start() end

    love.graphics.setColor(176*TO_RGB, 176*TO_RGB, 184*TO_RGB)
    love.graphics.rectangle("fill", 0, 0, 320, 320)
    love.graphics.setColor(1,1,1)
    draw_grid:draw()

    if scale then scale:draw_end() end
end

function love.resize(w, h)
    if scale then scale:resize(w, h) end
end