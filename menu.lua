Menu = {}

function Menu:load()
    self.welcomeScreen = love.graphics.newImage("assets/Welcome.png")
    self.pointer = love.graphics.newImage("assets/pointer.png")
    self.helpScreen = love.graphics.newImage("assets/Help.png")
    self.pointerX = 300
    self.pointerY = 245
    self.currentScreen = "menu"
end

function Menu:update(dt)
end

function Menu:draw()
    if self.currentScreen == "menu" then
        love.graphics.draw(self.welcomeScreen, 0, 0)
        love.graphics.draw(self.pointer, self.pointerX, self.pointerY)
        love.graphics.setColor(0.576, 0.149, 0.0)  -- brown
        love.graphics.setFont(PressStartFont)
        love.graphics.print("START GAME", 340, 253)
        love.graphics.print("HELP", 340, 291)
        love.graphics.setColor(1, 1, 1) -- reset to white
    elseif self.currentScreen == "help" then
        love.graphics.draw(self.helpScreen, 0, 0)
        love.graphics.setColor(0.576, 0.149, 0.0)  -- brown
        love.graphics.setColor(1, 1, 1) -- reset to white
    end
end

function Menu:keypressed(key)
    if self.currentScreen == "menu" and key == "down" then
        self.pointerY = 283
    elseif self.currentScreen == "menu" and key == "up" then
        self.pointerY = 245
    elseif self.currentScreen == "help" and key == "escape" then
        self.currentScreen = "menu"
    elseif self.currentScreen == "menu" and key == "return" then
        if self.pointerY == 245 then
            GameState = "survey"
        elseif self.pointerY == 283 then
            self.currentScreen = "help"
        end
    end
end

return Menu