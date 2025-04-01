-- Load the Anim8 library
anim8 = require("anim8")
-- Load the Animation module
Animation = require("animation")

-- Global variables
local background = nil
local box = {
    x = 400, y = 400, -- Adjusted to center in 800x600 window
    closed_img = nil,
    open_img = nil,
    state = "closed"
}

local items = {
    {name = "Solar Panels", img = nil, x = 0, y = 0, spawned = false, target_x = 200, target_y = 150, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0},
    {name = "Charge Controller", img = nil, x = 0, y = 0, spawned = false, target_x = 300, target_y = 150, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0},
    {name = "Battery Storage", img = nil, x = 0, y = 0, spawned = false, target_x = 600, target_y = 350, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0},
    {name = "Inverter", img = nil, x = 0, y = 0, spawned = false, target_x = 500, target_y = 450, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0},
    {name = "Wiring", img = nil, x = 0, y = 0, spawned = false, target_x = 300, target_y = 450, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0},
    {name = "Mounting Hardware", img = nil, x = 0, y = 0, spawned = false, target_x = 200, target_y = 350, state = "waiting", velocity = 0, move_timer = 0, inspected = false, is_damaged = false, replaced = false, flash_timer = 0}
}

local current_item = 1
local timer = 0
local unpacking = false
local done = false

-- Game state
local game_state = "level1" -- Possible states: "level1", "level2", "level3", "game_over"
local level2_complete = false

-- Window dimensions
local window_width = 800
local window_height = 600

-- Scaling factor for all images
local scale = 4

-- Inspection and replacement radius
local inspection_radius = 50 -- Distance within which the player can inspect or replace an item

-- Flash effect duration
local flash_duration = 0.5 -- Flash for 0.5 seconds

-- Load function
function love.load()
    Animation:load() 

    love.window.setMode(window_width, window_height)

    -- Load background with detailed error handling
    local success, result = pcall(love.graphics.newImage, "assets/courtyard.png")
    if success then
        background = result
        print("Successfully loaded assets/courtyard.png")
    else
        print("Failed to load assets/courtyard.png: " .. tostring(result))
        background = nil
    end

    -- Load box images with error handling
    local success, result = pcall(love.graphics.newImage, "assets/box_closed.png")
    if success then
        box.closed_img = result
        print("Successfully loaded assets/box_closed.png")
    else
        print("Failed to load assets/box_closed.png: " .. tostring(result))
    end

    success, result = pcall(love.graphics.newImage, "assets/box_open.png")
    if success then
        box.open_img = result
        print("Successfully loaded assets/box_open.png")
    else
        print("Failed to load assets/box_open.png: " .. tostring(result))
    end

    -- Load item images with error handling
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
            print("Successfully loaded " .. file)
        else
            print("Failed to load " .. file .. ": " .. tostring(result))
            items[i].img = nil
        end
    end

    -- Check if critical images are loaded
    if not box.closed_img or not box.open_img then
        error("Cannot start game: Missing box images.")
    end

    -- Randomly determine if items are damaged
    for _, item in ipairs(items) do
        item.is_damaged = math.random() < 0.3 -- 30% chance of being damaged
    end

    -- Set a larger font size for text
    love.graphics.setNewFont(14)
end

-- Linear interpolation function for smooth movement
function lerp(a, b, t)
    return a + (b - a) * t
end

-- Update function with integrated animation system
function love.update(dt)
    Animation:update(dt)

    if game_state == "level1" then
        if unpacking and not done then
            timer = timer + dt
            if timer >= 0.5 and current_item <= #items then
                local item = items[current_item]
                if not item.spawned then
                    -- Initialize the item for animation
                    item.x = box.x
                    item.y = box.y - 30
                    item.spawned = true
                    item.state = "popping"
                    item.velocity = -150 -- Initial upward velocity for the "pop" effect
                    print("Spawning item: " .. item.name .. " at (" .. item.x .. ", " .. item.y .. ")")
                else
                    if item.state == "popping" then
                        -- Handle the "pop" effect (upward motion and falling)
                        item.y = item.y + item.velocity * dt
                        item.velocity = item.velocity + 400 * dt -- Apply gravity
                        print("Item " .. item.name .. " popping: y = " .. item.y .. ", velocity = " .. item.velocity)
                        if item.y >= box.y + 60 then
                            item.state = "moving"
                            item.move_timer = 0
                            print("Item " .. item.name .. " starting to move to target (" .. item.target_x .. ", " .. item.target_y .. ")")
                        end
                    elseif item.state == "moving" then
                        -- Smoothly move to the target position using lerp
                        item.move_timer = item.move_timer + dt
                        local t = math.min(item.move_timer / 0.5, 1) -- Move over 0.5 seconds
                        item.x = lerp(item.x, item.target_x, t)
                        item.y = lerp(item.y, item.target_y, t)
                        print("Item " .. item.name .. " moving to target: (" .. item.x .. ", " .. item.y .. "), t = " .. t)

                        -- Clamp positions to stay within window bounds, accounting for scale
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
                            print("Item " .. item.name .. " reached target. Moving to next item: " .. current_item)
                        end
                    end
                end
            elseif current_item > #items then
                done = true
                print("Unpacking done!")
                -- Transition to level 2
                game_state = "level2"
                print("Transitioning to Level 2: Inspect the Kit")
            end
        end
    elseif game_state == "level2" then
        -- Update flash timers for visual feedback
        for _, item in ipairs(items) do
            if item.flash_timer > 0 then
                item.flash_timer = item.flash_timer - dt
            end
        end

        -- Check if all items are inspected and damaged items are replaced
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
            print("Level 2 Complete!")
        end
    elseif game_state == "level3" then
        -- Placeholder for Level 3
        -- We can add assembly logic here later
    end
end

-- Draw function
function love.draw()
    -- Draw the background, scaled to fit the window width
    if not background then
        -- Simple room background with shapes, adjusted for 800x600
        -- Floor (brown)
        love.graphics.setColor(0.6, 0.4, 0.2)
        love.graphics.rectangle("fill", 0, window_height / 2, window_width, window_height / 2)
        -- Walls (beige)
        love.graphics.setColor(0.9, 0.8, 0.7)
        love.graphics.rectangle("fill", 0, 0, window_width, window_height / 2)
        -- Window (blue)
        love.graphics.setColor(0.2, 0.2, 0.6)
        love.graphics.rectangle("fill", window_width / 2 - 80, 40, 160, 120) -- Adjusted size and position
        -- Desk (dark brown)
        love.graphics.setColor(0.4, 0.2, 0.1)
        love.graphics.rectangle("fill", window_width / 2 - 160, window_height / 2 + 40, 320, 40) -- Adjusted size and position
        -- Shelf (dark brown)
        love.graphics.setColor(0.4, 0.2, 0.1)
        love.graphics.rectangle("fill", 120, 120, 160, 16) -- Adjusted size and position
    else
        love.graphics.setColor(1, 1, 1)
        local bg_scale = window_width / background:getWidth() -- Scale to fit width (800/1000 = 0.8)
        local bg_height = background:getHeight() * bg_scale -- 800 * 0.8 = 640
        local bg_y = (window_height - bg_height) / 2 -- Center vertically: (600 - 640) / 2 = -20 (clip bottom)
        love.graphics.draw(background, 0, bg_y, 0, bg_scale, bg_scale)
    end
    love.graphics.setColor(1, 1, 1)

    -- Create a list of objects to draw, with their y-positions
    local draw_list = {}

    -- Add the box to the draw list (only in level 1)
    if game_state == "level1" then
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

    -- Add items to the draw list
    for i, item in ipairs(items) do
        if item.spawned and item.img then
            table.insert(draw_list, {obj = "item", y = item.y, item = item, draw = function()
                -- Apply flash effect if the item was recently inspected or replaced
                if item.flash_timer > 0 then
                    local flash_alpha = item.flash_timer / flash_duration
                    love.graphics.setColor(1, 1, 0, flash_alpha) -- Yellow flash
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.draw(item.img, item.x, item.y, 0, scale, scale, item.img:getWidth()/2, item.img:getHeight()/2)
                love.graphics.setColor(1, 1, 1)

                local text_width = love.graphics.getFont():getWidth(item.name)
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", item.x - text_width / 2 - 5, item.y - 50 - text_height - 5, text_width + 10, text_height + 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(item.name, item.x - text_width / 2, item.y - 50 - text_height)

                -- Display inspection status in level 2 and 3
                if (game_state == "level2" or game_state == "level3") and item.inspected then
                    local status_text = item.is_damaged and (item.replaced and "Replaced!" or "Damaged!") or "Good!"
                    local status_width = love.graphics.getFont():getWidth(status_text)
                    local status_height = love.graphics.getFont():getHeight()
                    love.graphics.setColor(0, 0, 0, 0.8)
                    love.graphics.rectangle("fill", item.x - status_width / 2 - 5, item.y - 80 - status_height - 5, status_width + 10, status_height + 10)
                    if item.is_damaged then
                        love.graphics.setColor(item.replaced and {0, 1, 1} or {1, 0, 0}) -- Cyan for replaced, red for damaged
                    else
                        love.graphics.setColor(0, 1, 0) -- Green for good
                    end
                    love.graphics.print(status_text, item.x - status_width / 2, item.y - 80 - status_height)
                    love.graphics.setColor(1, 1, 1)
                end
            end})
        end
    end

    -- Add the kid to the draw list
    table.insert(draw_list, {obj = "kid", y = Animation.player.y, draw = function()
        Animation:draw()
    end})

    -- Sort the draw list by y-position (lower y first)
    table.sort(draw_list, function(a, b) return a.y < b.y end)

    -- Draw all objects in order
    for _, entry in ipairs(draw_list) do
        entry.draw()
    end

    -- Prompt or completion text (always on top)
    if game_state == "level1" then
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
    elseif game_state == "level2" then
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
    elseif game_state == "level3" then
        local text = "Level 3: Assemble the Kit (Coming Soon!)"
        local text_width = love.graphics.getFont():getWidth(text)
        local text_height = love.graphics.getFont():getHeight()
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", window_width / 2 - text_width / 2 - 5, window_height / 2 - text_height / 2 - 5, text_width + 10, text_height + 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, window_width / 2 - text_width / 2, window_height / 2 - text_height / 2)
    elseif game_state == "game_over" then
        local text = "Game Over! Thanks for Playing!"
        local text_width = love.graphics.getFont():getWidth(text)
        local text_height = love.graphics.getFont():getHeight()
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", window_width / 2 - text_width / 2 - 5, window_height / 2 - text_height / 2 - 5, text_width + 10, text_height + 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, window_width / 2 - text_width / 2, window_height / 2 - text_height / 2)
    end
end

-- Key press handler
function love.keypressed(key)
    if game_state == "level1" then
        if key == "space" and box.state == "closed" then
            box.state = "open"
            unpacking = true
            print("Unpacking started!")
        end
    elseif game_state == "level2" then
        if key == "space" then
            if level2_complete then
                -- Transition to level 3
                game_state = "level3"
                print("Transitioning to Level 3: Assemble the Kit")
            else
                -- Check for item inspection
                for _, item in ipairs(items) do
                    if not item.inspected then
                        local dx = Animation.player.x - item.x
                        local dy = Animation.player.y - item.y
                        local distance = math.sqrt(dx * dx + dy * dy)
                        if distance <= inspection_radius then
                            item.inspected = true
                            item.flash_timer = flash_duration -- Trigger flash effect
                            print("Inspected " .. item.name .. ": " .. (item.is_damaged and "Damaged!" or "Good!"))
                            break
                        end
                    end
                end
            end
        elseif key == "r" then
            -- Check for item replacement
            for _, item in ipairs(items) do
                if item.inspected and item.is_damaged and not item.replaced then
                    local dx = Animation.player.x - item.x
                    local dy = Animation.player.y - item.y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    if distance <= inspection_radius then
                        item.replaced = true
                        item.flash_timer = flash_duration -- Trigger flash effect
                        print("Replaced " .. item.name)
                        break
                    end
                end
            end
        end
    elseif game_state == "level3" then
        if key == "space" then
            -- End the game for now
            game_state = "game_over"
            print("Game Over! All levels complete.")
        end
    end
end 
