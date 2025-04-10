WireGame = {}

function WireGame:load()
    -- Use existing assets
    self.solar_panel = love.graphics.newImage("assets/solar_panel.png")
    self.charge_controller = love.graphics.newImage("assets/charge_controller.png")
    self.techHead = love.graphics.newImage("assets/TechHead.png")
    self.background = love.graphics.newImage("assets/courtyard.png")
    
    -- Define colors for wires and ports
    self.colors = {
        {1, 0, 0}, -- Red
        {0, 0, 1}, -- Blue
        {1, 1, 0}  -- Yellow
    }
    
    -- Define wire objects with colors
    self.wires = {
        {
            color = {1, 0, 0}, -- Red
            x = 200,
            y = 300,
            width = 120,
            height = 30,
            connected = false,
            dragging = false,
            offsetX = 0,
            offsetY = 0,
            connectedTo = nil,
            startX = 200,
            startY = 300
        },
        {
            color = {0, 0, 1}, -- Blue
            x = 200,
            y = 350,
            width = 120,
            height = 30,
            connected = false,
            dragging = false,
            offsetX = 0,
            offsetY = 0,
            connectedTo = nil,
            startX = 200,
            startY = 350
        },
        {
            color = {1, 1, 0}, -- Yellow
            x = 200,
            y = 400,
            width = 120,
            height = 30,
            connected = false,
            dragging = false,
            offsetX = 0,
            offsetY = 0,
            connectedTo = nil,
            startX = 200,
            startY = 400
        }
    }
    
    -- Define port positions
    self.ports = {
        {color = {1, 0, 0}, x = 400, y = 200, width = 40, height = 40, connected = false, highlight = false}, -- Red
        {color = {0, 0, 1}, x = 400, y = 250, width = 40, height = 40, connected = false, highlight = false}, -- Blue
        {color = {1, 1, 0}, x = 400, y = 300, width = 40, height = 40, connected = false, highlight = false}  -- Yellow
    }
    
    -- Game state
    self.completed = false
    self.showInstructions = true
    self.instructionTimer = 0
    
    -- Debug flag
    self.debug = false
end

function WireGame:update(dt)
    if self.showInstructions then
        self.instructionTimer = self.instructionTimer + dt
        if self.instructionTimer >= 5 then
            self.showInstructions = false
        end
    end
    
    -- Update wire positions when dragging
    for _, wire in ipairs(self.wires) do
        if wire.dragging then
            local x, y = love.mouse.getPosition()
            wire.x = x - wire.offsetX
            wire.y = y - wire.offsetY
            
            -- Check if wire is near a port
            for _, port in ipairs(self.ports) do
                if not port.connected and wire.color[1] == port.color[1] and 
                   wire.color[2] == port.color[2] and 
                   wire.color[3] == port.color[3] then
                    local dx = (wire.x + wire.width/2) - (port.x + port.width/2)
                    local dy = (wire.y + wire.height/2) - (port.y + port.height/2)
                    local distance = math.sqrt(dx * dx + dy * dy)
                    if distance < 50 then
                        port.highlight = true
                    else
                        port.highlight = false
                    end
                end
            end
        end
    end
    
    -- Check if all wires are connected
    local allConnected = true
    for _, wire in ipairs(self.wires) do
        if not wire.connected then
            allConnected = false
            break
        end
    end
    self.completed = allConnected
end

function WireGame:draw()
    -- Draw background
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.background, 0, 0, 0, 800/self.background:getWidth(), 600/self.background:getHeight())
    
    -- Draw solar panel and charge controller
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.solar_panel, 350, 150, 0, 4, 4)
    love.graphics.draw(self.charge_controller, 450, 150, 0, 4, 4)
    
    -- Draw connection lines for connected wires
    for _, wire in ipairs(self.wires) do
        if wire.connected and wire.connectedTo then
            local port = wire.connectedTo
            love.graphics.setColor(wire.color)
            love.graphics.setLineWidth(5)
            love.graphics.line(
                wire.startX, 
                wire.startY, 
                port.x + port.width/2, 
                port.y + port.height/2
            )
            love.graphics.setLineWidth(1)
        end
    end
    
    -- Draw ports
    for _, port in ipairs(self.ports) do
        if port.highlight then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", port.x + port.width/2, port.y + port.height/2, port.width/2 + 5)
        end
        love.graphics.setColor(port.color)
        love.graphics.circle("fill", port.x + port.width/2, port.y + port.height/2, port.width/2)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.circle("line", port.x + port.width/2, port.y + port.height/2, port.width/2)
    end
    
    -- Draw wire start points (circles on the left)
    for _, wire in ipairs(self.wires) do
        love.graphics.setColor(wire.color)
        love.graphics.circle("fill", wire.startX, wire.startY, 20)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.circle("line", wire.startX, wire.startY, 20)
    end
    
    -- Draw wires being dragged
    for _, wire in ipairs(self.wires) do
        if wire.dragging then
            love.graphics.setColor(wire.color)
            love.graphics.setLineWidth(5)
            love.graphics.line(
                wire.startX, 
                wire.startY, 
                wire.x + wire.width/2, 
                wire.y + wire.height/2
            )
            love.graphics.setLineWidth(1)
        end
    end
    
    -- Draw instructions
    if self.showInstructions then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Drag the colored wires from the left to their matching ports on the right!", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)
    end
    
    -- Draw completion message
    if self.completed then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 50, 490, 700, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.printf("Great job! Press SPACE to continue", 180, 505, 560, "left")
        love.graphics.draw(self.techHead, 60, 490)
    end
    
    -- Debug info
    if self.debug then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ProggyTiny)
        love.graphics.print("Mouse: " .. love.mouse.getX() .. ", " .. love.mouse.getY(), 10, 10)
        for i, wire in ipairs(self.wires) do
            love.graphics.print("Wire " .. i .. ": " .. (wire.connected and "Connected" or "Not Connected"), 10, 30 + (i-1)*20)
        end
    end
end

function WireGame:mousepressed(x, y, button)
    if button == 1 then
        for _, wire in ipairs(self.wires) do
            if not wire.connected then
                -- Check if mouse is near the wire's start point
                local dx = x - wire.startX
                local dy = y - wire.startY
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < 20 then
                    wire.dragging = true
                    wire.offsetX = x - wire.x
                    wire.offsetY = y - wire.y
                    break
                end
            end
        end
    end
end

function WireGame:mousereleased(x, y, button)
    if button == 1 then
        for _, wire in ipairs(self.wires) do
            if wire.dragging then
                wire.dragging = false
                -- Check if wire is near its matching port
                for _, port in ipairs(self.ports) do
                    if not port.connected and wire.color[1] == port.color[1] and 
                       wire.color[2] == port.color[2] and 
                       wire.color[3] == port.color[3] then
                        local dx = (wire.x + wire.width/2) - (port.x + port.width/2)
                        local dy = (wire.y + wire.height/2) - (port.y + port.height/2)
                        local distance = math.sqrt(dx * dx + dy * dy)
                        if distance < 50 then
                            wire.connected = true
                            wire.connectedTo = port
                            port.connected = true
                            break
                        end
                    end
                end
                -- Reset highlight for all ports
                for _, port in ipairs(self.ports) do
                    port.highlight = false
                end
            end
        end
    end
end

function WireGame:keypressed(key)
    if key == "escape" then
        GameState = "pause"
    elseif key == "space" and self.completed then
        GameState = "game_over"
    elseif key == "d" then
        self.debug = not self.debug
    end
end

return WireGame 