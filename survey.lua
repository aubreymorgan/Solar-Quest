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
    if self.dialog then
        self.dialog:update(dt)
    end
end

function Survey:draw()

    -- Draw screen images and/or solar panel
    if self.currentScreen == "start" then
        love.graphics.draw(self.startGameScreen, 0, 0)

     -- Draw scoolyard background
    elseif self.currentScreen == "survey" then
        love.graphics.draw(self.schoolYardScreen, 0, 0)

        -- Scale the solar panel image to 88.4 x 94.5 pixels
        local originalWidth = self.solarPanel:getWidth()
        local originalHeight = self.solarPanel:getHeight()
        local scaleX = 88.4 / originalWidth
        local scaleY = 94.5 / originalHeight

        -- Apply scaling factors and draw solar panel
        love.graphics.draw( self.solarPanel, self.panelX, 
                            self.panelY, 0, scaleX, scaleY )

     -- Draw correct choice dialog
    elseif self.currentScreen == "correct" then
        love.graphics.draw(self.correct, 0, 0)

     -- Draw incorrect choice dialog
    elseif self.currentScreen == "incorrect" then
        love.graphics.draw(self.incorrect, 0, 0)
    end
end

function Survey:keypressed(key)
    -- User proceds by using enter key
    if self.currentScreen == "start" and key == "return" then
        self.currentScreen = "survey"

     -- User pauses the game using the escape key
    elseif key == "escape" then
        GameState = "pause"

     -- User is moving the solar panel with arrow keys
    elseif self.currentScreen == "survey" then

        -- Move to the next site if not already at the last site
        if key == "right" then
            if self.currentSiteIndex < #self.sites then
                self.currentSiteIndex = self.currentSiteIndex + 1
            end

         -- Move to the previous site if not already at the first site
        elseif key == "left" then
            if self.currentSiteIndex > 1 then
                self.currentSiteIndex = self.currentSiteIndex - 1
            end

         -- Check the location of the selected site
        elseif key == "return" then

            -- Correct choice
            if self.currentSiteIndex == 2 then
                self.currentScreen = "correct"
                -- Move on to Game phase: Unpacking and Inspecting the Kit 
                GameState = "unpacking"

             -- Incorrect choice
            else
                self.currentScreen = "incorrect" 
            end
        end
    
     -- Return to survey screen for another attempt
    elseif self.currentScreen == "incorrect" and key == "return" then
        self.currentScreen = "survey"
    end

    -- Update panel position based on current site
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y
end

