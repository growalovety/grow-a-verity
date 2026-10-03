local Variants = {
    Verity = {
        Name="Verity", Rarity="Common", Color=Color3.fromRGB(255,221,45), Personality="Helpful",
        Income=8, GrowthTime=45, HarvestValue=35, ProductionTime=25, SeedRarity="Common",
        SeedSource="Verity Guardian", Role="Guardian", Tags={"TANK","BARRIER"},
        SkillName="Truth Barrier", SkillDescription="Blocks the next hit.",
    },
    Falsity = {
        Name="Falsity", Rarity="Uncommon", Color=Color3.fromRGB(55,145,255), Personality="Deceptive",
        Income=14, GrowthTime=60, HarvestValue=60, ProductionTime=30, SeedRarity="Uncommon",
        SeedSource="Falsity Guardian", Role="Striker", Tags={"ATTACKER","CONTROL"},
        SkillName="False Strike", SkillDescription="Heavy hit with Daze chance.",
    },
    Cruelty = {
        Name="Cruelty", Rarity="Rare", Color=Color3.fromRGB(220,55,55), Personality="Aggressive",
        Income=24, GrowthTime=90, HarvestValue=110, ProductionTime=40, SeedRarity="Rare",
        SeedSource="Cruelty Guardian", Role="Damage", Tags={"ATTACKER","DOT"},
        SkillName="Bleeding Edge", SkillDescription="Heavy strike with Bleed.",
    },
    Hopeity = {
        Name="Hopeity", Rarity="Legendary", Color=Color3.fromRGB(155,105,255), Personality="Radiant",
        Income=65, GrowthTime=150, HarvestValue=300, ProductionTime=65, SeedRarity="Legendary",
        SeedSource="Hopeity Guardian", Role="Buffer", Tags={"SUPPORT","BUFF"},
        SkillName="Hope Pulse", SkillDescription="Heals and empowers the team.",
    },
    Nullity = {
        Name="Nullity", Rarity="Mythic", Color=Color3.fromRGB(55,40,75), Personality="Unknowable",
        Income=100, GrowthTime=210, HarvestValue=500, ProductionTime=90, SeedRarity="Mythic",
        SeedSource="Nullity Guardian", Role="Disruptor", Tags={"CONTROL","DRAIN"},
        SkillName="Null Field", SkillDescription="Drains energy and weakens the enemy.",
    },
    Lovity = {
        Name="Lovity", Rarity="Epic", Color=Color3.fromRGB(255,105,180), Personality="Affectionate",
        Income=38, GrowthTime=120, HarvestValue=175, ProductionTime=50, SeedRarity="Epic",
        SeedSource="Lovity Guardian", Role="Support", Tags={"HEALER","SUPPORT"},
        SkillName="Love Bloom", SkillDescription="Restores health and cleanses.",
    },
}
return Variants