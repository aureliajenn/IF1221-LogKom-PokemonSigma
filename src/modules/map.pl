:- dynamic(grass/2).
:- dynamic(pokemon_liar/4).
:- dynamic(player_pos/2).

size_of_map(8,8).

between(Low, High, Low) :-
    Low =< High.
between(Low, High, X) :-
    Low < High,
    Low1 is Low + 1,
    between(Low1, High, X).

generateMap :-
    retractall(grass(_,_)),
    retractall(pokemon_liar(_,_,_,_)),
    retractall(player_pos(_,_)),
    generate_grass(8),
    place_player_random,
    place_pokemon_liar.

generate_grass(N) :-
    MaxGrass is 64 - 1 - 19,
    ( N > MaxGrass ->
        fail
    ;
        true
    ),
    size_of_map(W, H),
    W1 is W - 1,
    H1 is H - 1,
    findall((X,Y), (between(0, W1, X), between(0, H1, Y)), AllCoords),
    shuffle(AllCoords, Shuffled),
    take_n(N, Shuffled, GrassCoords),
    assert_grass_list(GrassCoords).

assert_grass_list([]).
assert_grass_list([(GX,GY)|T]) :-
    assertz(grass(GX, GY)),
    assert_grass_list(T).

take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(N, [H|T], [H|Rest]) :-
    N1 is N-1,
    take_n(N1, T, Rest).

place_player_random :-
    findall((X, Y), (
        size_of_map(W, H),
        W1 is W-1,
        H1 is H-1,
        between(0, W1, X),
        between(0, H1, Y),
        \+ grass(X, Y),
        \+ pokemon_liar(X, Y, _, _)
    ), List),
    ( List = [] ->
        fail
    ; random_member((PX, PY), List),
      assertz(player_pos(PX, PY))
    ).

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
    write('Sisa langkah: '), write(MoveLeft), nl,
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