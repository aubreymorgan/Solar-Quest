require("menu")
require("survey")

-- Global game state: "menu" or "survey"
GameState = "menu"

function love.load()
    Menu:load()
    Survey:load()
end

function love.update(dt)
    if GameState == "menu" then
        Menu:update(dt)
    elseif GameState == "survey" then
        Survey:update(dt)
    end
end

function love.draw()   
    if GameState == "menu" then
        Menu:draw()
    elseif GameState == "survey" then
        Survey:draw()
    end
end

-- implements keypressed actions defined in specific GameState
function love.keypressed(key)
    if GameState == "menu" then
        Menu:keypressed(key)
    elseif GameState == "survey" then
        Survey:keypressed(key)
    end
end