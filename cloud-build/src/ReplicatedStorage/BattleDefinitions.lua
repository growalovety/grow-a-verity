local BattleDefinitions = {
    Verity = {
        Name="Verity", Rarity="Common", Role="Guardian", HP=105, Attack=19, Defense=22, Energy=5, MaxEnergy=5,
        Tags={"TANK","BARRIER"}, Accent=Color3.fromRGB(255,221,45),
        AttackName="Truth Strike", SkillName="Truth Barrier", GuardName="Shield Stance",
        SkillDescription="Gain Barrier: the next hit deals 60% less damage.", SkillCost=2,
        SkillType="BARRIER", Status="BARRIER",
    },
    Falsity = {
        Name="Falsity", Rarity="Common", Role="Striker", HP=95, Attack=23, Defense=17, Energy=5, MaxEnergy=5,
        Tags={"ATTACKER","CONTROL"}, Accent=Color3.fromRGB(55,145,255),
        AttackName="False Swipe", SkillName="False Strike", GuardName="Fake Out",
        SkillDescription="Heavy hit with a chance to Daze the enemy.", SkillCost=2,
        SkillType="CONTROL", Status="DAZE",
    },
    Lovity = {
        Name="Lovity", Rarity="Common", Role="Support", HP=100, Attack=18, Defense=20, Energy=5, MaxEnergy=5,
        Tags={"HEALER","SUPPORT"}, Accent=Color3.fromRGB(255,105,180),
        AttackName="Heart Tap", SkillName="Love Bloom", GuardName="Warm Embrace",
        SkillDescription="Restore health and cleanse one negative status.", SkillCost=2,
        SkillType="HEAL", Status="REGEN",
    },
    Cruelty = {
        Name="Cruelty", Rarity="Rare", Role="Damage", HP=92, Attack=26, Defense=15, Energy=5, MaxEnergy=5,
        Tags={"ATTACKER","DOT"}, Accent=Color3.fromRGB(220,55,55),
        AttackName="Cruel Claw", SkillName="Bleeding Edge", GuardName="Predator Stance",
        SkillDescription="Heavy strike that applies a damage-over-time Bleed.", SkillCost=2,
        SkillType="DOT", Status="BLEED",
    },
}
return BattleDefinitions