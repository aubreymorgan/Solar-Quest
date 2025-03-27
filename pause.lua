Pause = {}

function Pause:load()
    -- Initilaize images from assets folder
    self.pauseScreen = love.graphics.newImage("assets/Pause.png")
    self.pointer = love.graphics.newImage("assets/pointer.png")
    self.helpScreen = love.graphics.newImage("assets/Help.png")

    -- Define the pause option coordinates
    self.option = {
        {x = 290, y = 253}, -- Continue
        {x = 290, y = 306}, -- Main Menu
        {x = 290, y = 359}, -- Help
        {x = 290, y = 412}  -- Exit Game
    }

    -- Set initial pointer position to "Continue"
    self.currentIndex = 1
    self.pointerX = self.option[self.currentIndex].x
    self.pointerY = self.option[self.currentIndex].y

    -- Control current screen
    self.currentScreen = "pause"
end

function Pause:update(dt)
    
end

function Pause:draw()
    -- Draw screen images and/or pointer
    if self.currentScreen == "pause" then
        -- Draw pause screen and pointer
        love.graphics.draw(self.pauseScreen, 0, 0)
        love.graphics.draw(self.pointer, self.pointerX, self.pointerY)

    elseif self.currentScreen == "help" then
        -- Draw help screen
        love.graphics.draw(self.helpScreen, 0, 0)
    end
end

function Pause:keypressed(key)

    -- Allow user to move pointer down
    if  key == "down" then
        -- Move to the next option if not already at the last option
        if self.currentIndex < #self.option then
            self.currentIndex = self.currentIndex + 1
        end

    -- Allow user to move pointer up
    elseif key == "up" then
        -- Move to the previous option if not already at the first option
        if self.currentIndex > 1 then
            self.currentIndex = self.currentIndex - 1
        end
    
    -- Detect user's selection
    elseif self.currentScreen == "pause" and key == "return" then
        -- User selected Continue
        if self.currentIndex == 1 then
            GameState = "survey"  
        -- User selected Main Menu
        elseif self.currentIndex == 2 then
            Survey:load() -- This will reload the player position and other data
            GameState = "menu"   
        -- User selected Help
        elseif self.currentIndex == 3 then
            self.currentScreen = "help"
        -- User selected Exit Game
        else
            love.event.quit() 
        end

    -- Escape button returns from the help screen to the pause screen 
    elseif self.currentScreen == "help" and key == "escape" then
        -- I want to implement a back button
        self.currentScreen = "pause"
    end

    -- Update panel position based on current site
    self.pointerX = self.option[self.currentIndex].x
    self.pointerY = self.option[self.currentIndex].y
end