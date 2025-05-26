% Fakta dinamis agar bisa berubah saat runtime
:- dynamic(player/4).
:- dynamic(inBattle/2).
:- dynamic(pokemon_liar/4).

% run/0: Pemain memilih kabur saat encounter
run :-
    inBattle(_, _), !,
    % Kabur selalu berhasil
    retract(inBattle(_, _)),
    write('Kamu memilih kabur!'), nl,
    write('Skill issue.'), nl.

run :-
    \+ inBattle(_, _),
    write('Kamu tidak sedang dalam pertempuran!'), nl.
