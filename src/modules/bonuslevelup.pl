:- dynamic(pokemonInstance/7).

% Saat Pokemon didapat atau dibuat:
% assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF, 0)).

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
        retract(pokemonInstance(ID, _, NewLevel, NewHP, NewATK, NewDEF, NewEXP)),
        assertz(pokemonInstance(ID, EvolvedSpecies, NewLevel, NewHP, NewATK, NewDEF, NewEXP)),
        format('🧬 %w berevolusi menjadi %w!~n', [Species, EvolvedSpecies])
    ; true),

    try_level_up(ID).  % lanjutkan jika masih bisa level up
try_level_up(_) :- true.  % berhenti jika tidak cukup EXP
