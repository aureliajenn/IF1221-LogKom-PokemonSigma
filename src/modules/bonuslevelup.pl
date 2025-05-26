expForNextLevel(Rarity, LevelNow, EXPNeeded) :-
    exp_of_rarity(Rarity, BaseExp),
    EXPNeeded is BaseExp * LevelNow.

% levelUp(Species, NewLevel, BaseLevel, new_stats(NewHP, NewATK, NewDEF))
levelUp(Species, NewLevel, BaseLevel, new_stats(NewHP, NewATK, NewDEF)) :-
    IncLevel is NewLevel - BaseLevel,
    pokemon(Species, _, _, BaseHP, BaseATK, BaseDEF, _, _),
    NewHP is BaseHP + IncLevel * 2,
    NewATK is BaseATK + IncLevel,
    NewDEF is BaseDEF + IncLevel.

evolusi(LastSpecies, NewSpecies) :-
    pokemon(LastSpecies, _, _, _, _, _, NewSpecies, EvolveLevel),
    NewSpecies \= none,
    EvolveLevel > 0.

canEvolveAtLevel(Species, Level) :-
    pokemon(Species, _, _, _, _, _, NewSpecies, EvolveLevel),
    NewSpecies \= none,
    Level >= EvolveLevel.

levelUpInstance(ID, NewLevel) :-
    pokemonInstance(ID, Species, Rarity, _, _, _),
    level(ID, CurrentLevel),
    levelUp(Species, NewLevel, CurrentLevel, new_stats(NewHP, NewATK, NewDEF)),
    retract(pokemonInstance(ID, Species, Rarity, _, _, _)),
    assertz(pokemonInstance(ID, Species, Rarity, NewHP, NewATK, NewDEF)),
    retract(level(ID, _)),
    assertz(level(ID, NewLevel)).
