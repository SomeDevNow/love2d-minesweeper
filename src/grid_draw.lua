local grid_draw = {}
grid_draw.__index = grid_draw

function grid_draw:new(grid_info, spritesheet)
    local instance = {
        grid = grid_info,
        spritesheet = spritesheet,
        quads = {},
    }

    for i = 1, 4 do
        for j = 1, 4 do
            table.insert(instance.quads, love.graphics.newQuad((j-1)* 16, (i-1) * 16, 16, 16, 64, 64))
        end
    end

    local self = setmetatable(instance, grid_draw)
    return self
end

function grid_draw:draw()
    for x = 1, 16 do
        for y = 1, 16 do
            local tile = self.grid[x][y]
            love.graphics.draw(self.spritesheet, self.quads[tile+2],love.math.newTransform(32+(x-1)*16, 32+(x-1)*16))
        end
    end
end

return grid_draw