:- dynamic(status/3).

skill(Slot) :-
    inBattle(PlayerPokemon, EnemyPokemon),
    pokemonInstance(PlayerPokemon, Species, Level, _, _, _),
    ( species_skill(Species, Level, Slot, SkillName) ->
        skill(SkillName, _Type, _Power, Effect),
        ( has_status(PlayerPokemon, sleep) ->
            write('Pokemon Anda tertidur dan tidak bisa bergerak!'), nl,
            retract(status(PlayerPokemon, sleep, Turns)),
            ( Turns > 1 ->
                NewTurns is Turns - 1,
                assertz(status(PlayerPokemon, sleep, NewTurns))
            ; true ),
            enemy_turn(EnemyPokemon, PlayerPokemon)
        ;
            calculate_damage(PlayerPokemon, EnemyPokemon, SkillName, Damage),
            format('~w menggunakan skill "~w"!~n', [Species, SkillName]),
            format('~w menghasilkan damage sebesar ~w.~n', [Species, Damage]),
            apply_damage(EnemyPokemon, Damage),
            apply_effect(Effect, EnemyPokemon),

            ( pokemonInstance(EnemyPokemon, _, _, HPAfter, _, _) ->
                ( HPAfter =< 0 ->
                    write('Musuh berhasil dikalahkan!~n'),
                    give_exp_and_drop(PlayerPokemon, EnemyPokemon),
                    auto_catch_defeated(EnemyPokemon),
                    retract(inBattle(PlayerPokemon, EnemyPokemon)),
                    endGame  % panggil untuk cek apakah boss atau selesai
                ;
                    write('(Giliran monster lawan.)'), nl,
                    enemy_turn(EnemyPokemon, PlayerPokemon)
                )
            ;
                retractall(inBattle(PlayerPokemon, EnemyPokemon)),
                endGame
            )
        )
    ;
        write('Skill tidak tersedia pada slot tersebut.'), nl, fail
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
    ( effectiveness(Type, DefenderType, TypeModifier) -> true ; TypeModifier = 1 ),
    ( AttackerType == Type -> STAB = 1.5 ; STAB = 1 ),
    Damage is floor((Power * ATK) / (DEF * 0.2) * TypeModifier * STAB).

apply_damage(ID, Damage) :-
    pokemonInstance(ID, Species, Level, HP, ATK, DEF),
    NewHP is HP - Damage,
    retract(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    ( NewHP =< 0 ->
        assertz(pokemonInstance(ID, Species, Level, 0, ATK, DEF)),
        format('~w telah dikalahkan!~n', [Species])
    ;
        assertz(pokemonInstance(ID, Species, Level, NewHP, ATK, DEF)),
        format('HP ~w sekarang: ~d~n', [Species, NewHP])
    ).

apply_effect(none, _) :- !.
apply_effect(Effect, Target) :-
    is_effect_list(Effect), !,
    apply_effect_list(Effect, Target).
apply_effect(Effect, Target) :-
    apply_single_effect(Effect, Target).

is_effect_list([]).
is_effect_list([_|_]).

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
