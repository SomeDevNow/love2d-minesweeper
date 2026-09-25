local data = {}

data.grid = {}
data.bomb_pos = {}
data.grid_revealed = {}
data.grid_flagged = {}
data.game_over = false

function data.init_grids()
    data.grid = {}
    data.grid_revealed = {}
    data.grid_flagged = {}

    for i = 1, 16 do
        table.insert(data.grid, {})
        for j = 1, 16 do
            table.insert(data.grid[i], 0)
        end
    end

    for i = 1, 16 do
        table.insert(data.grid_revealed, {})
        for j = 1, 16 do
            table.insert(data.grid_revealed[i], false)
        end
    end

    for i = 1, 16 do
        table.insert(data.grid_flagged, {})
        for j = 1, 16 do
            table.insert(data.grid_flagged[i], false)
        end
    end

    data.bomb_pos = {}
end

function data.init(grid_pos_x, grid_pos_y)
    data.game_over = false

    new_bomb_pos(grid_pos_x, grid_pos_y)

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

function data.update(grid_x, grid_y)
    if data.grid[grid_x][grid_y] == 0 then
        data.clear_blanks(grid_x, grid_y)
    elseif data.grid[grid_x][grid_y] ~= 9 then
        data.grid_revealed[grid_x][grid_y] = true
    elseif data.grid[grid_x][grid_y] == 9 then
        data.game_over = true
    end

    return data.grid_revealed, data.game_over
end

function data.clear_blanks(grid_x, grid_y)
    local available_grid = false
    local check_grids = {{grid_x, grid_y}}
    local current_grid_checking = check_grids[1]
    
    repeat
        available_grid = false
        for i=1, #check_grids do
            for rx = -1, 1 do
                for ry = -1, 1 do
                    current_grid_checking = check_grids[i]
                    local cx, cy = current_grid_checking[1]-rx, current_grid_checking[2]-ry

                    if cx >= 1 and cx <= 16 and cy >= 1 and cy <= 16 and not data.grid_revealed[cx][cy] then
                        if data.grid[cx][cy] == 0 then
                            data.grid_revealed[cx][cy] = true
                            available_grid = true
                            table.insert(check_grids, {cx, cy})
                        end
                    end
                end
            end
        end
    until not available_grid

    for i=1, #check_grids do
        for rx = -1, 1 do
            for ry = -1, 1 do
                current_grid_checking = check_grids[i]
                local cx, cy = current_grid_checking[1]-rx, current_grid_checking[2]-ry

                if cx >= 1 and cx <= 16 and cy >= 1 and cy <= 16 and not data.grid_revealed[cx][cy] then
                    data.grid_revealed[cx][cy] = true
                end
            end
        end
    end
    return data.grid_revealed
end

function data.change_flag_state(grid_x, grid_y)
    if not data.grid_revealed[grid_x][grid_y] or data.grid_flagged[grid_x][grid_y] then
        data.grid_flagged[grid_x][grid_y] = (data.grid_flagged[grid_x][grid_y] and {false} or {true})[1]
    end
    return data.grid_flagged
end

function new_bomb_pos(grid_pos_x, grid_pos_y)
    data.bomb_pos = {}
    local seen = {}

    for i = 1, 40 do
        local x, y
        local key

        repeat
            x = love.math.random(1, 16)
            y = love.math.random(1, 16)
            key = x .. "," .. y
        until not seen[key] and math.abs(x-grid_pos_x) > 2 or math.abs(y-grid_pos_y) > 2
        seen[key] = true

        table.insert(data.bomb_pos, {x, y})
    end
end

return data