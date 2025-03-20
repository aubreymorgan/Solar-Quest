require("menu")
require("survey")
require("pause")

-- Global game state: "menu", "pause", "survey", "unpacking"
GameState = "menu"

function love.load()
    Menu:load()     -- Load Main Menu Screen
    Pause:load()    -- Load Pause Screen
    Survey:load()   -- Load Game Phase: Pre-Installation and Site Survey
    --Sai's code here   -- Load Game Phase: Unpacking and Inspecting the Kit
end

function love.update(dt)
    if GameState == "menu" then
        Menu:update(dt)
    elseif GameState == "pause" then
        Pause:update(dt)
    elseif GameState == "survey" then
        -- Update Game Phase: Pre-Installation and Site Survey 
        Survey:update(dt)
    elseif GameState == "unpacking" then
        -- Update Game phase: Unpacking and Inspecting the Kit
        --Sai's code here
    end
end

function love.draw()   
    if GameState == "menu" then
        Menu:draw()
    elseif GameState == "pause" then
        Pause:draw()
    elseif GameState == "survey" then
        -- Draw Game Phase: Pre-Installation and Site Survey
        Survey:draw()
    elseif GameState == "unpacking" then
        -- Draw Game phase: Unpacking and Inspecting the Kit
        --Sai's code here
    end
end

-- Implements keypressed actions defined in specific GameState
function love.keypressed(key)
    if GameState == "menu" then
        Menu:keypressed(key)
    elseif GameState == "pause" then
        Pause:keypressed(key)
    elseif GameState == "survey" then
        Survey:keypressed(key)
    elseif GameState == "unpacking" then
        --Sai's code here
    end
end