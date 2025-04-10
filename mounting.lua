Mounting = {}

function Mounting:load()
    -- Initialize images from assets folder
    love.graphics.setDefaultFilter("nearest", "nearest")
    self.school = love.graphics.newImage("assets/RepairedSchool.png")
    self.techHead = love.graphics.newImage("assets/TechHead.png")
    self.spright = love.graphics.newImage("assets/SolarPanelRight.png")
    self.spmiddle = love.graphics.newImage("assets/SolarPanelMiddle.png")
    self.spleft = love.graphics.newImage("assets/SolarPanelLeft.png")
    self.school1 = love.graphics.newImage("assets/School1.png")

    -- Controls blinking effect for player prompts
    self.blinkTimer = 0
    self.showPressSpace = true

    -- Define solar panel properties
    self.tile = {
        x = 575,
        y = 500,
        width = self.spmiddle:getWidth(),
        height = self.spmiddle:getHeight(),
        dragging = false,
        offsetX = 0,
        offsetY = 0
    }

    -- Define the target area for dropping the panel (right side of the roof)
    self.targetArea = {x = 328, y = 147, width = 145, height = 76}

    self.currentScreen = "mounting"
end

function Mounting:update(dt)
    -- Updates blinking effect for player prompts
    if self.currentScreen == "mounting" then
        self.blinkTimer = self.blinkTimer + dt
        if self.blinkTimer >= 0.5 then
            self.blinkTimer = 0
            self.showPressSpace = not self.showPressSpace
        end
    end

    -- Updates drag and drop panel
    if self.currentScreen == "mounting" and self.tile.dragging then
        local x, y = love.mouse.getPosition()
        self.tile.x = x - self.tile.offsetX
        self.tile.y = y - self.tile.offsetY
    end
end

function Mounting:draw()
    if self.currentScreen == "mounting" then
        love.graphics.draw(self.school, 0, 0)

        -- Optional: draw red rectangle for drop area (debugging)
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.rectangle("fill", self.targetArea.x, self.targetArea.y, self.targetArea.width, self.targetArea.height)
        love.graphics.setColor(1, 1, 1)

        -- Draw dialog box
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Place the solar panel on the roof!", 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)

        -- Draw the solar panel
        love.graphics.draw(self.spmiddle, self.tile.x, self.tile.y)

        love.graphics.setColor(1, 1, 1)

    elseif self.currentScreen == "complete" then
        love.graphics.draw(self.school1, 0, 0)

        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Solar panel successfully installed!", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)

        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 670, 565, 60, 20)
            love.graphics.printf("SPACE", 670, 567, 60, "center")
        end
    end
end

function Mounting:keypressed(key)
    if key == "escape" then
        GameState = "pause"
    end

    if self.currentScreen == "complete" then
        if key == "space" then
            GameState =  "wire_game"
        end
    end
end

function Mounting:mousepressed(x, y, button)
    if self.currentScreen == "mounting" and button == 1 then
        local tile = self.tile
        -- Check if mouse is within the solar panel bounds
        if x >= tile.x and x <= tile.x + tile.width and y >= tile.y and y <= tile.y + tile.height then
            tile.dragging = true
            tile.offsetX = x - tile.x
            tile.offsetY = y - tile.y
        end
    end
end

function Mounting:mousereleased(x, y, button)
    if self.currentScreen == "mounting" and button == 1 then
        local tile = self.tile
        tile.dragging = false

        -- Check if dropped in target area (right side of the roof)
        local target = self.targetArea
        if x >= target.x and x <= target.x + target.width and y >= target.y and y <= target.y + target.height then
            self.tile.x = target.x + (target.width - tile.width) / 2
            self.tile.y = target.y + (target.height - tile.height) / 2
            self.currentScreen = "complete"  -- Transition to success screen
        else
            print("Try again!")  -- Inform user that placement failed
        end
    end
end

return Mounting
