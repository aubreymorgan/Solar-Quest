Survey = {}

function Survey:load()
    Animation:load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    self.schoolYardScreen = love.graphics.newImage("assets/CrackedSchool.png")
    self.techHead = love.graphics.newImage("assets/TechHead.png")
    self.solarMeterRed = love.graphics.newImage("assets/SolarMeterRed.png")
    self.solarMeterYellow = love.graphics.newImage("assets/SolarMeterYellow.png")
    self.solarMeterGreen = love.graphics.newImage("assets/SolarMeterGreen.png")
    self.roofTile = love.graphics.newImage("assets/RepairTile.png")
    self.repairedSchool = love.graphics.newImage("assets/RepairedSchool.png")

    self.scanZones = {
        { y = 0, height = 140, meter = "yellow", assessment = "This area seems to be getting some shadows early in the morning from the school building and trees..." },
        { y = 140, height = 88, meter = "green", assessment = "This area gets great sunlight! Although it looks like the roof needs to be repaired first..." },
        { y = 228, height = 161, meter = "red", assessment = "This area is not compatible for mounting solar panels..." },
        { y = 390, height = 98, meter = "yellow", assessment = "This area seems to be getting some shadows later in the day from the school building and trees..." },
    }
    self.currentZoneIndex = 1

    self.blinkTimer = 0
    self.showPressSpace = true

    self.tile = {
        x = 660,
        y = 500,
        width = self.roofTile:getWidth(),
        height = self.roofTile:getHeight(),
        dragging = false,
        offsetX = 0,
        offsetY = 0
    }

    self.targetArea = { x = 243, y = 147, width = 79, height = 79 }

    self.currentScreen = "start"

    self.doorX = 400
    self.doorY = 300
    self.doorRadius = 150 -- Increased from 75 to match previous fix
end

function Survey:update(dt)
    if self.currentScreen == "start" or self.currentScreen == "survey" or self.currentScreen == "ready" or self.currentScreen == "scanning" or self.currentScreen == "correct" or self.currentScreen == "incorrect" or self.currentScreen == "empty" then
        self.blinkTimer = self.blinkTimer + dt
        if self.blinkTimer >= 0.5 then
            self.blinkTimer = 0
            self.showPressSpace = not self.showPressSpace
        end
    end

    if self.currentScreen == "empty" then
        Animation:update(dt)
    end

    if self.currentScreen == "repair" and self.tile.dragging then
        local x, y = love.mouse.getPosition()
        self.tile.x = x - self.tile.offsetX
        self.tile.y = y - self.tile.offsetY
    end
end

function Survey:draw()
    if self.currentScreen == "start" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Today we are going to install your school's new solar panels! First, we need to survey the area to find the best location to install the panels. Let's go!", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 670, 565, 60, 20)
            love.graphics.printf("SPACE", 670, 567, 60, "center")
        end
    elseif self.currentScreen == "survey" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("We can use this solar meter to determine how much sunlight an area is getting. Use the up/down keys to scan an area.", 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.draw(self.solarMeterRed, 673, 485)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 610, 565, 60, 20)
            love.graphics.printf("SPACE", 610, 567, 60, "center")
        end
    elseif self.currentScreen == "scanning" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        local zone = self.scanZones[self.currentZoneIndex]
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, zone.y, 800, zone.height)
        love.graphics.setColor(1, 1, 1)
        local text = "Press ENTER to select this area"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        local centerX = 0 + 400 - (textWidth / 2)
        local centerY = zone.y + (zone.height / 2) - (textHeight / 2)
        love.graphics.print(text, centerX, centerY)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf(zone.assessment, 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 570, 565, 30, 20)
            love.graphics.printf("UP", 570, 567, 30, "center")
            love.graphics.rectangle("line", 610, 565, 50, 20)
            love.graphics.printf("DOWN", 610, 567, 50, "center")
        end
        if zone.meter == "red" then
            love.graphics.draw(self.solarMeterRed, 673, 485)
        elseif zone.meter == "yellow" then
            love.graphics.draw(self.solarMeterYellow, 673, 485)
        elseif zone.meter == "green" then
            love.graphics.draw(self.solarMeterGreen, 673, 485)
        end
    elseif self.currentScreen == "correct" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        local zone = self.scanZones[self.currentZoneIndex]
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", 0, zone.y, 800, zone.height)
        love.graphics.setColor(1, 1, 1)
        local text = "Correct!"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        local centerX = 0 + 400 - (textWidth / 2)
        local centerY = zone.y + (zone.height / 2) - (textHeight / 2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(text, centerX, centerY)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("That solar meter reading looks great! Now let's repair that roof!", 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 610, 565, 60, 20)
            love.graphics.printf("SPACE", 610, 567, 60, "center")
        end
        if zone.meter == "red" then
            love.graphics.draw(self.solarMeterRed, 673, 485)
        elseif zone.meter == "yellow" then
            love.graphics.draw(self.solarMeterYellow, 673, 485)
        elseif zone.meter == "green" then
            love.graphics.draw(self.solarMeterGreen, 673, 485)
        end
    elseif self.currentScreen == "incorrect" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        local zone = self.scanZones[self.currentZoneIndex]
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, zone.y, 800, zone.height)
        love.graphics.setColor(1, 1, 1)
        local text = "Incorrect!"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        local centerX = 0 + 400 - (textWidth / 2)
        local centerY = zone.y + (zone.height / 2) - (textHeight / 2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(text, centerX, centerY)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("We need to choose an area with a higher solar meter reading. Please try again!", 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 610, 565, 60, 20)
            love.graphics.printf("SPACE", 610, 567, 60, "center")
        end
        if zone.meter == "red" then
            love.graphics.draw(self.solarMeterRed, 673, 485)
        elseif zone.meter == "yellow" then
            love.graphics.draw(self.solarMeterYellow, 673, 485)
        elseif zone.meter == "green" then
            love.graphics.draw(self.solarMeterGreen, 673, 485)
        end
    elseif self.currentScreen == "repair" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("We can use this roof tile to repair the damaged roof. Just drag and drop the tile onto the damaged area", 180, 510, 500, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.draw(self.roofTile, self.tile.x, self.tile.y)
        love.graphics.setColor(1, 1, 1)
    elseif self.currentScreen == "ready" then
        love.graphics.draw(self.repairedSchool, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Now it's time to head inside so we can start unpacking our solar power kit.", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 670, 565, 60, 20)
            love.graphics.printf("SPACE", 670, 567, 60, "center")
        end
    elseif self.currentScreen == "empty" then
        love.graphics.draw(self.repairedSchool, 0, 0)
        Animation:draw(1) -- Use 1x scale in survey phase
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Move with arrow keys. Press the space bar to go inside the school.", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)
        love.graphics.setColor(1, 1, 1)
        if self.showPressSpace then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 670, 565, 60, 20)
            love.graphics.printf("SPACE", 670, 567, 60, "center")
        end
    end
end

function Survey:keypressed(key)
    if key == "escape" then
        GameState = "pause"
    elseif self.currentScreen == "start" and key == "space" then
        self.currentScreen = "survey"
    elseif self.currentScreen == "survey" then
        if key == "space" then
            self.currentScreen = "scanning"
        elseif key == "backspace" then
            self.currentScreen = "start"
        end
    elseif self.currentScreen == "scanning" then
        if key == "up" then
            if self.currentZoneIndex > 1 then
                self.currentZoneIndex = self.currentZoneIndex - 1
            end
        elseif key == "down" then
            if self.currentZoneIndex < #self.scanZones then
                self.currentZoneIndex = self.currentZoneIndex + 1
            end
        elseif key == "return" then
            if self.currentZoneIndex == 2 then
                self.currentScreen = "correct"
            else
                self.currentScreen = "incorrect"
            end
        elseif key == "backspace" then
            self.currentScreen = "survey"
        end
    elseif self.currentScreen == "incorrect" then
        if key == "space" then
            self.currentScreen = "scanning"
        elseif key == "backspace" then
            self.currentScreen = "scanning"
        end
    elseif self.currentScreen == "correct" then
        if key == "space" then
            self.currentScreen = "repair"
        elseif key == "backspace" then
            self.currentScreen = "scanning"
        end
    elseif self.currentScreen == "repair" then
        if key == "backspace" then
            self.currentScreen = "scanning"
        end
    elseif self.currentScreen == "ready" then
        if key == "space" then
            self.currentScreen = "empty"
        elseif key == "backspace" then
            self.currentScreen = "repair"
        end
    elseif self.currentScreen == "empty" then
        local scale = 1
        if Animation:keypressed(key, self.doorX, self.doorY, self.doorRadius, scale) then
            GameState = "level1" -- Transition to Level 1 instead of "unpacking"
        elseif key == "backspace" then
            self.currentScreen = "repair"
        end
    end
end

function Survey:mousepressed(x, y, button)
    if self.currentScreen == "repair" and button == 1 then
        local tile = self.tile
        if x >= tile.x and x <= tile.x + tile.width and y >= tile.y and y <= tile.y + tile.height then
            tile.dragging = true
            tile.offsetX = x - tile.x
            tile.offsetY = y - tile.y
        end
    end
end

function Survey:mousereleased(x, y, button)
    if self.currentScreen == "repair" and button == 1 then
        local tile = self.tile
        tile.dragging = false
        local target = self.targetArea
        if x >= target.x and x <= target.x + target.width and y >= target.y and y <= target.y + target.height then
            print("Tile successfully placed!")
            self.currentScreen = "ready"
        else
            print("Try again!")
        end
    end
end

return Survey