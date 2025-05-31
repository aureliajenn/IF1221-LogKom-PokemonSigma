attack :-
    \+ inBattle(_, _),
    write('Tidak ada pertarungan yang sedang berlangsung!'), nl, !.

attack :-
    inBattle(PlayerID, EnemyID),
    pokemonInstance(PlayerID, Species, _, _, ATK, _),
    pokemonInstance(EnemyID, EnemySpecies, _, _, _, DEF),
    PowerSkill = 1,
    pokemon(Species, _, TypeA, _, _, _, _, _),
    pokemon(EnemySpecies, _, TypeT, _, _, _, _, _),
    (effectiveness(TypeA, TypeT, Modifier) -> true ; Modifier = 1),
    DamageFloat is ((PowerSkill * ATK) / (DEF * 0.2)) * Modifier,
    Damage is max(1, floor(DamageFloat)),
    apply_damage(EnemyID, Damage),
    format("~w menyerang!~n", [Species]),
    format("~w menerima ~d damage!~n", [EnemySpecies, Damage]),
    pokemonInstance(EnemyID, _, _, HPBaru, _, _),
    format("HP ~w sekarang: ~d~n", [EnemySpecies, HPBaru]),
    (HPBaru =< 0 ->
        write('Musuh berhasil dikalahkan!'), nl,
        give_exp_and_drop(PlayerID, EnemyID),
        retract(inBattle(PlayerID, EnemyID)),
        true
    ; true).

give_exp_and_drop(PlayerID, EnemyID) :-
    pokemonInstance(EnemyID, EnemySpecies, EnemyLevel, _, _, _),
    exp_given_rarity(EnemySpecies, BaseExp),
    Exp is BaseExp + (EnemyLevel * 2),
    format('Pokemonmu mendapat ~d EXP!~n', [Exp]),
    random(1, 101, R),
    (R =< 75 ->
        random(1, 101, RItem),
        (RItem =< 5 -> Item = hyper_potion
        ; RItem =< 20 -> Item = super_potion
        ; Item = potion),
        add_item_to_bag(Item),
        format('Kamu mendapatkan item: ~w!~n', [Item])
    ; write('Tidak mendapatkan item kali ini.~n')).