run :-
    inBattle(_, _), !,
    retract(inBattle(_, _)),
    write('Kamu memilih kabur dari pertarungan!'), nl,
    write('Skill issue.'), nl.

run :-
    encountered(_, _, _, _, _, _), !,
    retract(encountered(_, _, _, _, _, _)),
    retract(temp_enemy_id(_)),
    write('Kamu kabur dari pertemuan dengan Pokémon liar.'), nl.

run :-
    write('Kamu tidak sedang dalam pertempuran atau pertemuan apapun!'), nl.
