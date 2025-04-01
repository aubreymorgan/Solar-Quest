Animation = {}

function Animation:load(survey)
    -- Load animation file from library
    self.anim8 = require 'libraries/anim8'
    self.survey = survey  -- Store reference to Survey

    -- Initilaize player object
    self.player = {}
    self.player.x = 550
    self.player.y = 400
    self.player.speed = 3
    self.player.sprite = love.graphics.newImage("assets/Sprite.png")
    self.player.grid = self.anim8.newGrid(self.player.sprite:getWidth()/3, self.player.sprite:getHeight()/4, self.player.sprite:getWidth(), self.player.sprite:getHeight())

    -- Initilaize animation object
    self.player.animations = {}
    self.player.animations.up = self.anim8.newAnimation(self.player.grid('1-3', 1), 0.2)
    self.player.animations.left = self.anim8.newAnimation(self.player.grid('1-3', 2), 0.2)
    self.player.animations.down = self.anim8.newAnimation(self.player.grid('1-3', 3), 0.2)
    self.player.animations.right = self.anim8.newAnimation(self.player.grid('1-3', 4), 0.2)
    self.player.anim = self.player.animations.left
end

function Animation:update(dt)

    local isMoving = false 

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

function Animation:draw()
    -- Draw player sprite
    self.player.anim:draw(self.player.sprite, self.player.x, self.player.y, nil, 1.5)
end

function Animation:keypressed(key)
    -- Check if space is pressed while near the technician
    if key == "space" then
        local dx = self.player.x - self.survey.techX
        local dy = self.player.y - self.survey.techY
        -- Calculate distance between layer and tecnician
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance <= self.survey.techRadius then
            -- Update Survey's variable
            self.survey.showDialogue = true  
        end
    end
end


