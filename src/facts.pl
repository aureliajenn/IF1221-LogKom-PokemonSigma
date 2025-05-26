/*fakta pokemon(Species, Rarity, Type, BaseHP, BaseATK, BaseDEF, EvolveTo, EvolveLVL)*/
pokemon(charmander, common, fire, 35, 15, 10, charmeleon, 15).
pokemon(squirtle, common, water, 40, 12, 15, wartortle, 15).
pokemon(pidgey, common, flying, 30, 14, 10, none, -1).
pokemon(charmeleon, common, fire, 55, 25, 20, none, -1).
pokemon(wartortle, common, water, 60, 22, 25, none, -1).
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
species_skill(charmander,5,1,scratch).
species_skill(charmander,10,2,ember).
species_skill(charmeleon,15,1,ember).
species_skill(charmeleon,15,2,fire_spin).
species_skill(squirtle,5,1,tackle).
species_skill(squirtle,10,2,water_gun).
species_skill(wartortle,15,1,water_gun).
species_skill(wartortle,15,2,bubble).
species_skill(pidgey,5,1,tackle).
species_skill(pidgey,10,2,gust).
species_skill(pikachu,5,1,thunder_shock).
species_skill(pikachu,10,2,quick_attack).
species_skill(geodude,5,1,tackle).
species_skill(geodude,10,2,rock_throw).
species_skill(snorlax,5,1,tackle).
species_skill(snorlax,10,2,rest).
species_skill(articuno,5,1,gust).
species_skill(articuno,10,2,ice_shard).


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

/* fakta Pemain */
:- dynamic player/4.

/* fakta Map, Pokemon Liar yang Tersembunyi, dan Pokemon di Luar Rumput */
:- dynamic grass/2.
:- dynamic pokemon_liar/4.
:- dynamic pokemon_outside/2.

/* fakta ukuran Map */
size_of_map(8,8).

/* fakta Pokemon (Dinamis) */
:- dynamic pokemonInstance/6.

/* fakta Party */
:- dynamic party/1.

/* fakta Storage */
:- dynamic storage/1.

/* fakta InBattle */
:- dynamic inBattle/2.

/* fakta Tas/Bag */
:- dynamic bag/2.

/* fakta Immune Boss */
:- dynamic immune/2.
immune(mewtwo, burn).
immune(mewtwo, paralyze).
immune(mewtwo, sleep).
immune(mewtwo, confuse).
immune(mewtwo, freeze).

/* fakta item(Name,Type,Effect) */
:- dynamic item/3.
item(pokeball, ball, catch).
item(potion, medicine, heal(0.2)).
item(super_potion, medicine, heal(0.5)).
item(hyper_potion, medicine, heal(1)).

/*fakta encountered(Name,HP,ATK,DEF,Level,Exp).*/
:- dynamic encountered/6.