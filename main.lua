require("menu")
require("survey")
require("pause")

-- Global game state: "menu" or "survey"
GameState = "menu"

function love.load()
    Menu:load()
    Survey:load()
    Pause:load()
end

function love.update(dt)
    if GameState == "menu" then
        Menu:update(dt)
    elseif GameState == "survey" then
        Survey:update(dt)
    elseif GameState == "pause" then
        Pause:update(dt)
    end
end

function love.draw()   
    if GameState == "menu" then
        Menu:draw()
    elseif GameState == "survey" then
        Survey:draw()
    elseif GameState == "pause" then
        Pause:draw()
    end
end

-- implements keypressed actions defined in specific GameState
function love.keypressed(key)
    if GameState == "menu" then
        Menu:keypressed(key)
    elseif GameState == "survey" then
        Survey:keypressed(key)
    elseif GameState == "pause" then
        Pause:keypressed(key)
    end
end