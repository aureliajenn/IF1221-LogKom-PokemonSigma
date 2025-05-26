% Lookup modifier langsung dari fakta effectiveness
modifier(AtkType, DefType, Modifier) :-
    effectiveness(AtkType, DefType, Modifier), !.


% Serangan oleh player terhadap Pokémon liar
attack :-
    \+ current_battle(_, _),
    write('Tidak ada pertarungan yang sedang berlangsung!'), nl, !.

attack :-
    current_battle(PlayerMon, EnemyMon),
    current_skill(Skill),
    pokemon(PlayerMon, TypeA, _, _, AtkA, _, _, _),
    encountered(EnemyMon, TypeT, LvlT, HP_T, AtkT, DefT),
    skill(Skill, TypeSkill, PowerSkill),
    modifier(TypeSkill, TypeT, Modifier),
    DamageFloat is ((PowerSkill * AtkA) / (DefT * 5)) * Modifier,
    Damage is floor(DamageFloat),
    NewHP is max(0, HP_T - Damage),

    % Update HP musuh liar
    retract(encountered(EnemyMon, TypeT, LvlT, HP_T, AtkT, DefT)),
    assertz(encountered(EnemyMon, TypeT, LvlT, NewHP, AtkT, DefT)),

    format("~w menggunakan ~w!~n", [PlayerMon, Skill]),
    format("~w menerima ~d damage!~n", [EnemyMon, Damage]),
    format("HP ~w sekarang: ~d~n", [EnemyMon, NewHP]),

    (NewHP =< 0 ->
        write('Musuh berhasil dikalahkan!'), nl,
        end_battle
    ; true).
