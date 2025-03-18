local gameFeatures = {}

local wireLevel = 1
local solarLevel = 1

function gameFeatures.init()
    print("Game Features Module Initialized")
end

function gameFeatures.getWireLevel()
    return wireLevel
end

function gameFeatures.setWireLevel(level)
    wireLevel = level
end

function gameFeatures.getSolarLevel()
    return solarLevel
end

function gameFeatures.setSolarLevel(level)
    solarLevel = level
end

return gameFeatures
