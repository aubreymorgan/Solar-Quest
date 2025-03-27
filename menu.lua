Menu = {}

function Menu:load()
    -- Initilaize images from assets folder
    self.welcomeScreen = love.graphics.newImage("assets/Welcome.png")
    self.pointer = love.graphics.newImage("assets/pointer.png")
    self.helpScreen = love.graphics.newImage("assets/Help.png")

    -- Set initial pointer position to "Start Game"
    self.pointerX = 300
    self.pointerY = 245

    -- Control current screen
    self.currentScreen = "menu"
end

function Menu:update(dt)
    
end

function Menu:draw()
    -- Draw screen images and/or pointer
    if self.currentScreen == "menu" then
        love.graphics.draw(self.welcomeScreen, 0, 0)
        love.graphics.draw(self.pointer, self.pointerX, self.pointerY)
    elseif self.currentScreen == "help" then
        love.graphics.draw(self.helpScreen, 0, 0)
    end
end

function Menu:keypressed(key)
    -- Allow user to move pointer down to "Help"
    if self.currentScreen == "menu" and key == "down" then
        self.pointerY = 283
    -- Allow user to move pointer up to  "Start Game"
    elseif self.currentScreen == "menu" and key == "up" then
        self.pointerY = 245
    -- Escape button returns from the help screen to the menu screen 
    elseif self.currentScreen == "help" and key == "escape" then
        self.currentScreen = "menu"
    -- Detect Enter key press and update gameState
    elseif self.currentScreen == "menu" and key == "return" then
        -- Enter is pressed while on start game option
        if self.pointerY == 245 then
            GameState = "survey"  
        -- Enter is pressed  while on help option
        elseif self.pointerY == 283 then
            self.currentScreen = "help"  
        end
    end
end