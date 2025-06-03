:- dynamic(temp_enemy_id/1).
:- dynamic(inBattle/2).

/* Memulai pertarungan antara Pokémon pertama di party dan Pokémon liar yang telah disiapkan */
start_battle :-
    % Pastikan ada lawan
    ( \+ temp_enemy_id(_) ->
        write('Tidak ada Pokémon liar yang ditemukan. Tidak bisa memulai pertarungan.'), nl, !
    ;
    % Pastikan player memiliki party
    ( \+ party(_) ->
        write('Kamu belum memiliki Pokémon di party untuk bertarung!'), nl, !
    ;
    % Ambil Pokémon pertama dari party
    party([PlayerID|_]),
    temp_enemy_id(EnemyID),
    assertz(inBattle(PlayerID, EnemyID)),

    % Ambil informasi spesies
    pokemonInstance(PlayerID, PlayerSpecies, _, _, _, _),
    pokemonInstance(EnemyID, EnemySpecies, _, _, _, _),

    % Tampilkan informasi pertarungan
    write('Persiapkan dirimu! Pertarungan yang epik baru saja dimulai!'), nl,
    format('Pertarungan dimulai antara ~w dan ~w!~n~n', [PlayerSpecies, EnemySpecies]),

    % Petunjuk perintah yang bisa digunakan
    write('Command yang dapat digunakan selama pertarungan:'), nl,
    write('- attack.      : Serangan fisik standar'), nl,
    write('- defend.      : Bertahan, defense naik 30% selama 1 turn'), nl,
    write('- skill(N).    : Gunakan skill ke-N (1 atau 2 jika Lv >= 10)'), nl,
    write('- catch.       : Menangkap Pokémon liar (jika tersedia Pokéball kosong)'), nl,
    write('- run.         : Kabur dari pertarungan (tidak selalu berhasil)'), nl
    )).

% Mengakhiri pertarungan dan membersihkan status
end_battle :-
    retractall(inBattle(_, _)),
    retractall(encountered(_, _, _, _, _, _)),
    retractall(temp_enemy_id(_)),
    write('Pertarungan berakhir.'), nl.

/* Alias untuk memulai pertarungan */
battle :- start_battle.
