Survey = {}

function Survey:load()
    -- Initilaize images from assets folder
    self.startGameScreen = love.graphics.newImage("assets/StartGame.png")
    self.schoolYardScreen = love.graphics.newImage("assets/Schoolyard.png")
    self.solarPanel = love.graphics.newImage("assets/panel.png")
    self.correct = love.graphics.newImage("assets/correct.png")
    self.incorrect = love.graphics.newImage("assets/incorrect.png")

    -- Define the potential site coordinates
    self.sites = {
        {x = 223, y = 109}, -- Site1
        {x = 436, y = 109}, -- Site2
        {x = 625, y = 205}  -- Site3
    }

    -- Initalize the solar panel location
    self.currentSiteIndex = 1
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y

    -- Control current screen
    self.currentScreen = "start"
end

function Survey:update(dt)

end

function Survey:draw()
    -- Draw screen images and/or solar panel
    if self.currentScreen == "start" then
        love.graphics.draw(self.startGameScreen, 0, 0)
    elseif self.currentScreen == "survey" then
        -- Draw scoolyard background
        love.graphics.draw(self.schoolYardScreen, 0, 0)

        -- Scale the solar panel image to 88.4 x 94.5 pixels
        local originalWidth = self.solarPanel:getWidth()
        local originalHeight = self.solarPanel:getHeight()
        local scaleX = 88.4 / originalWidth
        local scaleY = 94.5 / originalHeight

        -- Apply scaling factors and draw solar panel
        love.graphics.draw( self.solarPanel, self.panelX, 
                            self.panelY, 0, scaleX, scaleY )
    elseif self.currentScreen == "correct" then
        love.graphics.draw(self.correct, 0, 0)
    elseif self.currentScreen == "incorrect" then
        love.graphics.draw(self.incorrect, 0, 0)
    end
end

function Survey:keypressed(key)
    if self.currentScreen == "start" and key == "return" then
        self.currentScreen = "survey"
    elseif key == "escape" then
        GameState = "pause"
    elseif self.currentScreen == "survey" then
        if key == "right" then
            -- Move to the next site if not already at the last site
            if self.currentSiteIndex < #self.sites then
                self.currentSiteIndex = self.currentSiteIndex + 1
            end
        elseif key == "left" then
            -- Move to the previous site if not already at the first site
            if self.currentSiteIndex > 1 then
                self.currentSiteIndex = self.currentSiteIndex - 1
            end
        elseif key == "return" then
            -- Check the selected site
            if self.currentSiteIndex == 2 then
                self.currentScreen = "correct"  -- Correct choice
            else
                self.currentScreen = "incorrect"  -- Incorrect choice
            end
        end
    elseif self.currentScreen == "incorrect" and key == "return" then
        -- Return to survey screen for another attempt
        self.currentScreen = "survey"
    end

    -- Update panel position based on current site
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y
end

