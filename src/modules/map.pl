% generateMap/0: Setup awal map (rumput & pokemon)
generateMap :-
    retractall(grass(_,_)),
    retractall(pokemon_liar(_,_,_,_)),
    retractall(pokemon_outside(_,_)),
    generate_grass(32),
    place_all_pokemon.

% generate_grass(N): menempatkan N petak rumput secara acak
generate_grass(0) :- !.
generate_grass(N) :-
    random_coord(X, Y),
    (\+ grass(X,Y) -> assertz(grass(X,Y)), N1 is N - 1 ; N1 = N),
    generate_grass(N1).

% place_all_pokemon/0: tempatkan semua pokemon sesuai jumlah dan rarity
place_all_pokemon :-
    place_pokemon_by_rarity(legendary, 1),
    place_pokemon_by_rarity(epic, 3),
    place_pokemon_by_rarity(rare, 5),
    place_common_pokemon(10).

% place_pokemon_by_rarity(Rarity, Count): tempatkan Pokemon (selain common) di rumput
place_pokemon_by_rarity(_, 0) :- !.
place_pokemon_by_rarity(Rarity, N) :-
    random_species_by_rarity(Rarity, Species),
    random_grass_coord(X, Y),
    \+ pokemon_liar(_, _, X, Y),
    assertz(pokemon_liar(Rarity, Species, X, Y)),
    N1 is N - 1,
    place_pokemon_by_rarity(Rarity, N1).

% place_common_pokemon(N): tempatkan common pokemon, bisa di dalam atau luar rumput
place_common_pokemon(0) :- !.
place_common_pokemon(N) :-
    random_species_by_rarity(common, Species),
    random_in_range(0, 2, R),
    ( R =:= 0 ->
        random_grass_coord(X, Y),
        \+ pokemon_liar(_, _, X, Y),
        assertz(pokemon_liar(common, Species, X, Y))
    ;
        random_non_grass_coord(X, Y),
        \+ pokemon_outside(X, Y),
        assertz(pokemon_liar(common, Species, X, Y)),
        assertz(pokemon_outside(X, Y))
    ),
    N1 is N - 1,
    place_common_pokemon(N1).

% Show entire map with symbols
showMap :-
    player(_, PX, PY, Moves),
    size_of_map(Width, Height),
    nl, write('Move left: '), write(Moves), nl, nl,
    show_rows(0, Height, Width, PX, PY).

% Helper to loop over rows
show_rows(Y, Height, _, _, _) :-
    Y >= Height, !.
show_rows(Y, Height, Width, PX, PY) :-
    show_columns(0, Width, Y, PX, PY),
    nl,
    Y1 is Y + 1,
    show_rows(Y1, Height, Width, PX, PY).

% Helper to print a single tile
show_columns(X, Width, _, _, _) :-
    X >= Width, !.
show_columns(X, Width, Y, PX, PY) :-
    (
        PX =:= X, PY =:= Y -> write('P')
    ;   pokemon_outside(X,Y) -> write('C')
    ;   grass(X,Y) -> write('#')
    ;   write('.')
    ),
    write(' '),
    X1 is X + 1,
    show_columns(X1, Width, Y, PX, PY).