local data = {}

data.grid = {}
data.bomb_pos = {}
data.grid_revealed = {}
data.grid_flagged = {}
data.mines_left = 40
data.restart_game = false
data.win_audio_played = false

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
    data.grid = {}
    data.grid_revealed = {}
    data.grid_flagged = {}

    data.init_grids()
    data.restart_game = false

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
        until not seen[key] and (math.abs(x-grid_pos_x) > 2 or math.abs(y-grid_pos_y) > 2)
        seen[key] = true

        table.insert(data.bomb_pos, {x, y})
    end
end

function data.update(grid_x, grid_y, dig_area_audio, dig_audio, lose_audio)
    if data.grid[grid_x][grid_y] == 0 then
        data.clear_blanks(grid_x, grid_y, dig_area_audio)
    elseif data.grid[grid_x][grid_y] ~= 9 then
        love.audio.stop(dig_audio)
        love.audio.play(dig_audio)
        data.grid_revealed[grid_x][grid_y] = true
    elseif data.grid[grid_x][grid_y] == 9 then
        data.game_over = true
        love.audio.stop(lose_audio)
        love.audio.play(lose_audio)
    end

    return data.grid_revealed, data.game_over
end

function data.clear_blanks(grid_x, grid_y, dig_area_audio)    
    local available_grid = false
    local check_grids = {{grid_x, grid_y}}
    local current_grid_checking = check_grids[1]
    
    love.audio.play(dig_area_audio)

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

function data.change_flag_state(grid_x, grid_y, flag_audio)
    if not data.grid_revealed[grid_x][grid_y] or data.grid_flagged[grid_x][grid_y] then
        data.grid_flagged[grid_x][grid_y] = (data.grid_flagged[grid_x][grid_y] and {false} or {true})[1]
        love.audio.stop(flag_audio)
        love.audio.play(flag_audio)
    end

    return data.grid_flagged
end

function data.check_for_win(win_audio)
    local grids_revealed = 0
    for _, row in pairs(data.grid_revealed) do
        for _, tile in pairs(row) do
            if tile == true then
                grids_revealed = grids_revealed + 1
            end
        end
    end
    if grids_revealed >= 216 then
        if not data.win_audio_played then
            love.audio.play(win_audio)
            data.win_audio_played = true
        end
        return true
    else
        return false
    end
end

function data.draw()
    data.get_mines_left()

    love.graphics.setColor(0,0,0)
    love.graphics.print(data.mines_left, 144, 0)
    love.graphics.setColor(1,1,1)
end

function data.get_mines_left()
    data.mines_left = 40
    for _, flag_row in pairs(data.grid_flagged) do
        for _, flag in pairs(flag_row) do
            if flag == true then
                data.mines_left = data.mines_left - 1
            end
        end
    end
    if data.mines_left < 0 then
        data.mines_left = 0
    end
end

return data