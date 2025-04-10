require("menu")
require("survey")
require("pause")
require("animation")
require("wire_game")
require("mounting")

-- Global game state
GameState = "menu" -- Possible states: "menu", "pause", "survey", "level1", "level2", "level3", "wire_game", "game_over"

-- Global variables for your unpacking/inspection/assembly phases
local background = nil
local box = {
    x = 400, y = 400,
    closed_img = nil,
    open_img = nil,
    state = "closed"
}

local items = {
    {name = "Solar Panels", img = nil, x = 0, y = 0, spawned = false, target_x = 200, target_y = 150, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false},
    {name = "Charge Controller", img = nil, x = 0, y = 0, spawned = false, target_x = 350, target_y = 150, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false},
    {name = "Battery Storage", img = nil, x = 0, y = 0, spawned = false, target_x = 600, target_y = 350, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false},
    {name = "Inverter", img = nil, x = 0, y = 0, spawned = false, target_x = 500, target_y = 450, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false},
    {name = "Wiring", img = nil, x = 0, y = 0, spawned = false, target_x = 300, target_y = 450, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false},
    {name = "Mounting Hardware", img = nil, x = 0, y = 0, spawned = false, target_x = 200, target_y = 350, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0, checked = false}
}

local current_item = 1
local timer = 0
local unpacking = false
local done = false
local level2_complete = false

-- Window dimensions
local window_width = 800
local window_height = 600

-- Scaling factor for items
local scale = 4

-- Scaling factor for the player in Levels 1-3
local player_scale = 2

-- Inspection and replacement radius
local inspection_radius = 50

-- Flash effect duration
local flash_duration = 0.5

-- Font for the checklist
local checklist_font = nil
PressStartFont = nil
ProggyTiny = nil

function love.load()
    -- Set nearest-neighbor filter to prevent blurry scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Load fonts with error handling
    local success, font = pcall(love.graphics.newFont, "assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 20)
    if success and font then
        PressStartFont = font
    else
        error("Failed to load PressStartFont: assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")
    end

    success, font = pcall(love.graphics.newFont, "assets/fonts/proggy-tiny/ProggyTiny.ttf", 28)
    if success and font then
        ProggyTiny = font
    else
        error("Failed to load ProggyTiny: assets/fonts/proggy-tiny/ProggyTiny.ttf")
    end

    success, font = pcall(love.graphics.newFont, "assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 12)
    if success and font then
        checklist_font = font
    else
        error("Failed to load checklist_font: assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")
    end

    love.graphics.setFont(PressStartFont)

    -- Load modules
    Menu:load()
    Pause:load()
    Survey:load()
    Animation:load()
    WireGame:load()
    Mounting:load()

    -- Load assets for unpacking/inspection/assembly
    love.window.setMode(window_width, window_height)

    -- Load background
    local success, result = pcall(love.graphics.newImage, "assets/courtyard.png")
    if success then
        background = result
    else
        background = nil
    end

    -- Load box images
    local success, result = pcall(love.graphics.newImage, "assets/box_closed.png")
    if success then
        box.closed_img = result
    end

    success, result = pcall(love.graphics.newImage, "assets/box_open.png")
    if success then
        box.open_img = result
    end

    -- Load item images
    local item_files = {
        "assets/solar_panel.png",
        "assets/charge_controller.png",
        "assets/battery.png",
        "assets/inverter.png",
        "assets/wiring.png",
        "assets/hardware.png"
    }

    for i, file in ipairs(item_files) do
        local success, result = pcall(love.graphics.newImage, file)
        if success then
            items[i].img = result
        else
            items[i].img = nil
        end
    end

    -- Check if critical images are loaded
    if not box.closed_img or not box.open_img then
        error("Cannot start game: Missing box images.")
    end

    -- Randomly determine if items are damaged
    for _, item in ipairs(items) do
        item.is_damaged = math.random() < 0.3
    end

    -- Set a larger font size for general text
    love.graphics.setNewFont(14)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function love.update(dt)
    if GameState == "menu" then
        Menu:update(dt)
    elseif GameState == "pause" then
        Pause:update(dt)
    elseif GameState == "survey" then
        Survey:update(dt)
    elseif GameState == "level1" then
        Animation:update(dt)
        if unpacking and not done then
            timer = timer + dt
            if timer >= 0.5 and current_item <= #items then
                local item = items[current_item]
                if not item.spawned then
                    item.x = box.x
                    item.y = box.y - 30
                    item.spawned = true
                    item.state = "popping"
                    item.velocity = -150
                else
                    if item.state == "popping" then
                        item.y = item.y + item.velocity * dt
                        item.velocity = item.velocity + 400 * dt
                        if item.y >= box.y + 60 then
                            item.state = "moving"
                            item.move_timer = 0
                        end
                    elseif item.state == "moving" then
                        item.move_timer = item.move_timer + dt
                        local t = math.min(item.move_timer / 0.5, 1)
                        item.x = lerp(item.x, item.target_x, t)
                        item.y = lerp(item.y, item.target_y, t)
                        if item.img then
                            local img_width = item.img:getWidth() * scale
                            local img_height = item.img:getHeight() * scale
                            item.x = math.max(img_width / 2, math.min(item.x, window_width - img_width / 2))
                            item.y = math.max(img_height / 2, math.min(item.y, window_height - img_height / 2))
                        end
                        if t >= 1 then
                            item.state = "done"
                            current_item = current_item + 1
                            timer = 0
                        end
                    end
                end
            elseif current_item > #items then
                done = true
                GameState = "level2"
            end
        end
    elseif GameState == "level2" then
        Animation:update(dt)
        for _, item in ipairs(items) do
            if item.flash_timer > 0 then
                item.flash_timer = item.flash_timer - dt
            end
        end
        local all_inspected_and_fixed = true
        for _, item in ipairs(items) do
            if not item.inspected then
                all_inspected_and_fixed = false
                break
            end
            if item.is_damaged and not item.replaced then
                all_inspected_and_fixed = false
                break
            end
        end
        if all_inspected_and_fixed then
            level2_complete = true
            GameState = "mounting"
        end
    elseif GameState == "level3" then
        Animation:update(dt)
        -- Placeholder for assembly logic
    elseif GameState == "mounting" then
        Mounting:update(dt)
    elseif GameState == "wire_game" then
        WireGame:update(dt)
        if WireGame.completed then
            GameState = "game_over"
        end
    end
end

function love.draw()
    if GameState == "menu" then
        Menu:draw()
    elseif GameState == "pause" then
        Pause:draw()
    elseif GameState == "survey" then
        Survey:draw()
    elseif GameState == "level1" or GameState == "level2" then
        -- Draw background
        if not background then
            love.graphics.setColor(0.6, 0.4, 0.2)
            love.graphics.rectangle("fill", 0, window_height / 2, window_width, window_height / 2)
            love.graphics.setColor(0.9, 0.8, 0.7)
            love.graphics.rectangle("fill", 0, 0, window_width, window_height / 2)
            love.graphics.setColor(0.2, 0.2, 0.6)
            love.graphics.rectangle("fill", window_width / 2 - 80, 40, 160, 120)
            love.graphics.setColor(0.4, 0.2, 0.1)
            love.graphics.rectangle("fill", window_width / 2 - 160, window_height / 2 + 40, 320, 40)
            love.graphics.setColor(0.4, 0.2, 0.1)
            love.graphics.rectangle("fill", 120, 120, 160, 16)
        else
            love.graphics.setColor(1, 1, 1)
            local bg_scale = window_width / background:getWidth()
            local bg_height = background:getHeight() * bg_scale
            local bg_y = (window_height - bg_height) / 2
            love.graphics.draw(background, 0, bg_y, 0, bg_scale, bg_scale)
        end
        love.graphics.setColor(1, 1, 1)

        -- Create a list of objects to draw
        local draw_list = {}

        -- Add the box (Level 1 only)
        if GameState == "level1" then
            if box.state == "closed" and box.closed_img then
                table.insert(draw_list, {obj = "box", y = box.y, draw = function()
                    love.graphics.draw(box.closed_img, box.x, box.y, 0, scale, scale, box.closed_img:getWidth()/2, box.closed_img:getHeight()/2)
                end})
            elseif box.open_img then
                table.insert(draw_list, {obj = "box", y = box.y, draw = function()
                    love.graphics.draw(box.open_img, box.x, box.y, 0, scale, scale, box.open_img:getWidth()/2, box.open_img:getHeight()/2)
                end})
            end
        end

        -- Add items
        for i, item in ipairs(items) do
            if item.spawned and item.img then
                table.insert(draw_list, {obj = "item", y = item.y, item = item, draw = function()
                    if item.flash_timer > 0 then
                        local flash_alpha = item.flash_timer / flash_duration
                        love.graphics.setColor(1, 1, 0, flash_alpha)
                    else
                        love.graphics.setColor(1, 1, 1)
                    end
                    love.graphics.draw(item.img, item.x, item.y, 0, scale, scale, item.img:getWidth()/2, item.img:getHeight()/2)
                    love.graphics.setColor(1, 1, 1)

                    local text_width = love.graphics.getFont():getWidth(item.name)
                    local text_height = love.graphics.getFont():getHeight()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(item.name, item.x - text_width / 2, item.y - 50 - text_height)

                    if GameState == "level2" and item.inspected then
                        local status_text = item.is_damaged and (item.replaced and "Replaced!" or "Damaged!") or "Good!"
                        local status_width = love.graphics.getFont():getWidth(status_text)
                        local status_height = love.graphics.getFont():getHeight()
                        if item.is_damaged then
                            love.graphics.setColor(item.replaced and {0, 1, 1} or {1, 0, 0})
                        else
                            love.graphics.setColor(0, 1, 0)
                        end
                        love.graphics.print(status_text, item.x - status_width / 2, item.y - 80 - status_height)
                        love.graphics.setColor(1, 1, 1)
                    end
                end})
            end
        end

        -- Add the player
        table.insert(draw_list, {obj = "kid", y = Animation.player.y, draw = function()
            Animation:draw(player_scale)
        end})

        -- Sort by y-position
        table.sort(draw_list, function(a, b) return a.y < b.y end)

        -- Draw all objects
        for _, entry in ipairs(draw_list) do
            entry.draw()
        end

        -- Draw checklist in Level 2 with new theme
        if GameState == "level2" then
            local checklist_y = 50
            local line_height = 20
            local padding = 30 -- Increased padding to 30 for safety

            -- Calculate the width based on the longest item name
            love.graphics.setFont(checklist_font)
            local checklist_width = checklist_font:getWidth("Checklist") + padding -- Start with the title width
            for _, item in ipairs(items) do
                local text = "✔ " .. item.name
                local text_width = checklist_font:getWidth(text)
                checklist_width = math.max(checklist_width, text_width + padding)
            end

            -- Debug: Print the calculated width
            print("Checklist width: " .. checklist_width)

            -- Calculate checklist_x to ensure the checklist fits within the screen
            local checklist_x = window_width - checklist_width - 20 -- 20 pixels margin from the right edge

            local checklist_height = (#items * line_height) + 40

            -- Draw background with a semi-transparent gray
            love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
            love.graphics.rectangle("fill", checklist_x - 10, checklist_y - 20, checklist_width, checklist_height, 5)

            -- Draw a green border
            love.graphics.setColor(0, 1, 0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", checklist_x - 10, checklist_y - 20, checklist_width, checklist_height, 5)

            -- Draw title
            local title = "Checklist"
            local title_width = checklist_font:getWidth(title)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(title, checklist_x, checklist_y - 15)

            -- Draw items
            for i, item in ipairs(items) do
                local checkmark = item.checked and "✔ " or "  "
                local text = checkmark .. item.name
                if item.checked then
                    love.graphics.setColor(0, 1, 0)
                else
                    love.graphics.setColor(1, 1, 0)
                end
                love.graphics.print(text, checklist_x, checklist_y + (i - 1) * line_height)
            end

            -- Reset font and color
            love.graphics.setFont(love.graphics.newFont(14))
            love.graphics.setColor(1, 1, 1)
        end

        -- Prompt or completion text
        if GameState == "level1" then
            if box.state == "closed" then
                local text_width = love.graphics.getFont():getWidth("Press Space to Unpack")
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", box.x - text_width / 2 - 5, box.y - 100 - text_height - 5, text_width + 10, text_height + 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("Press Space to Unpack", box.x - text_width / 2, box.y - 100 - text_height)
            elseif done then
                local text_width = love.graphics.getFont():getWidth("Kit Unpacked!")
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", box.x - text_width / 2 - 5, box.y - 100 - text_height - 5, text_width + 10, text_height + 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("Kit Unpacked!", box.x - text_width / 2, box.y - 100 - text_height)
            end
        elseif GameState == "level2" then
            if not level2_complete then
                local text = "Inspect all items (Space to inspect, R to replace damaged)"
                local text_width = love.graphics.getFont():getWidth(text)
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", window_width / 2 - text_width / 2 - 5, 20, text_width + 10, text_height + 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(text, window_width / 2 - text_width / 2, 20 + 5)
            else
                local text = "Level 2 Complete! Press Space to Continue"
                local text_width = love.graphics.getFont():getWidth(text)
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", window_width / 2 - text_width / 2 - 5, window_height / 2 - text_height / 2 - 5, text_width + 10, text_height + 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(text, window_width / 2 - text_width / 2, window_height / 2 - text_height / 2)
            end
        end
    elseif GameState == "mounting" then
        Mounting:draw()
    elseif GameState == "wire_game" then
        WireGame:draw()
    elseif GameState == "game_over" then
        local text = "Game Over! Thanks for Playing!"
        local text_width = love.graphics.getFont():getWidth(text)
        local text_height = love.graphics.getFont():getHeight()
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", window_width / 2 - text_width / 2 - 5, window_height / 2 - text_height / 2 - 5, text_width + 10, text_height + 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, window_width / 2 - text_width / 2, window_height / 2 - text_height / 2)
    end
end

function love.keypressed(key)
    if GameState == "menu" then
        Menu:keypressed(key)
    elseif GameState == "pause" then
        Pause:keypressed(key)
    elseif GameState == "survey" then
        Survey:keypressed(key)
    elseif GameState == "level1" then
        if key == "space" and box.state == "closed" then
            box.state = "open"
            unpacking = true
        elseif key == "escape" then
            Pause.previousState = GameState
            GameState = "pause"
        end
    elseif GameState == "level2" then
        if key == "space" then
            if level2_complete then
                GameState = "wire_game"
            else
                for _, item in ipairs(items) do
                    if not item.inspected then
                        local dx = Animation.player.x - item.x
                        local dy = Animation.player.y - item.y
                        local distance = math.sqrt(dx * dx + dy * dy)
                        if distance <= inspection_radius then
                            item.inspected = true
                            item.flash_timer = flash_duration
                            if not item.is_damaged then
                                item.checked = true
                            end
                            break
                        end
                    end
                end
            end
        elseif key == "r" then
            for _, item in ipairs(items) do
                if item.inspected and item.is_damaged and not item.replaced then
                    local dx = Animation.player.x - item.x
                    local dy = Animation.player.y - item.y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    if distance <= inspection_radius then
                        item.replaced = true
                        item.flash_timer = flash_duration
                        item.checked = true
                        break
                    end
                end
            end
        elseif key == "escape" then
            Pause.previousState = GameState
            GameState = "pause"
        end
    elseif GameState == "mounting" then
        Mounting:keypressed(key)
    elseif GameState == "wire_game" then
        WireGame:keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if GameState == "survey" then
        Survey:mousepressed(x, y, button)
    elseif GameState == "mounting" then
        Mounting:mousepressed(x, y, button)
    elseif GameState == "wire_game" then
        WireGame:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if GameState == "survey" then
        Survey:mousereleased(x, y, button)
    elseif GameState == "mounting" then
        Mounting:mousereleased(x, y, button)
    elseif GameState == "wire_game" then
        WireGame:mousereleased(x, y, button)
    end
end