expForNextLevel(Rarity, LevelNow, EXPNeeded) :-
    exp_of_rarity(Rarity, BaseExp),
    EXPNeeded is BaseExp * LevelNow.

levelUp(Species, NewLevel, BaseLevel, new_stats(NewHP, NewATK, NewDEF)) :-
    IncLevel is NewLevel - BaseLevel,
    pokemon(Species, _, _, BaseHP, BaseATK, BaseDEF, _, _),
    NewHP is BaseHP + NewLevel * 2,
    NewATK is BaseATK + NewLevel,
    NewDEF is BaseDEF + NewLevel.

evolusi(LastSpecies, NewSpecies) :-
    pokemon(LastSpecies, _, _, _, _, _, NewSpecies, EvolveLevel),
    NewSpecies \= none,
    EvolveLevel > 0.

canEvolveAtLevel(Species, Level) :-
    pokemon(Species, _, _, _, _, _, NewSpecies, EvolveLevel),
    NewSpecies \= none,
    Level >= EvolveLevel.

levelUpInstance(ID, NewLevel) :-
    pokemonInstance(ID, Species, _, _, _, _),
    pokemon(Species, _, _, BaseHP, BaseATK, BaseDEF, _, _),
    NewHP is BaseHP + NewLevel * 2,
    NewATK is BaseATK + NewLevel,
    NewDEF is BaseDEF + NewLevel,
    retract(pokemonInstance(ID, Species, _, _, _, _)),
    assertz(pokemonInstance(ID, Species, NewLevel, NewHP, NewATK, NewDEF)).