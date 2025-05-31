:- dynamic(move_left/1).
move_left(20).

is_all_fainted([]).
is_all_fainted([ID|Rest]) :-
    pokemonInstance(ID, _, _, HP, _, _),
    HP =< 0,
    is_all_fainted(Rest).

startBossBattle :-
    assertz(pokemonInstance(boss001, mewtwo, 20, 250, 300, 250)),
    assertz(encountered(mewtwo, 250, 300, 250, 20, 0)),
    party([PlayerMon|_]),
    assertz(inBattle(PlayerMon, mewtwo)),
    write('Pertarungan melawan Mewtwo dimulai!'), nl.

endGame :-
    move_left(0),
    \+ inBattle(_, _),
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
    \+ pokemonInstance(_, mewtwo, _, HP, _, _),
    write('Selamat! Kamu telah mengalahkan Mewtwo dan memenangkan permainan!'), nl,
    halt, !.

endGame :- true.