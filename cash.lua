local cash = {}

local availableUnits = 500  -- Starting currency

function cash.init()
    print("Cash Module Initialized")
end

function cash.getUnits()
    return availableUnits
end

function cash.spendUnits(amount)
    if availableUnits >= amount then
        availableUnits = availableUnits - amount
        return true
    else
        print("Not enough units!")
        return false
    end
end

return cash
