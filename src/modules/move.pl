:- dynamic(player_pos/2).
:- dynamic(move_left/1).

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
        heal_all_pokemon,
        check_cell_content(NewX, NewY)
    ;
        write('Gagal bergerak! Kamu berada di ujung map.'), nl, fail
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

heal_all_pokemon :-
    party(PokemonList),
    heal_party_list(PokemonList),
    heal_bag_pokeballs.

heal_party_list([]).
heal_party_list([PokemonID|T]) :-
    heal_pokemon(PokemonID, 0.2),
    heal_party_list(T).

heal_bag_pokeballs :-
    heal_bag_pokeballs_loop(0, 19).

heal_bag_pokeballs_loop(I, Max) :- I > Max, !.
heal_bag_pokeballs_loop(I, Max) :-
    (bag(I, pokeball(filled(PokemonID))) ->
        heal_pokemon(PokemonID, 0.2)
    ; true),
    I1 is I + 1,
    heal_bag_pokeballs_loop(I1, Max).

heal_pokemon(PokemonID, Factor) :-
    pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF),
    pokemon(Species, _, _, BaseHP, _, _, _, _),
    MaxHP is BaseHP + (Level * 2),
    HealAmount is round(MaxHP * Factor),
    NewHP is min(CurrentHP + HealAmount, MaxHP),
    retract(pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF)),
    assertz(pokemonInstance(PokemonID, Species, Level, NewHP, ATK, DEF)),
    format('HP ~w bertambah menjadi ~d/~d~n', [PokemonID, NewHP, MaxHP]).

decrement_move :-
    move_left(M),
    M1 is M - 1,
    retract(move_left(M)),
    assertz(move_left(M1)),
    format('Sisa langkah: ~d~n', [M1]).

check_cell_content(X, Y) :-
    (pokemon_liar(X, Y, Species, Level) ->
        interact(X, Y, Species, Level)
    ; grass(X, Y) ->
        write('Tidak ada apa-apa di semak ini.'), nl
    ; true).

interact(X, Y, Species, Level) :-
    format('Kamu bertemu ~w liar (Lv.~d)!~n', [Species, Level]),
    assertz(encountered(Species, _, _, _, Level, 0)),
    write('Pilih aksi: battle. / catch. / run.'), nl.