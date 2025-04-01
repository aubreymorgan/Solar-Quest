-- Move on to Game phase: Unpacking and Inspecting the Kit 
-- GameState = "unpacking"
require("animation")

Survey = {}

function Survey:load()
    -- Load animation and pass Survey as a parameter
    Animation:load(self) -- Pass Survey as a parameter

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Initilaize images from assets folder
    self.startGameScreen = love.graphics.newImage("assets/StartGame.png")
    self.schoolYardScreen = love.graphics.newImage("assets/Schoolyard.png")
    self.solarPanel = love.graphics.newImage("assets/panel.png")
    self.correct = love.graphics.newImage("assets/correct.png")
    self.incorrect = love.graphics.newImage("assets/incorrect.png")
    self.empty = love.graphics.newImage("assets/EmptySchoolyard.png")
    self.tech = love.graphics.newImage("assets/TechStanding.png")

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

    -- Define technician's position
    self.techX = 300
    self.techY = 400
    self.techRadius = 100  -- Interaction radius

    -- Variable to track whether dialogue is active
    self.showDialogue = false
end


function Survey:update(dt)
    if self.currentScreen == "empty" then
        Animation:update(dt)
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

    elseif self.currentScreen == "empty" then
        love.graphics.draw(self.empty, 0, 0)
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("Move with arrow keys. Press space bar to talk to technician.", 160, 0, 480, "center")

        -- Draw Technician sprite
        love.graphics.draw(self.tech, self.techX, self.techY)
        
        -- Draw player sprite
        Animation:draw()

        -- Display dialogue box
        if self.showDialogue then
            love.graphics.setColor(0, 0, 0, 0.7) -- Semi-transparent black box
            love.graphics.rectangle("fill", 150, 500, 500, 100, 10)
            love.graphics.setColor(1, 1, 1) -- White text
            love.graphics.printf("Great work! Now let's go unpack the solar panel kit.", 160, 520, 480, "center")
            love.graphics.setColor(1, 1, 1) -- Reset color
        end
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
                self.currentScreen = "empty"

             -- Incorrect choice
            else
                self.currentScreen = "incorrect" 
            end
        end
    
     -- Return to survey screen for another attempt
    elseif self.currentScreen == "incorrect" and key == "return" then
        self.currentScreen = "survey"
    elseif self.currentScreen == "empty" then
        -- Check if space is pressed while near the technician
        Animation:keypressed(key)
    elseif key == "return" and self.currentScreen == "empty" and self.showDialogue then
        -- Move on to Game phase: Unpacking and Inspecting the Kit 
        GameState = "unpacking"
    end

    -- Update panel position based on current site
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y
end

