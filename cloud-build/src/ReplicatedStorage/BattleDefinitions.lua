local BattleDefinitions = {
    Verity = {
        Name = "Verity",
        Rarity = "Common",
        Role = "Guardian",
        HP = 120,
        Attack = 18,
        Defense = 28,
        Energy = 3,
        Tags = {"TANK", "BARRIER"},
        SkillName = "Truth Barrier",
        SkillDescription = "Block the next 30 damage.",
        SkillCost = 2,
        Accent = Color3.fromRGB(255, 221, 45),
    },

    Falsity = {
        Name = "Falsity",
        Rarity = "Uncommon",
        Role = "Striker",
        HP = 90,
        Attack = 28,
        Defense = 12,
        Energy = 3,
        Tags = {"ATTACKER", "CONTROL"},
        SkillName = "False Strike",
        SkillDescription = "Deal 24 damage and weaken the target.",
        SkillCost = 2,
        Accent = Color3.fromRGB(55, 145, 255),
    },

    Lovity = {
        Name = "Lovity",
        Rarity = "Epic",
        Role = "Support",
        HP = 100,
        Attack = 12,
        Defense = 18,
        Energy = 3,
        Tags = {"HEALER", "SUPPORT"},
        SkillName = "Love Bloom",
        SkillDescription = "Restore 28 HP to an ally.",
        SkillCost = 2,
        Accent = Color3.fromRGB(255, 105, 180),
    },
}

return BattleDefinitions
