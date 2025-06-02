:- dynamic(inBattle/2).
:- dynamic(pokemonInstance/6).
:- dynamic(inParty/1).

attack :-
    (\+ inBattle(_, _) ->
        write('Tidak ada pertarungan yang sedang berlangsung!'), nl, !
    ;
        inBattle(PlayerID, EnemyID),
        pokemonInstance(PlayerID, PlayerSpecies, _, HP, ATK, _),
        (HP =< 0 ->
            write(PlayerSpecies), write(' sudah tidak bisa bertarung! Ganti Pokemon terlebih dahulu.'), nl, !
        ;
            pokemonInstance(EnemyID, EnemySpecies, _, _, _, DEF),
            PowerSkill = 1,
            pokemon(PlayerSpecies, _, TypeA, _, _, _, _, _),
            pokemon(EnemySpecies, _, TypeT, _, _, _, _, _),
            (effectiveness(TypeA, TypeT, Modifier) -> true ; Modifier = 1),

            DamageFloat is ((PowerSkill * ATK) / (DEF * 0.2)) * Modifier,
            RawDamage is floor(DamageFloat),
            (RawDamage < 1 -> Damage = 1 ; Damage = RawDamage),

            apply_damage(EnemyID, Damage),

            write(PlayerSpecies), write(' menyerang!'), nl,
            write(EnemySpecies), write(' menerima '), write(Damage), write(' damage!'), nl,

            pokemonInstance(EnemyID, _, _, HPBaru, _, _),
            write('HP '), write(EnemySpecies), write(' sekarang: '), write(HPBaru), nl,

            (HPBaru =< 0 ->
                write('Musuh berhasil dikalahkan!'), nl,
                give_exp_and_drop(PlayerID, EnemyID),
                auto_catch_defeated(EnemyID),
                retract(inBattle(PlayerID, EnemyID))
            ;
                enemy_turn(EnemyID, PlayerID), !
            )
        )
    ).


enemy_turn(EnemyID, PlayerID) :-
    pokemonInstance(EnemyID, EnemySpecies, _, _, ATK, _),
    pokemonInstance(PlayerID, PlayerSpecies, _, _, _, DEF),
    Power = 1,
    DamageFloat is ((Power * ATK) / (DEF * 0.2)),
    RawDamage is floor(DamageFloat),
    (RawDamage < 1 -> BaseDamage = 1 ; BaseDamage = RawDamage),
    calculateDamage(EnemyID, PlayerID, BaseDamage, Damage),
    apply_damage(PlayerID, Damage),
    write(EnemySpecies), write(' menyerang balik!'), nl,
    write(PlayerSpecies), write(' menerima '), write(Damage), write(' damage!'), nl,
    pokemonInstance(PlayerID, _, _, HPAfter, _, _),
    write('HP '), write(PlayerSpecies), write(' sekarang: '), write(HPAfter), nl,
    (HPAfter =< 0 ->
        write('Pokemonmu telah dikalahkan!'), nl,
        get_alive_party(AliveList),
        remove_dead_from_list(PlayerID, AliveList, Remaining),
        (Remaining == [] ->
            write('Semua Pokemonmu sudah kalah. Kamu kalah total.'), nl,
            retract(inBattle(PlayerID, EnemyID))
        ;
            write('Silakan pilih Pokemon pengganti:'), nl,
            print_pokemon_list(Remaining, 1),
            write('Masukkan indeks: '),
            catch(read(Index), _, (write('Input tidak valid.'), nl, fail)),
            Index0 is Index - 1,
            length(Remaining, Len),
            (Index0 >= 0, Index0 < Len ->
                nth0(Index0, Remaining, NewPlayerID),
                switch_active_pokemon(NewPlayerID),
                write('Pokemon telah diganti. Pertarungan dilanjutkan!'), nl,
                enemy_turn(EnemyID, NewPlayerID)
            ;
                write('Indeks tidak valid. Pertarungan dibatalkan.'), nl,
                retract(inBattle(PlayerID, EnemyID))
            )
        )
    ; true).

get_alive_party(AliveList) :-
    findall(ID,
        (inParty(ID), pokemonInstance(ID, _, _, HP, _, _), HP > 0),
        AliveList).

remove_dead_from_list(_, [], []).
remove_dead_from_list(ID, [ID|Rest], Result) :-
    remove_dead_from_list(ID, Rest, Result).
remove_dead_from_list(ID, [H|Rest], [H|Result]) :-
    H \= ID,
    remove_dead_from_list(ID, Rest, Result).

switch_active_pokemon(NewPlayerID) :-
    inBattle(_, EnemyID),
    retractall(inBattle(_, _)),
    assertz(inBattle(NewPlayerID, EnemyID)).

print_pokemon_list([], _).
print_pokemon_list([ID|Rest], Index) :-
    pokemonInstance(ID, Species, Level, HP, ATK, DEF),
    format('~d. ~w (Lv ~d, HP: ~d, ATK: ~d, DEF: ~d)~n',
           [Index, Species, Level, HP, ATK, DEF]),
    NextIndex is Index + 1,
    print_pokemon_list(Rest, NextIndex).

give_exp_and_drop(PlayerID, EnemyID) :-
    % Tambahkan EXP (misalnya naikkan level, dll)
    pokemonInstance(PlayerID, Species, Level, HP, ATK, DEF),
    NewLevel is Level + 1,
    retract(pokemonInstance(PlayerID, Species, Level, HP, ATK, DEF)),
    assertz(pokemonInstance(PlayerID, Species, NewLevel, HP, ATK, DEF)),
    format('~w naik ke level ~d!~n', [Species, NewLevel]),

    % Tambahkan item ke tas (misalnya potion atau pokeball)
    add_item_to_bag(potion),
    write('Kamu mendapatkan 1 potion!'), nl.
