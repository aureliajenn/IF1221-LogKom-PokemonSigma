
:- dynamic(move_left/1).
:- dynamic(active_pokemon/1).
:- dynamic(inBattle/2).
:- dynamic(status/3).

% Mengecek apakah semua Pokémon pemain telah pingsan
is_all_fainted([]).
is_all_fainted([ID|Rest]) :-
    pokemonInstance(ID, _, _, HP, _, _),
    HP =< 0,
    is_all_fainted(Rest).

% Memilih Pokémon pertama yang masih hidup dari party
select_valid_active([ID|_], ID) :-
    pokemonInstance(ID, _, _, HP, _, _),
    HP > 0, !.
select_valid_active([_|Rest], ValidID) :-
    select_valid_active(Rest, ValidID).

% Memulai pertarungan melawan Mewtwo
startBossBattle :-
    % Pastikan Mewtwo terdaftar sebagai boss
    assertz(pokemonInstance(mewtwo, mewtwo, 20, 250, 300, 250)),
    assertz(encountered(mewtwo, 250, 300, 250, 20, 0)),

    party(Party),
    select_valid_active(Party, ValidPlayerMon),

    retractall(active_pokemon(_)),
    assertz(active_pokemon(ValidPlayerMon)),
    retractall(inBattle(_, _)),
    assertz(inBattle(ValidPlayerMon, mewtwo)),

    pokemonInstance(ValidPlayerMon, PlayerSpecies, _, _, _, _),
    write('Pertarungan melawan Mewtwo dimulai!'), nl,
    write('Persiapkan dirimu! Pertarungan dimulai antara '), write(PlayerSpecies), write(' dan Mewtwo!'), nl, nl,
    write('Command yang dapat digunakan selama pertarungan:'), nl,
    write('- attack.      : Serangan fisik standar'), nl,
    write('- defend.      : Bertahan, defense naik 30% selama 1 turn'), nl,
    write('- skill(N).    : Gunakan skill ke-N (1 atau 2 jika Lv >= 10)'), nl.

% Aturan akhir permainan
endGame :-
    move_left(ML), ML > 0,
    write('Belum waktunya melawan boss! Sisa langkah: '), write(ML), nl, !.

endGame :-
    move_left(ML), ML =< 0,
    \+ inBattle(_, _),
    write('Sudah 20 langkah. Saatnya melawan boss legendaris!'), nl,
    startBossBattle, !.

endGame :-
    inBattle(_, mewtwo),
    \+ pokemonInstance(_, mewtwo, _, _, _, _),
    write('Selamat! Kamu telah mengalahkan Mewtwo dan memenangkan permainan!'), nl,
    retractall(inBattle(_, _)),
    retractall(active_pokemon(_)),
    halt, !.

endGame :-
    party(Party),
    is_all_fainted(Party),
    inBattle(_, mewtwo),
    write('Semua Pokemon milikmu sudah tidak bisa bertarung...'), nl,
    write('Kamu kalah. Permainan selesai.'), nl,
    halt, !.

endGame :- true.
