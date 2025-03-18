local solarSystem = {}

-- Require gameFeatures to prevent nil error
local gameFeatures = require("gameFeatures")

local energyPerSecond = {0.5, 1, 1.5}
local solarLimits = {200, 400, math.huge}
local currentEnergy = 0
local solarEnergyTimer = 0

function solarSystem.init()
    print("Solar System Module Initialized")
end

function solarSystem.update(dt)
    solarEnergyTimer = solarEnergyTimer + dt
    if solarEnergyTimer >= 1 then
        local wireBonus = gameFeatures.getWireLevel()
        local solarBonus = gameFeatures.getSolarLevel()

        if currentEnergy < solarLimits[solarBonus] then
            currentEnergy = currentEnergy + energyPerSecond[wireBonus]
        end
        solarEnergyTimer = 0
    end
end

function solarSystem.getEnergy()
    return currentEnergy
end

function solarSystem.setEnergy(amount)
    currentEnergy = amount
end

return solarSystem
