local data = {}

data.grid = {}
data.bomb_pos = {}

function data.new_bomb_pos()
    data.bomb_pos = {}
    local seen = {}

    for i = 1, 40 do
        local x, y
        local key

        repeat
            x = love.math.random(1, 16)
            y = love.math.random(1, 16)
            key = x .. "," .. y
        until not seen[key]
        seen[key] = true

        table.insert(data.bomb_pos, {x, y})
    end
end

function data.init()
    data.grid = {}
    data.new_bomb_pos()

    for i = 1, 16 do
        table.insert(data.grid, {})
        for j = 1, 16 do
            table.insert(data.grid[i], 0)
        end
    end

    for _, pos in pairs(data.bomb_pos) do
        data.grid[pos[1]][pos[2]] = 9
    end

    for x = 1, 16 do
        for y = 1, 16 do
            if data.grid[x][y] ~= 9 then
                local bombs_nearby = 0

                for rx = -1, 1 do
                    for ry = -1, 1 do
                        if not (rx == 0 and ry == 0) then
                            local cx = x-rx
                            local cy = y-ry
                            if cy >= 1 and cy <= 16 and cx >= 1 and cx <= 16 then
                                if data.grid[cx][cy] == 9 then
                                    bombs_nearby = bombs_nearby + 1
                                end
                            end
                        end
                    end
                end
                data.grid[x][y] = bombs_nearby
            end
        end
    end
    return data.grid
end

return data