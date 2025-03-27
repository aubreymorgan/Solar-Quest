-- Move on to Game phase: Unpacking and Inspecting the Kit 
-- GameState = "unpacking"

Survey = {}

function Survey:load()
    -- Load animation file from library
    self.anim8 = require 'libraries/anim8'
    -- Prevents graphics from bluring when scaled up 
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

    -- Initilaize player object
    self.player = {}
    self.player.x = 550
    self.player.y = 400
    self.player.speed = 3
    self.player.sprite = love.graphics.newImage("assets/Sprite.png")
    -- newGrid(grid cell width, grid cell height, entire grid width, entire grid height)
    self.player.grid = self.anim8.newGrid(self.player.sprite:getWidth()/3, self.player.sprite:getHeight()/4, self.player.sprite:getWidth(), self.player.sprite:getHeight())

    -- Initilaize animation object
    self.player.animations = {}
    -- newAnimation(player.grid('column - column', row), frames/second)
    self.player.animations.up = self.anim8.newAnimation(self.player.grid('1-3', 1), 0.2)
    self.player.animations.left = self.anim8.newAnimation(self.player.grid('1-3', 2), 0.2)
    self.player.animations.down = self.anim8.newAnimation(self.player.grid('1-3', 3), 0.2)
    self.player.animations.right = self.anim8.newAnimation(self.player.grid('1-3', 4), 0.2)
    self.player.anim = self.player.animations.left

    -- Define technician's position
    self.techX = 300
    self.techY = 400
    self.techRadius = 100  -- Interaction radius

    -- Variable to track whether dialogue is active
    self.showDialogue = false
end


function Survey:update(dt)

    local isMoving = false 
     -- User is moving the player with arrow keys
    if self.currentScreen == "empty" then
        if love.keyboard.isDown("right") then 
            self.player.x = self.player.x + self.player.speed
            self.player.anim = self.player.animations.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then 
            self.player.x = self.player.x - self.player.speed 
            self.player.anim = self.player.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("down") then 
            self.player.y = self.player.y + self.player.speed 
            self.player.anim = self.player.animations.down
            isMoving = true
        end
        if love.keyboard.isDown("up") then 
            self.player.y = self.player.y - self.player.speed 
            self.player.anim = self.player.animations.up
            isMoving = true
        end 

        if isMoving == false then
            self.player.anim:gotoFrame(1)
        end

        self.player.anim:update(dt)
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
        self.player.anim:draw(self.player.sprite, self.player.x, self.player.y, nil, 1.5)
        --self.player.anim:draw(self.player.sprite, self.player.x, self.player.y, nil, 2)

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
     -- Check if space is pressed while near the technician
    elseif key == "space" and self.currentScreen == "empty" then
        local dx = self.player.x - self.techX
        local dy = self.player.y - self.techY
        local distance = math.sqrt(dx * dx + dy * dy) -- Calculate distance

        if distance <= self.techRadius then
            self.showDialogue = true
        end
    elseif key == "return" and self.currentScreen == "empty" and self.showDialogue then
        -- Move on to Game phase: Unpacking and Inspecting the Kit 
        GameState = "unpacking"
    end

    -- Update panel position based on current site
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y
end

