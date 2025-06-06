% nth1(1, [H|_], H).
% nth1(N, [_|T], Elem) :-
%     N > 1,
%     N1 is N - 1,
%     nth1(N1, T, Elem).

deleteg(_, [], []).
deleteg(Elem, [Elem|T], T) :- !.
deleteg(Elem, [H|T], [H|Rest]) :-
    deleteg(Elem, T, Rest).

random_coord(X, Y) :-
    size_of_map(W, H),
    random_fix(0, W, X),
    random_fix(0, H, Y).

random_grass_coord(X, Y) :-
    findall((A,B), (grass(A,B), \+ pokemon_liar(A,B,_,_)), AvailableGrassTiles),
    (AvailableGrassTiles = [] ->
        fail
    ; random_member((X,Y), AvailableGrassTiles)
    ).


random_non_grass_coord(X, Y) :-
    repeat,
    random_coord(X, Y),
    \+ grass(X, Y),
    !.

% random_species_by_rarity(Rarity, Species) :-
%     findall(S, pokemon(S, Rarity, _, _, _, _, _, _), List),
%     write('List species untuk rarity '), write(Rarity), write(': '), write(List), nl,
%     random_member(Species, List).

random_in_range(Min, Max, Value) :-
    random_fix(Min, Max, Value).

random_member(X, List) :-
    length(List, Len),
    Len > 0,
    random_fix(1, Len, N),
    nth1(N, List, X).


shuffle([], []).
shuffle(List, [X|Rest]) :-
    length(List, Len),
    Len > 0,
    random_fix(1, Len, Index),  % <- ganti 0 dengan 1
    nth1(Index, List, X),       % <- pakai nth1, bukan nth
    deleteg(X, List, NewList),
    shuffle(NewList, Rest).


random_fix(Min, Max, Result) :-
    Range is Max - Min + 1,
    random(RawFloat),
    Temp is RawFloat * Range,
    Int is truncate(Temp),
    Result is Min + Int.

place_player_random :-
    findall((X, Y), (
        size_of_map(W, H),
        W1 is W-1,
        H1 is H-1,
        between(0, W1, X),
        between(0, H1, Y),
        \+ pokemon_liar(X, Y, _, _)
    ), List),  % termasuk rumput juga kalau tidak ada tempat kosong
    % write('Available tiles for player (including grass): '), write(List), nl,
    ( List = [] ->
        write('Gagal menempatkan player!'), nl, fail
    ; random_member((PX, PY), List),
      assertz(player_pos(PX, PY))
    ).

