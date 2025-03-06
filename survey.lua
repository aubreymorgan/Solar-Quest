Survey = {}

function Survey:load()
    -- Initilaize images from assets folder
    self.startGameScreen = love.graphics.newImage("assets/StartGame.png")
    self.schoolYardScreen = love.graphics.newImage("assets/Schoolyard.png")
    self.solarPanel = love.graphics.newImage("assets/panel.png")

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

        -- Apply scaling factors and dwar solar panel
        love.graphics.draw( self.solarPanel, self.panelX, 
                            self.panelY, 0, scaleX, scaleY )
    end
end

function Survey:keypressed(key)
    if self.currentScreen == "start" and key == "return" then
        self.currentScreen = "survey"
    elseif key == "escape" then
        GameState = "menu"
    elseif key == "right" then
        -- Move to the next site if not already at the last site
        if self.currentSiteIndex < #self.sites then
            self.currentSiteIndex = self.currentSiteIndex + 1
        end
    elseif key == "left" then
        -- Move to the previous site if not already at the first site
        if self.currentSiteIndex > 1 then
            self.currentSiteIndex = self.currentSiteIndex - 1
        end
    end

    -- Update panel position based on current site
    self.panelX = self.sites[self.currentSiteIndex].x
    self.panelY = self.sites[self.currentSiteIndex].y
end
