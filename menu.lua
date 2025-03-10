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
    -- Allow user to move pointer with up/down keys
    if love.keyboard.isDown("down") then
        -- Move to "Help"
        self.pointerY = 283 
    elseif love.keyboard.isDown("up") then
        -- Move back to "Start Game"
        self.pointerY = 245 
    end

    -- Detect Enter key press and update gameState
    if love.keyboard.isDown("return") then
        -- Enter is pressed while on start game option
        if self.pointerY == 245 then
            GameState = "survey"  
        -- Enter is pressed  while on help option
        elseif self.pointerY == 283 then
            self.currentScreen = "help"  
        end
    end

    -- Return to menu if player exits 
    if love.keyboard.isDown("escape") then
        self.currentScreen = "menu"
    end
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