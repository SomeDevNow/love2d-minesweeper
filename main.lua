
local resize = require "lib.resize"
local WINDOW_WIDTH <const> = 320
local WINDOW_HEIGHT <const> = 320
local scale = resize:new(WINDOW_WIDTH, WINDOW_HEIGHT)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    if scale then scale:resize(love.graphics.getWidth(), love.graphics.getHeight()) end
end

function love.update()

end

function love.draw()
    if scale then scale:draw_start() end
    love.graphics.rectangle("fill", 0, 0, 50, 50)

    if scale then scale:draw_end() end
end

function love.resize(w, h)
    if scale then scale:resize(w, h) end
end