:- dynamic(inBattle/2).
:- dynamic(pending_encounter/2).
:- dynamic(active_pokemon/1).

/* Memulai pertarungan antara Pokemon pertama di party dan Pokemon liar yang telah disiapkan */
battle :-
    inBattle(_, _),
    write('Pertarungan sedang berlangsung!'), nl, !, fail.

battle :-
    \+ pending_encounter(_, _),
    write('Tidak ada Pokemon liar yang sedang ditemui.'), nl, !, fail.

battle :-
    \+ party(_),
    write('Kamu belum memiliki Pokemon di party untuk bertarung!'), nl, !, fail.

battle :-
    pending_encounter(Species, Level),
    retract(pending_encounter(Species, Level)),
    generate_pokemon_id(EnemyID),
    pokemon(Species, Rarity, _, BaseHP, BaseATK, BaseDEF, _, _),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is BaseDEF + Level,
    assertz(pokemonInstance(EnemyID, Species, Level, HP, ATK, DEF)),

    % Pilih Pokemon pemain (aktif atau head party)
    (active_pokemon(PlayerID) -> true ; (party([PlayerID|_]), assertz(active_pokemon(PlayerID)))),

    assertz(inBattle(PlayerID, EnemyID)),

    % Tampilkan info pertarungan
    pokemonInstance(PlayerID, PlayerSpecies, _, _, _, _),
    write('Persiapkan dirimu! Pertarungan dimulai!'), nl,
    format('Pertarungan dimulai antara ~w dan ~w!~n~n', [PlayerSpecies, Species]),

    write('Command yang dapat digunakan selama pertarungan:'), nl,
    write('- attack.      : Serangan fisik standar'), nl,
    write('- defend.      : Bertahan, defense naik 30% selama 1 turn'), nl,
    write('- skill(N).    : Gunakan skill ke-N (1 atau 2 jika Lv >= 10)'), nl.

/* Mengakhiri pertarungan dan membersihkan status */
end_battle :-
    retractall(inBattle(_, _)),
    retractall(active_pokemon(_)),
    retractall(pending_encounter(_, _)),
    write('Pertarungan berakhir.'), nl.
