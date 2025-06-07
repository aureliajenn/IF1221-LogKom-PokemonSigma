:- dynamic(inBattle/2).
:- dynamic(pokemonInstance/6).
:- dynamic(party/1).
:- dynamic(active_pokemon/1).
:- dynamic(pending_encounter/2).

/* Attack */
attack :-
    \+ inBattle(_, _),
    write('Tidak ada pertarungan!'), nl, !.

attack :-
    inBattle(PlayerID, EnemyID),
    ( \+ pokemonInstance(PlayerID, _, _, _, _, _) ->
        write('Pokemonmu tidak ditemukan. Pertarungan dihentikan.'), nl,
        end_battle, !
    ; \+ pokemonInstance(EnemyID, _, _, _, _, _) ->
        write('Musuh sudah tidak ada. Pertarungan berakhir.'), nl,
        end_battle, !
    ;
        pokemonInstance(PlayerID, PlayerSpecies, _, HP, ATK, _),
        ( HP =< 0 ->
            write('Pokemonmu sudah tidak bisa bertarung!'), nl, !
        ;
            pokemonInstance(EnemyID, EnemySpecies, _, _, _, DEF),
            Damage is max(1, floor(ATK / (DEF * 0.2))),
            apply_damage(EnemyID, Damage),
            format('~w menyerang dan memberi ~d damage ke ~w!~n', [PlayerSpecies, Damage, EnemySpecies]),
            ( pokemonInstance(EnemyID, _, _, HPNew, _, _),
              HPNew =< 0 ->
                format('~w telah dikalahkan!~n', [EnemySpecies]),
                give_exp_and_drop(PlayerID, EnemyID),
                auto_catch_after_defeat(EnemyID),
                end_battle
            ;
                enemy_turn(EnemyID, PlayerID)
            )
        )
    ).

/* Enemy Turn */
enemy_turn(EnemyID, PlayerID) :-
    ( \+ pokemonInstance(EnemyID, _, _, _, _, _) -> true
    ; pokemonInstance(EnemyID, _, _, HP, _, _), HP =< 0 -> true
    ;
        pokemonInstance(EnemyID, EnemySpecies, _, _, ATK, _),
        pokemonInstance(PlayerID, PlayerSpecies, _, _, _, DEF),
        BaseDamage is max(1, floor(ATK / (DEF * 0.2))),
        calculateDamage(EnemyID, PlayerID, BaseDamage, FinalDamage),
        apply_damage(PlayerID, FinalDamage),
        format('~w menyerang balik!~n', [EnemySpecies]),
        format('~w menerima ~d damage!~n', [PlayerSpecies, FinalDamage]),

        pokemonInstance(PlayerID, _, _, HPAfter, _, _),
        format('HP ~w sekarang: ~d~n', [PlayerSpecies, HPAfter]),
        nl,

        ( HPAfter =< 0 ->
            write('Pokemonmu telah dikalahkan!'), nl,
            get_alive_party(AliveList),
            remove_dead_from_list(PlayerID, AliveList, Remaining),
            ( Remaining == [] ->
                write('Semua Pokemonmu sudah kalah. Kamu kalah total.'), nl,
                end_battle,
                quit_game
            ;
                choose_pokemon_replacement(Remaining, EnemyID)
            )
        ;
            true
        )
    ).

/* Choose Replacement */
choose_pokemon_replacement(Remaining, EnemyID) :-
    write('Silakan pilih Pokemon pengganti:'), nl,
    print_pokemon_list(Remaining, 1),
    repeat,
    write('Masukkan indeks: '),
    read(Index),
    length(Remaining, Len),
    ( integer(Index), Index >= 1, Index =< Len ->
        nth1(Index, Remaining, NewPlayerID),
        switch_active_pokemon(NewPlayerID),
        pokemonInstance(NewPlayerID, Species, _, _, _, _),
        format('Pokemon telah diganti menjadi ~w!~n', [Species]),
        write('Pertarungan dilanjutkan.'), nl, !
    ;
        write('Indeks tidak valid. Silakan coba lagi.'), nl,
        fail
    ).

/* Get Alive Party */
get_alive_party(AliveList) :-
    party(P),
    findall(ID, (member(ID, P), pokemonInstance(ID, _, _, HP, _, _), HP > 0), AliveList).

/* Remove Dead */
remove_dead_from_list(_, [], []).
remove_dead_from_list(ID, [ID|Rest], Result) :- remove_dead_from_list(ID, Rest, Result).
remove_dead_from_list(ID, [H|Rest], [H|Result]) :-
    H \= ID, remove_dead_from_list(ID, Rest, Result).

/* Switch Active */
switch_active_pokemon(NewPlayerID) :-
    inBattle(_, EnemyID),
    retractall(inBattle(_, _)),
    assertz(inBattle(NewPlayerID, EnemyID)).

/* Print Pokemon List */
print_pokemon_list([], _).
print_pokemon_list([ID|Rest], Index) :-
    pokemonInstance(ID, Species, Level, HP, ATK, DEF),
    format('~d. ~w (Lv ~d, HP: ~d, ATK: ~d, DEF: ~d)~n',
        [Index, Species, Level, HP, ATK, DEF]),
    NextIndex is Index + 1,
    print_pokemon_list(Rest, NextIndex).

/* EXP and Drop */
give_exp_and_drop(PlayerID, EnemyID) :-
    pokemonInstance(PlayerID, Species, Level, HP, ATK, DEF),
    NewLevel is Level + 1,
    retract(pokemonInstance(PlayerID, Species, Level, HP, ATK, DEF)),
    assertz(pokemonInstance(PlayerID, Species, NewLevel, HP, ATK, DEF)),
    format('~w naik ke level ~d!~n', [Species, NewLevel]),
    add_item_to_bag(potion),
    write('Kamu mendapatkan 1 potion!'), nl.

/* Auto Catch setelah Pokemon liar dikalahkan */
auto_catch_after_defeat(EnemyID) :-
    pokemonInstance(EnemyID, Species, Level, HP, ATK, DEF),
    retractall(encountered(_, _, _, _, _, _)),
    assertz(encountered(Species, common, Level, HP, ATK, DEF)),

    write('Pokemon dikalahkan, mencoba menangkap otomatis...'), nl,
    ( find_empty_pokeball_slot(_) ->
        store_encountered_pokemon,
        write('Pokemon berhasil ditangkap dan disimpan!'), nl
    ;
        write('Tidak ada Pokeball kosong! Pokemon tidak bisa ditangkap.'), nl
    ),

    retractall(encountered(_, _, _, _, _, _)).

/* End Battle */
end_battle :-
    retractall(inBattle(_, _)),
    retractall(active_pokemon(_)),
    retractall(pending_encounter(_, _)),
    write('Pertarungan berakhir.'), nl.

/* Quit Game */
quit_game :-
    write('Game berakhir. Terima kasih telah bermain!'), nl,
    halt.
