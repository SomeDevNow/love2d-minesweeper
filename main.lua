
local resize = require "lib.resize"
local scale = resize:new(320, 320)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.update()

end

function love.draw()
    if scale then
        scale:draw_start()
    end
    love.graphics.rectangle("fill", 50, 50, 50, 50)

    if scale then
        scale:draw_end()
    end
end

function love.resize(w, h)
    if scale then
        scale:resize(w, h)
    end
end