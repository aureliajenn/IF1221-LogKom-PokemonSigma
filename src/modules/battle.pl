:- dynamic(current_battle/2).
:- dynamic(current_skill/1).

% Memulai pertarungan
start_battle :-
    player_active(PlayerMon),
    encountered(EnemyName, _, _, _, _, _),
    assertz(current_battle(PlayerMon, EnemyName)),
    % Default: pakai skill pertama
    pokemon(PlayerMon, _, _, _, _, _, Skill1, _),
    assertz(current_skill(Skill1)),
    format("Pertarungan dimulai antara ~w dan ~w!~n", [PlayerMon, EnemyName]).

% Mengakhiri pertarungan dan reset state
end_battle :-
    retractall(current_battle(_, _)),
    retractall(current_skill(_)),
    retractall(encountered(_, _, _, _, _, _)),
    write('Pertarungan berakhir.'), nl.