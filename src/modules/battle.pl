:- dynamic(inBattle/2).

start_battle :-
    party([PlayerMon|_]),
    encountered(EnemyName, _, _, _, _, _),
    assertz(inBattle(PlayerMon, EnemyName)),
    format("Pertarungan dimulai antara ~w dan ~w!~n", [PlayerMon, EnemyName]).

end_battle :-
    retractall(inBattle(_, _)),
    retractall(encountered(_, _, _, _, _, _)),
    write('Pertarungan berakhir.'), nl.