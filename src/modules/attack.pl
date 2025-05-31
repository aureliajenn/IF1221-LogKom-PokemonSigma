attack :-
    \+ inBattle(_, _),
    write('Tidak ada pertarungan yang sedang berlangsung!'), nl, !.

attack :-
    inBattle(PlayerID, EnemyID),
    % Ambil skill default (misal slot 1)
    pokemonInstance(PlayerID, Species, Level, _, ATK, _),
    (species_skill(Species, Level, 1, SkillName) -> true ; SkillName = tackle),
    skill(SkillName, TypeSkill, PowerSkill, _),
    pokemonInstance(EnemyID, EnemySpecies, _, _, _, DEF),
    pokemon(Species, _, TypeA, _, _, _, _, _),
    pokemon(EnemySpecies, _, TypeT, _, _, _, _, _),
    (effectiveness(TypeSkill, TypeT, Modifier) -> true ; Modifier = 1),
    DamageFloat is ((PowerSkill * ATK) / (DEF * 5)) * Modifier,
    Damage is max(1, floor(DamageFloat)),
    apply_damage(EnemyID, Damage),
    format("~w menggunakan ~w!~n", [Species, SkillName]),
    format("~w menerima ~d damage!~n", [EnemySpecies, Damage]),
    pokemonInstance(EnemyID, _, _, HPBaru, _, _),
    format("HP ~w sekarang: ~d~n", [EnemySpecies, HPBaru]),
    (HPBaru =< 0 ->
        write('Musuh berhasil dikalahkan!'), nl,
        retract(inBattle(PlayerID, EnemyID)),
        % Tambahkan reward/exp dsb di sini
        true
    ; true).