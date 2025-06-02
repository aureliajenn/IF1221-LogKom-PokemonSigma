:- dynamic(player_pos/2).
:- dynamic(move_left/1).
:- dynamic(inBattle/2).
:- dynamic(pokemonInstance/6).
:- dynamic(party/1).

move(Direction) :-
    inBattle(_, _),
    write('Anda sedang dalam pertarungan! Tidak bisa bergerak.'), nl, !, fail.

move(Direction) :-
    move_left(Moves),
    Moves =< 0,
    write('Permainan sudah berakhir!'), nl, !, fail.

move(Direction) :-
    player_pos(X, Y),
    calculate_new_pos(X, Y, Direction, NewX, NewY),
    (validate_move(NewX, NewY) ->
        update_player_position(X, Y, NewX, NewY),
        decrement_move,
        check_cell_content(NewX, NewY),
        showMap, nl, !
    ;
        write('Gagal bergerak! Kamu berada di ujung map.'), nl, !, fail
    ).

calculate_new_pos(X, Y, up, X, NewY) :- NewY is Y - 1.
calculate_new_pos(X, Y, down, X, NewY) :- NewY is Y + 1.
calculate_new_pos(X, Y, left, NewX, Y) :- NewX is X - 1.
calculate_new_pos(X, Y, right, NewX, Y) :- NewX is X + 1.

validate_move(X, Y) :-
    size_of_map(MaxX, MaxY),
    X >= 0, X < MaxX,
    Y >= 0, Y < MaxY.

update_player_position(OldX, OldY, NewX, NewY) :-
    retract(player_pos(OldX, OldY)),
    assertz(player_pos(NewX, NewY)),
    format('Berhasil bergerak ke posisi (~d,~d).~n', [NewX, NewY]).

decrement_move :-
    move_left(M),
    M1 is M - 1,
    retract(move_left(M)),
    assertz(move_left(M1)),
    format('Sisa langkah: ~d~n', [M1]).

check_cell_content(X, Y) :-
    (pokemon_liar(X, Y, Species, Level) ->
        interact(X, Y, Species, Level), !
    ; grass(X, Y) ->
        write('Tidak ada apa-apa di semak ini.'), nl, !
    ; true).

interact(X, Y, Species, Level) :-
    format('Kamu bertemu ~w liar (Lv.~d)!~n', [Species, Level]),
    generate_pokemon_id(EnemyID),
    pokemon(Species, Rarity, _, BaseHP, BaseATK, BaseDEF, _, _),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is BaseDEF + Level,
    assertz(pokemonInstance(EnemyID, Species, Level, HP, ATK, DEF)),
    assertz(temp_enemy_id(EnemyID)),
    assertz(encountered(Species, Rarity, BaseHP, BaseATK, Level, 0)),
    party([First|_]),
    assertz(inBattle(First, EnemyID)),
    write('Pilih aksi: battle. / catch. / run.'), nl.

switch_active_pokemon(NewPlayerID) :-
    inBattle(_, EnemyID),
    retractall(inBattle(_, _)),
    assertz(inBattle(NewPlayerID, EnemyID)).

get_alive_party(List) :-
    findall(ID, (party(Party), member(ID, Party), pokemonInstance(ID, _, _, HP, _, _), HP > 0), List).

print_pokemon_list([], _).
print_pokemon_list([ID|T], Index) :-
    pokemonInstance(ID, Species, Level, HP, ATK, DEF),
    format('~d. ~w (Lv ~d, HP: ~d, ATK: ~d, DEF: ~d)~n', [Index, Species, Level, HP, ATK, DEF]),
    NextIndex is Index + 1,
    print_pokemon_list(T, NextIndex).

handle_fainted_player(PlayerID, EnemyID) :-
    get_alive_party(AliveList),
    exclude_custom(=(PlayerID), AliveList, Remaining),
    (Remaining == [] ->
        write('Semua Pokemonmu sudah kalah. Kamu kalah total.'), nl,
        retract(inBattle(PlayerID, EnemyID))
    ;
        write('Pokemonmu telah dikalahkan!'), nl,
        write('Silakan pilih Pokemon pengganti:'), nl,
        print_pokemon_list(Remaining, 1),
        write('Masukkan indeks: '), read(Index),
        Index0 is Index - 1,
        nth0(Index0, Remaining, NewPlayerID),
        switch_active_pokemon(NewPlayerID),
        write('Pokemon telah diganti. Pertarungan dilanjutkan!'), nl,
        enemy_turn(EnemyID, NewPlayerID)
    ).

exclude_custom(_, [], []).
exclude_custom(Pred, [H|T], Result) :-
    ( call(Pred, H) ->
        exclude_custom(Pred, T, Result)
    ;
        Result = [H|Rest],
        exclude_custom(Pred, T, Rest)
    ).
