:- dynamic(grass/2).
:- dynamic(pokemon_liar/4).
:- dynamic(player_pos/2).

size_of_map(8,8).

% between(Low, High, Low) :-
%     Low =< High.
% between(Low, High, X) :-
%     Low < High,
%     Low1 is Low + 1,
%     between(Low1, High, X).

random_species_by_rarity(Rarity, Species) :-
    findall(S, pokemon(S, Rarity, _, _, _, _, _, _), SpeciesList),
    SpeciesList \= [],
    random_member(Species, SpeciesList).

generateMap :-
    retractall(grass(_,_)),
    retractall(pokemon_liar(_,_,_,_)),
    retractall(player_pos(_,_)),
    generate_grass(30),
    place_player_random,
    place_pokemon_liar.

generate_grass(N) :-
    MaxGrass is 64 - 1 - 19,
    N1 is min(N, MaxGrass),
    size_of_map(W, H),
    W1 is W - 1,
    H1 is H - 1,
    findall((X,Y), (between(0, W1, X), between(0, H1, Y)), AllCoords),
    shuffle(AllCoords, Shuffled),
    take_n(N1, Shuffled, GrassCoords),
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

place_pokemon_liar :-
    place_pokemon_random(legendary, 1, in_grass),
    place_pokemon_random(epic, 3, in_grass),
    place_pokemon_random(rare, 5, in_grass),
    place_pokemon_random(common, 5, in_grass),
    place_pokemon_random(common, 5, outside_grass).

place_pokemon_random(_, 0, _) :- !.
place_pokemon_random(Rarity, N, Location) :-
    get_available_coords(Location, Coords),
    length(Coords, Available),
    (Available < N ->
        format('Hanya tersedia ~d posisi untuk meletakkan ~w di ~w~n', [Available, Rarity, Location]),
        N1 is Available
    ;
        N1 = N),
    place_pokemon_random_n(Rarity, N1, Coords).

place_pokemon_random_n(_, 0, _) :- !.
place_pokemon_random_n(Rarity, N, [(X,Y)|Rest]) :-
    random_species_by_rarity(Rarity, Species),
    random_in_range(3, 15, Level),
    assertz(pokemon_liar(X, Y, Species, Level)),
    N1 is N - 1,
    place_pokemon_random_n(Rarity, N1, Rest).

get_available_coords(in_grass, Coords) :-
    findall((X,Y), (grass(X,Y), \+ pokemon_liar(X,Y,_,_)), Coords).
get_available_coords(outside_grass, Coords) :-
    size_of_map(W, H),
    W1 is W - 1, H1 is H - 1,
    findall((X,Y), (
        between(0, W1, X), between(0, H1, Y),
        \+ grass(X,Y), \+ pokemon_liar(X,Y,_,_)
    ), Coords).

% showMap :-
%     size_of_map(W, H),
%     ( player_pos(PX, PY) -> true ; PX = -1, PY = -1 ),
%     ( move_left(MoveLeft) -> true ; MoveLeft = 0 ),
%     format('Sisa langkah: ~d~n', [MoveLeft]),
%     show_rows(0, H, W, PX, PY).

% show_rows(Y, Height, _, _, _) :-
%     Y >= Height, !.
% show_rows(Y, Height, Width, PX, PY) :-
%     show_columns(0, Width, Y, PX, PY), nl,
%     Y1 is Y + 1,
%     show_rows(Y1, Height, Width, PX, PY).

% show_columns(X, Width, _, _, _) :-
%     X >= Width, !.
% show_columns(X, Width, Y, PX, PY) :-
%     (X =:= PX, Y =:= PY -> write('P ')
%     ; grass(X, Y) -> write('# ')
%     ; pokemon_liar(X, Y, Species, _) -> (pokemon(Species, common, _, _, _, _, _, _) -> write('C ') ; write('. '))
%     ; write('. ')),
%     X1 is X + 1,
%     show_columns(X1, Width, Y, PX, PY).

showMap :-
    size_of_map(W, H),
    ( player_pos(PX, PY) -> true ; PX = -1, PY = -1 ),
    ( move_left(MoveLeft) -> true ; MoveLeft = 0 ),
    
    % Header informasi
    format('Sisa langkah: ~d~n~n', [MoveLeft]),
    write('Legenda:'), nl,
    write('  P = Player'), nl,
    write('  # = Grass'), nl,
    write('  C = Common Pokemon'), nl,
    write('  . = Empty'), nl, nl,
    
    % Header kolom
    write('     '),
    print_column_headers(0, W), nl,
    
    % Garis pembatas atas
    write('   +'),
    print_horizontal_border(W), nl,
    
    % Isi peta
    show_rows(0, H, W, PX, PY).

% bagian ini ↓ DIHAPUS
% % Garis pembatas bawah
% write('   +'),
% print_horizontal_border(W), nl.


print_column_headers(X, Width) :-
    X >= Width, !.
print_column_headers(X, Width) :-
    (X < 10 -> format(' %d  ', [X])
    ; format('%d  ', [X])),
    X1 is X + 1,
    print_column_headers(X1, Width).

print_horizontal_border(0) :- !.
print_horizontal_border(N) :-
    write('---+'),
    N1 is N - 1,
    print_horizontal_border(N1).

show_rows(Y, Height, _, _, _) :-
    Y >= Height, !.
show_rows(Y, Height, Width, PX, PY) :-
    % Nomor baris
    (Y < 10 -> format(' %d |', [Y])
    ; format('%d |', [Y])),

    % Isi baris
    show_columns(0, Width, Y, PX, PY),

    % Penutup baris
    format('|~n', []),

    % Garis pembatas
    write('   +'),
    print_horizontal_border(Width), nl,

    Y1 is Y + 1,
    show_rows(Y1, Height, Width, PX, PY).

show_columns(X, Width, _, _, _) :-
    X >= Width, !.
show_columns(X, Width, Y, PX, PY) :-
    ( X > 0 -> write('|') ; true ),  % <<< INI kuncinya: hanya print '|' jika bukan kolom pertama
    
    ( X =:= PX, Y =:= PY -> write(' P ')
    ; grass(X, Y) -> write(' # ')
    ; pokemon_liar(X, Y, Species, _) -> 
        (pokemon(Species, common, _, _, _, _, _, _) -> write(' C ')
        ; write(' C ')  % karena TUBES hanya butuh C
        )
    ; write(' . ')
    ),

    X1 is X + 1,
    show_columns(X1, Width, Y, PX, PY).
