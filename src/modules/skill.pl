:- dynamic(status/3).
:- dynamic(active_pokemon/1).

/* RULE: Menggunakan skill dari slot tertentu selama battle atau luar battle */
skill(Slot) :-
    ( inBattle(_, _) ->
        inBattle(PlayerPokemon, _)
    ; active_pokemon(PlayerPokemon) ->
        true
    ;
        write('Tidak ada Pokemon aktif!'), nl, fail
    ),
    pokemonInstance(PlayerPokemon, Species, Level, _, _, _),
    ( species_skill(Species, Level, Slot, SkillName) ->
        skill(SkillName, Type, Power, EffectList),
        ( has_status(PlayerPokemon, sleep) ->
            write('Pokemon Anda tertidur dan tidak bisa bergerak!'), nl,
            retract(status(PlayerPokemon, sleep, Turns)),
            ( Turns > 1 ->
                NewTurns is Turns - 1,
                assertz(status(PlayerPokemon, sleep, NewTurns))
            ; true ),
            ( inBattle(_, EnemyPokemon) -> enemy_turn(EnemyPokemon, PlayerPokemon) ; true )
        ;
            ( Power \= none ->
                ( inBattle(_, EnemyPokemon) -> true ; EnemyPokemon = dummy ),
                calculate_damage(PlayerPokemon, EnemyPokemon, SkillName, Damage),
                format('~w menggunakan skill "~w"!~n', [Species, SkillName]),
                format('~w menghasilkan damage sebesar ~w.~n', [Species, Damage]),
                ( EnemyPokemon \= dummy -> apply_damage(EnemyPokemon, Damage) ; true )
            ;
                format('~w menggunakan skill "~w"!~n', [Species, SkillName])
            ),
            ( inBattle(_, EnemyPokemon) -> maybe_apply_effect(EffectList, EnemyPokemon) ; true ),
            ( SkillName = rest -> maybe_apply_effect(EffectList, PlayerPokemon) ; true ),

            ( inBattle(_, EnemyPokemon),
                pokemonInstance(EnemyPokemon, _, _, HPAfter, _, _) ->
                    ( HPAfter =< 0 ->
                        format('Musuh berhasil dikalahkan!~n', []),
                        give_exp_and_drop(PlayerPokemon, EnemyPokemon),
                        auto_catch_defeated(EnemyPokemon),
                        retract(inBattle(PlayerPokemon, EnemyPokemon)),
                        endGame
                    ;
                        format('(Giliran monster lawan.)~n', []),
                        enemy_turn(EnemyPokemon, PlayerPokemon)
                    )
                ;
                % Ini jalan jika inBattle tapi pokemonInstance musuh sudah tidak ada
                ( inBattle(_, EnemyPokemon) ->
                    retractall(inBattle(PlayerPokemon, EnemyPokemon)),
                    endGame
                ; true )
            )

        )
    ;
        write('Skill tidak tersedia pada slot tersebut.'), nl, fail
    ).

skill(_) :-
    \+ inBattle(_, _), \+ active_pokemon(_),
    write('Anda tidak sedang dalam pertarungan dan tidak ada Pokemon aktif!'), nl, fail.

/* RULE: Hitung damage skill berdasarkan ATK, DEF, tipe, dan STAB */
calculate_damage(AttackerID, DefenderID, SkillName, Damage) :-
    pokemonInstance(AttackerID, AttackerSpecies, _, _, ATK, _),
    pokemonInstance(DefenderID, DefenderSpecies, _, _, _, DEF),
    skill(SkillName, Type, Power, _),
    pokemon(AttackerSpecies, _, AttackerType, _, _, _, _, _),
    pokemon(DefenderSpecies, _, DefenderType, _, _, _, _, _),
    ( effectiveness(Type, DefenderType, TypeModifier) -> true ; TypeModifier = 1 ),
    ( AttackerType == Type -> STAB = 1.5 ; STAB = 1 ),
    Damage is floor((Power * ATK) / (DEF * 0.2) * TypeModifier * STAB).

/* RULE: Kurangi HP target */
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

/* RULE: Efek acak - hanya terjadi secara probabilistik */
maybe_apply_effect(none, _) :- !.
maybe_apply_effect([], _) :- !.
maybe_apply_effect([Effect|Rest], Target) :-
    maybe_apply_single_effect(Effect, Target),
    maybe_apply_effect(Rest, Target).

maybe_apply_single_effect(confuse_20, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 20 ->
        assertz(status(Target, confuse, 2)),
        write('Efek confuse berhasil diterapkan!~n')
    ;
        write('Efek confuse gagal diterapkan.~n')
    ).
maybe_apply_single_effect(failed_atk_20_percent, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 20 ->
        assertz(status(Target, failed_attack, 1)),
        write('Serangan musuh bisa gagal di giliran berikutnya!~n')
    ;
        write('Efek gagal serang tidak terjadi.~n')
    ).
maybe_apply_single_effect(minus_3_hp_2_turns, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 70 ->
        assertz(status(Target, dot_3hp, 2)),
        write('Musuh akan kehilangan 3 HP per turn selama 2 turn!~n')
    ;
        write('Efek damage over time gagal diterapkan.~n')
    ).
maybe_apply_single_effect(minus_5_hp_2_turns, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 60 ->
        assertz(status(Target, dot_5hp, 2)),
        write('Musuh akan kehilangan 5 HP per turn selama 2 turn!~n')
    ;
        write('Efek damage over time gagal diterapkan.~n')
    ).
maybe_apply_single_effect(minus_3_atk_perm, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 80 ->
        pokemonInstance(Target, Species, Level, HP, ATK, DEF),
        NewATK is max(0, ATK - 3),
        retract(pokemonInstance(Target, Species, Level, HP, ATK, DEF)),
        assertz(pokemonInstance(Target, Species, Level, HP, NewATK, DEF)),
        write('ATK musuh berkurang secara permanen sebesar 3 poin!~n')
    ;
        write('Debuff ATK gagal diterapkan.~n')
    ).
maybe_apply_single_effect(heal_40_percent, Target) :-
    random_fix(1, 100, Roll),
    ( Roll =< 90 ->
        pokemonInstance(Target, Species, Level, HP, ATK, DEF),
        pokemon(Species, _, _, BaseHP, _, _, _, _),
        MaxHP is BaseHP + Level * 2,
        Heal is floor(MaxHP * 0.4),
        NewHP is min(MaxHP, HP + Heal),
        retract(pokemonInstance(Target, Species, Level, HP, ATK, DEF)),
        assertz(pokemonInstance(Target, Species, Level, NewHP, ATK, DEF)),
        format('~w memulihkan HP sebesar ~d!~n', [Species, Heal])
    ;
        write('Pemulihan HP gagal terjadi.~n')
    ).
maybe_apply_single_effect(_, _) :- true.

has_status(PokemonID, Status) :-
    status(PokemonID, Status, _).

/* RANDOM FIX IMPLEMENTATION */
random_fix(Min, Max, Result) :-
    Range is Max - Min + 1,
    random(RawFloat),
    Temp is RawFloat * Range,
    Int is truncate(Temp),
    Result is Min + Int.
