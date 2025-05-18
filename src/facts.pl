/*fakta pokemon(Species, Rarity, Type, BaseHP, BaseATK, BaseDEF, EvolveTo, EvolveLVL)*/
pokemon(charmander, common, fire, 35, 15, 10, charmeleon, 15).
pokemon(squirtle, common, water, 40, 12, 15, wartortle, 15).
pokemon(pidgey, common, flying, 30, 14, 10, none, -1).
pokemon(charmeleon, common, fire, 57, 26, 21, none, -1).
pokemon(wartortle, common, water, 62, 23, 26, none, -1).
pokemon(pikachu, rare, electric, 30, 16, 10, none, -1).
pokemon(geodude, rare, rock, 30, 20, 25, none, -1).
pokemon(snorlax, epic, 70, 30, 20, none, -1).
pokemon(articuno, legendary, ice, 60, 28, 35, none, -1).

/*fakta rarityValue(Rarity, Value).*/
rarityValue(common,40).
rarityValue(rare,30).
rarityValue(epic,25).
rarityValue(legendary,20).

/*fakta skill(SkillName, Tipe, Power, EfekTambahan).*/
skill(tackle,normal,35,none).
skill(scratch, normal, 35, none).
skill(ember,fire,40,[burn_10_percent, -3_hp_2_turns]).
skill(water_gun, water, 40, none).
skill(gust, flying, 30, none).
skill(fire_spin, fire, 35, [_,-5_hp_2_turns]).
skill(bubble, water, 30, []). %butuh rev
skill(thunder_shock, electric, 40, []). %butuh rev
skill(quick_attack, normal, 30, []). %butuh rev
skill(rock_throw, rock, 50, none).
skill(rest, normal, none, []). %butuh rev
skill(ice_shard, ice, 40, []). %butuh rev

/*fakta exp_of_rarity(Rarity, BaseExpRarity).*/
exp_of_rarity(common,20).
exp_of_rarity(rare,30).
exp_of_rarity(epic,40).
exp_of_rarity(legendary,50).

/*fakta exp_given_rarity(Rarity,BaseExpGivenRarity).*/
exp_given_rarity(common,10).
exp_given_rarity(rare,20).
exp_given_rarity(epic,30).
exp_given_rarity(legendary,40).

/*fakta skill slot species_skill(Species, Level, SkillSlot, SkillName).*/
species_skill(charmander,1,1,scratch).
species_skill(charmander,10,2,ember).
%belum selesai


/*fakta effectiveness(TypeAttack, TypeTarget, Modifier).*/
effectiveness(fire,ice,1.5).
effectiveness(fire,water,0.5).
effectiveness(fire,rock,0.5).
effectiveness(fire,fire,0.5).
effectiveness(water,fire,1.5).
effectiveness(water,rock,1.5).
effectiveness(water,electric,0.5).
effectiveness(water,water,0.5).
effectiveness(electric,water,1.5).
effectiveness(electric,flying,1.5).
effectiveness(electric,electric,0.5).
effectiveness(electric,rock,0.5).
effectiveness(flying,electric,0.5).
effectiveness(flying,rock,0.5).
effectiveness(flying,ice,0.5).
effectiveness(rock,fire,1.5).
effectiveness(rock,flying,1.5).
effectiveness(rock,ice,1.5).
effectiveness(rock,water,0.5).
effectiveness(rock,rock,0.5).
effectiveness(ice,flying,1.5).
effectiveness(ice,fire,0.5).
effectiveness(ice,rock,0.5).
effectiveness(ice,water,0.5).
effectiveness(ice,ice,0.5).
effectiveness(normal,rock,0.5).
effectiveness(_,_,1).

/**/