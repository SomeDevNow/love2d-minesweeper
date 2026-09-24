local grid_draw = {}
grid_draw.__index = grid_draw

function grid_draw:new(grid_info, spritesheet)
    local instance = {
        grid_info = grid_info,
        grid_init = false,
        grid_pos = nil,
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

function grid_draw:update()
    self.grid_init = true
end

function grid_draw:draw()
    if not self.grid_init then
        for x = 1, 16 do
            for y = 1, 16 do
                love.graphics.draw(self.spritesheet, self.quads[1], love.math.newTransform(32+(x-1)*16, 32+(y-1)*16))
            end
        end
    elseif self.grid_init then
        for x = 1, 16 do
            for y = 1, 16 do
                if self.grid_info.grid_flagged[x][y] then
                    love.graphics.draw(self.spritesheet, self.quads[12],love.math.newTransform(32+(x-1)*16, 32+(y-1)*16))
                elseif self.grid_info.grid_revealed[x][y] then
                    local tile = self.grid_info.grid[x][y]
                    love.graphics.draw(self.spritesheet, self.quads[tile+2],love.math.newTransform(32+(x-1)*16, 32+(y-1)*16))
                else
                    love.graphics.draw(self.spritesheet, self.quads[1], love.math.newTransform(32+(x-1)*16, 32+(y-1)*16))
                end
            end
        end
    end
end

function grid_draw:get_grid_init() return self.grid_init end
function grid_draw:set_grid_info(val) self.grid_info = val end

return grid_draw