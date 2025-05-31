:- dynamic(inBattle/2).

run :-
    inBattle(_, _), !,
    retract(inBattle(_, _)),
    write('Kamu memilih kabur!'), nl,
    write('Skill issue.'), nl.

run :-
    \+ inBattle(_, _),
    write('Kamu tidak sedang dalam pertempuran!'), nl.