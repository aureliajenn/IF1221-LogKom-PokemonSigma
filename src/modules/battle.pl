:- dynamic(temp_enemy_id/1).
:- dynamic(inBattle/2).

start_battle :-
    party([PlayerID|_]),
    temp_enemy_id(EnemyID),
    assertz(inBattle(PlayerID, EnemyID)),

    % Ambil nama species dari ID
    pokemonInstance(PlayerID, PlayerSpecies, _, _, _, _),
    pokemonInstance(EnemyID, EnemySpecies, _, _, _, _),

    write('Persiapkan dirimu! Pertarungan yang epik baru saja dimulai!'), nl,
    write('Pertarungan dimulai antara '),
    write(PlayerSpecies), write(' dan '), write(EnemySpecies), nl, nl,

    % Tambahan command
    write('Command yang dapat digunakan selama battle:'), nl,
    write('- attack.                        : Serangan fisik standar'), nl,
    write('- defend.                        : Bertahan, defense naik 30% selama 1 turn'), nl,
    write('- skill(N).                      : Menggunakan skill di slot N (1 atau 2 jika Lv>=10)'), nl.
    

end_battle :-
    retractall(inBattle(_, _)),
    retractall(encountered(_, _, _, _, _, _)),
    write('Pertarungan berakhir.'), nl.

battle :- start_battle.