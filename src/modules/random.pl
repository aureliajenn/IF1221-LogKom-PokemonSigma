nth(0, [H|_], H).
nth(N, [_|T], Elem) :-
    N > 0,
    N1 is N - 1,
    nth(N1, T, Elem).

deleteg(_, [], []).
deleteg(Elem, [Elem|T], T) :- !.
deleteg(Elem, [H|T], [H|Rest]) :-
    deleteg(Elem, T, Rest).

% random_coord(X, Y)
% Menghasilkan koordinat acak valid dalam batas peta
random_coord(X, Y) :-
    size_of_map(W, H),
    random_fix(0, W, X),
    random_fix(0, H, Y).

% random_grass_coord(X, Y)
% Menghasilkan koordinat yang merupakan petak rumput
random_grass_coord(X, Y) :-
    findall((A,B), grass(A,B), GrassTiles),
    random_member((X,Y), GrassTiles).

% random_non_grass_coord(X, Y)
% Menghasilkan koordinat acak yang bukan petak rumput
random_non_grass_coord(X, Y) :-
    repeat,
    random_coord(X, Y),
    \+ grass(X, Y),
    !.

% random_species_by_rarity(Rarity, Species)
% Mengambil 1 spesies acak dari daftar pokemon dengan rarity tertentu
random_species_by_rarity(Rarity, Species) :-
    findall(S, pokemon(S, Rarity, _, _, _, _, _, _), List),
    random_member(Species, List).

% random_in_range(Min, Max, Value)
% Menghasilkan nilai acak Value antara Min (inklusif) dan Max (eksklusif)
random_in_range(Min, Max, Value) :-
    random_fix(Min, Max, Value).

random_member(X, List) :-
    length(List, Len),
    Len > 0,
    random_fix(1, Len, N),
    nth(N, List, X).

shuffle([], []).
shuffle(List, [X|Rest]) :-
    length(List, Len),
    Len > 0,
    random_fix(0, Len, Index),
    nth(Index, List, X),
    deleteg(X, List, NewList),
    shuffle(NewList, Rest).

% random_fix(Low, High, Result)
% GNU Prolog-compatible random integer in [Low, High)
random_fix(Min, Max, Result) :-
    Range is Max - Min,
    random(RawFloat),
    Temp is RawFloat * Range,
    Int is truncate(Temp),
    Result is Min + Int.
