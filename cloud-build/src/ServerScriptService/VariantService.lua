local Variants = require(game:GetService("ReplicatedStorage"):WaitForChild("VariantDefinitions"))

local VariantService = {}

local RarityWeights = {
    Common = 60,
    Uncommon = 25,
    Rare = 10,
    Epic = 5,
}

function VariantService.Roll()
    local pool = {}
    local total = 0
    for name, definition in pairs(Variants) do
        local weight = RarityWeights[definition.Rarity] or 0
        if weight > 0 then
            total += weight
            table.insert(pool, {Name = name, Weight = weight})
        end
    end

    local roll = math.random() * total
    local cursor = 0
    for _, entry in ipairs(pool) do
        cursor += entry.Weight
        if roll <= cursor then
            return entry.Name
        end
    end
    return pool[#pool].Name
end

function VariantService.Get(name)
    return Variants[name]
end

function VariantService.GetAll()
    return Variants
end

return VariantService
