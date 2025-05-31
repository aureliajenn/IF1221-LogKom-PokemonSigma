:- dynamic(grass/2).
:- dynamic(pokemon_liar/4).
:- dynamic(player_pos/2).

size_of_map(8,8).

generateMap :-
    retractall(grass(_,_)),
    retractall(pokemon_liar(_,_,_,_)),
    retractall(player_pos(_,_)),
    generate_grass(32),
    place_player_random,
    place_pokemon_liar.

generate_grass(0) :- !.
generate_grass(N) :-
    random_coord(X, Y),
    \+ grass(X, Y),
    assertz(grass(X, Y)),
    N1 is N - 1,
    generate_grass(N1).
generate_grass(N) :-
    generate_grass(N).

place_player_random :-
    repeat,
    random_coord(X, Y),
    \+ grass(X, Y),
    \+ pokemon_liar(X, Y, _, _),
    assertz(player_pos(X, Y)), !.

place_pokemon_liar :-
    place_pokemon_random(legendary, 1, in_grass),
    place_pokemon_random(epic, 3, in_grass),
    place_pokemon_random(rare, 5, in_grass),
    place_pokemon_random(common, 5, in_grass),
    place_pokemon_random(common, 5, outside_grass).

place_pokemon_random(_, 0, _) :- !.
place_pokemon_random(Rarity, N, in_grass) :-
    random_species_by_rarity(Rarity, Species),
    random_grass_coord(X, Y),
    \+ pokemon_liar(X, Y, _, _),
    random_in_range(3, 15, Level),
    assertz(pokemon_liar(X, Y, Species, Level)),
    N1 is N-1,
    place_pokemon_random(Rarity, N1, in_grass).
place_pokemon_random(Rarity, N, outside_grass) :-
    random_species_by_rarity(Rarity, Species),
    random_non_grass_coord(X, Y),
    \+ pokemon_liar(X, Y, _, _),
    random_in_range(3, 15, Level),
    assertz(pokemon_liar(X, Y, Species, Level)),
    N1 is N-1,
    place_pokemon_random(Rarity, N1, outside_grass).

showMap :-
    size_of_map(W, H),
    player_pos(PX, PY),
    move_left(MoveLeft),
    format('Sisa langkah: ~d~n', [MoveLeft]),
    show_rows(0, H, W, PX, PY).

show_rows(Y, Height, _, _, _) :-
    Y >= Height, !.
show_rows(Y, Height, Width, PX, PY) :-
    show_columns(0, Width, Y, PX, PY),
    nl,
    Y1 is Y + 1,
    show_rows(Y1, Height, Width, PX, PY).

show_columns(X, Width, _, _, _) :-
    X >= Width, !.
show_columns(X, Width, Y, PX, PY) :-
    (X =:= PX, Y =:= PY -> write('P ')
    ; grass(X, Y) -> write('# ')
    ; pokemon_liar(X, Y, Species, _) -> (pokemon(Species, common, _, _, _, _, _, _) -> write('C ') ; write('. '))
    ; write('. ')
    ),
    X1 is X + 1,
    show_columns(X1, Width, Y, PX, PY).