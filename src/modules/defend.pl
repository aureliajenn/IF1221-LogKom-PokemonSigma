:- dynamic(isDefending/1).

/* RULE: Mengaktifkan mode bertahan dalam pertarungan */
defend :-
    \+ inBattle(_, _), !,
    write('Kamu tidak sedang bertarung!'), nl.

defend :-
    inBattle(PlayerID, _),
    ( isDefending(PlayerID) ->
        write('Pokemon kamu sudah dalam posisi bertahan!'), nl
    ;
        assertz(isDefending(PlayerID)),
        write('Pokemon kamu dalam posisi bertahan! Defense naik 30% untuk 1 turn.'), nl
    ).

/* RULE: Hitung damage, memperhitungkan efek defend */
calculateDamage(_, TargetID, BaseDamage, FinalDamage) :-
    isDefending(TargetID), !,
    FinalDamage is round(BaseDamage * 0.7),
    retract(isDefending(TargetID)).

calculateDamage(_, _, BaseDamage, BaseDamage).
