:- dynamic(pokemonInstance/7).

% Saat Pokemon didapat atau dibuat:
% assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF, 0)).

canEvolveAtLevel(Species, Level) :-
    pokemon(Species, _, _, _, _, _, EvolveTo, EvolveLevel),
    EvolveTo \= none,
    Level >= EvolveLevel.

evolusi(Species, EvolvedSpecies) :-
    pokemon(Species, _, _, _, _, _, EvolvedSpecies, EvolveLevel),
    EvolvedSpecies \= none,
    EvolveLevel \= -1.

add_exp(ID, AddEXP) :-
    pokemonInstance(ID, Species, Level, HP, ATK, DEF, CurExp),
    NewEXP is CurExp + AddEXP,
    retract(pokemonInstance(ID, Species, Level, HP, ATK, DEF, CurExp)),
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF, NewEXP)).

try_level_up(ID) :-
    pokemonInstance(ID, Species, LevelNow, HP, ATK, DEF, EXP),
    pokemon(Species, Rarity, _, _, _, _, _, _),
    expForNextLevel(Rarity, LevelNow, EXPNeeded),
    EXP >= EXPNeeded,
    NewEXP is EXP - EXPNeeded,
    NewLevel is LevelNow + 1,

    levelUp(Species, NewLevel, LevelNow, new_stats(NewHP, NewATK, NewDEF)),
    retract(pokemonInstance(ID, Species, LevelNow, HP, ATK, DEF, EXP)),
    assertz(pokemonInstance(ID, Species, NewLevel, NewHP, NewATK, NewDEF, NewEXP)),
    format('%w naik ke level ~d!~n', [Species, NewLevel]),

    (canEvolveAtLevel(Species, NewLevel),
    evolusi(Species, EvolvedSpecies) ->
        pokemon(Species, _, _, BaseHP, BaseATK, BaseDEF, _, _),
        FinalHP is BaseHP + NewLevel * 2,
        FinalATK is BaseATK + NewLevel,
        FinalDEF is BaseDEF + NewLevel,
        retract(pokemonInstance(ID, _, NewLevel, _, _, _, NewEXP)),
        assertz(pokemonInstance(ID, EvolvedSpecies, NewLevel, FinalHP, FinalATK, FinalDEF, NewEXP)),
        format('%w berevolusi menjadi %w!~n', [Species, EvolvedSpecies])
    ; true),

    try_level_up(ID).
try_level_up(_) :- true.
