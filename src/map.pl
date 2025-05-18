% Fakta Dinamis
dynamic(cell/3).  % cell(X, Y, Isi).
dynamic(move_left/1).  % jumlah turn tersisa

% Membuat Map
generateMap :-
    retractall(cell(_,_,_)),
    generate_empty_map,
    place_grass,
    place_pokemon,
    place_player,
    assertz(move_left(20)).

% Memasukkan Pemain di Map
setPlayer :-
    repeat,
    random_between(1, 8, X),
    random_between(1, 8, Y),
    \+ cell(X, Y, _),         % hanya tempat kosong
    assertz(cell(X, Y, player)),
    assertz(player_pos(X, Y)),
    !.  % hentikan repeat setelah berhasil

% Menampilkan Map
showMap :-
    move_left(M), format('Move left: ~d~n', [M]),
    forall(between(1, 8, X),
        (forall(between(1, 8, Y),
            (cell(X,Y,C), write_symbol(C), write(' '))
        ),
        nl)
    ).

% Aturan untuk penulisan berdasarkan simbol
write_symbol(grass) :- write('#').
write_symbol(player) :- write('P').
write_symbol(common) :- write('C').
write_symbol(empty) :- write('.').
write_symbol(_) :- write('?').
