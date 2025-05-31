:- dynamic(grass/2).
:- dynamic(pokemon_liar/4).
:- dynamic(player_pos/2).

size_of_map(8, 8).

generateMap :-
    retractall(grass(_,_)),
    retractall(pokemon_liar(_,_,_,_)),
    retractall(player_pos(_,_)),
    assertz(player_pos(0,0)),
    generate_grass(20).

generate_grass(0) :- !.
generate_grass(N) :-
    random_coord(X, Y),
    \+ grass(X, Y),
    assertz(grass(X, Y)),
    N1 is N - 1,
    generate_grass(N1).
generate_grass(N) :-
    generate_grass(N).

showMap :-
    size_of_map(W, H),
    player_pos(PX, PY),
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
    (X =:= PX, Y =:= PY -> write('P ') ;
     grass(X, Y) -> write('G ') ;
     write('. ')),
    X1 is X + 1,
    show_columns(X1, Width, Y, PX, PY).