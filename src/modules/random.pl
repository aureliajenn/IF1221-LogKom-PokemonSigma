% random_coord(X, Y)
% Menghasilkan koordinat acak valid dalam batas peta
random_coord(X, Y) :-
    size_of_map(MaxX, MaxY),
    random(0, MaxX, X),
    random(0, MaxY, Y).

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
    random(Min, Max, Value).
