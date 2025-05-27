% Tambahan Fakta
:- dynamic(move_left/1).
move_left(20).

% Mengecek apakah seluruh pokemon dalam party telah mati
is_all_fainted([]).
is_all_fainted([ID|Rest]) :-
    pokemonInstance(ID, _, _, HP, _, _),
    HP =< 0,
    is_all_fainted(Rest).

% Rule pertarungan boss
startBossBattle :-
    assertz(pokemonInstance(boss001, mewtwo, legendary, 250, 300, 250)),
    assertz(inBattle(_, mewtwo)),
    write('Pertarungan melawan Mewtwo dimulai!'), nl.

% Rule utama endGame
endGame :-
    move_left(0),
    \+ inBattle(_, _),  % tidak sedang dalam pertarungan
    write('Sudah 20 langkah. Saatnya melawan boss legendaris!'), nl,
    startBossBattle, !.

endGame :-
    party(Party),
    is_all_fainted(Party),
    write('Semua Pokémon milikmu sudah tidak bisa bertarung...'), nl,
    write('Kamu kalah. Permainan selesai.'), nl, 
    halt, !.

endGame :-
    inBattle(_, mewtwo),
    % Asumsikan Mewtwo adalah pokemonInstance juga
    \+ pokemonInstance(_, mewtwo, _, HP, _, _),
    write('Selamat! Kamu telah mengalahkan Mewtwo dan memenangkan permainan!'), nl,
    halt, !.

endGame :- 
    % Tidak memenuhi kondisi apapun
    true.
