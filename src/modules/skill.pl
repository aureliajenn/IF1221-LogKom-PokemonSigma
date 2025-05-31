:- dynamic(status/3).

skill(Slot) :-
    inBattle(PlayerPokemon, EnemyPokemon),
    pokemonInstance(PlayerPokemon, Species, Level, HP, ATK, DEF),
    species_skill(Species, Level, Slot, SkillName),
    skill(SkillName, Type, Power, Effect),
    (has_status(PlayerPokemon, sleep) ->
        write('Pokemon Anda tertidur dan tidak bisa bergerak!'), nl,
        retract(status(PlayerPokemon, sleep, Turns)),
        (Turns > 1 -> 
            NewTurns is Turns - 1,
            assertz(status(PlayerPokemon, sleep, NewTurns))
        ;
            true
        ),
        enemy_turn(EnemyPokemon, PlayerPokemon)
    ;
        calculate_damage(PlayerPokemon, EnemyPokemon, SkillName, Damage),
        apply_damage(EnemyPokemon, Damage),
        format('~w menggunakan skill "~w"!~n', [Species, SkillName]),
        format('~w menghasilkan damage sebesar ~w.~n', [Species, Damage]),
        apply_effect(Effect, EnemyPokemon),
        write('(Giliran monster lawan.)'), nl,
        enemy_turn(EnemyPokemon, PlayerPokemon)
    ).

skill(_) :-
    \+ inBattle(_, _),
    write('Anda tidak sedang dalam pertarungan!'), nl, fail.

calculate_damage(AttackerID, DefenderID, SkillName, Damage) :-
    pokemonInstance(AttackerID, AttackerSpecies, _, _, ATK, _),
    pokemonInstance(DefenderID, DefenderSpecies, _, _, _, DEF),
    skill(SkillName, Type, Power, _),
    pokemon(AttackerSpecies, _, AttackerType, _, _, _, _, _),
    pokemon(DefenderSpecies, _, DefenderType, _, _, _, _, _),
    (effectiveness(Type, DefenderType, Modifier) -> true ; Modifier = 1),
    Damage is floor((Power * ATK) / (DEF * 0.2) * Modifier).

apply_damage(PokemonID, Damage) :-
    pokemonInstance(PokemonID, Species, Level, HP, ATK, DEF),
    NewHP is HP - Damage,
    (NewHP =< 0 ->
        retract(pokemonInstance(PokemonID, Species, Level, _, ATK, DEF)),
        assertz(pokemonInstance(PokemonID, Species, Level, 0, ATK, DEF)),
        format('~w telah dikalahkan!~n', [Species])
    ;
        retract(pokemonInstance(PokemonID, Species, Level, _, ATK, DEF)),
        assertz(pokemonInstance(PokemonID, Species, Level, NewHP, ATK, DEF))
    ).

apply_effect(none, _) :- !.
apply_effect(Effect, Target) :-
    is_list(Effect),
    !,
    apply_effect_list(Effect, Target).
apply_effect(Effect, Target) :-
    apply_single_effect(Effect, Target).

apply_effect_list([], _).
apply_effect_list([H|T], Target) :-
    apply_single_effect(H, Target),
    apply_effect_list(T, Target).

apply_single_effect(burn, Target) :-
    assertz(status(Target, burn, 2)),
    write('Pokemon lawan terbakar!'), nl.
apply_single_effect(sleep, Target) :-
    assertz(status(Target, sleep, 2)),
    write('Pokemon lawan tertidur!'), nl.
apply_single_effect(confuse, Target) :-
    assertz(status(Target, confuse, 2)),
    write('Pokemon lawan kebingungan!'), nl.
apply_single_effect(_, _).

has_status(PokemonID, Status) :-
    status(PokemonID, Status, _).