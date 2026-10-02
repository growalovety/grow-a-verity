local BattleDefinitions = {
    Verity = {
        Name = "Verity", Rarity = "Common", Role = "Guardian",
        HP = 105, Attack = 19, Defense = 22, Energy = 3,
        Tags = {"TANK", "BARRIER"},
        AttackName = "Truth Strike", SkillName = "Truth Barrier", GuardName = "Shield Stance",
        SkillDescription = "Raise a barrier and reduce the next hit.",
        SkillCost = 2, Accent = Color3.fromRGB(255, 221, 45),
    },
    Falsity = {
        Name = "Falsity", Rarity = "Common", Role = "Striker",
        HP = 95, Attack = 23, Defense = 17, Energy = 3,
        Tags = {"ATTACKER", "CONTROL"},
        AttackName = "False Swipe", SkillName = "False Strike", GuardName = "Fake Out",
        SkillDescription = "Deal bonus damage with a deceptive strike.",
        SkillCost = 2, Accent = Color3.fromRGB(55, 145, 255),
    },
    Lovity = {
        Name = "Lovity", Rarity = "Common", Role = "Support",
        HP = 100, Attack = 18, Defense = 20, Energy = 3,
        Tags = {"HEALER", "SUPPORT"},
        AttackName = "Heart Tap", SkillName = "Love Bloom", GuardName = "Warm Embrace",
        SkillDescription = "Restore health with a healing bloom.",
        SkillCost = 2, Accent = Color3.fromRGB(255, 105, 180),
    },
}
return BattleDefinitions