:- dynamic(isDefending/1).

defend :-
    inBattle(PlayerID, _),
    \+ isDefending(PlayerID),
    assertz(isDefending(PlayerID)),
    write('Pokemon kamu dalam posisi bertahan! Defense naik 30% untuk 1 turn.'), nl,
    !.

defend :-
    inBattle(PlayerID, _),
    isDefending(PlayerID),
    write('Pokemon kamu sudah dalam posisi bertahan!'), nl,
    !.

defend :-
    \+ inBattle(_, _),
    write('Kamu tidak sedang dalam pertarungan!'), nl,
    !.

calculateDamage(AttackerID, TargetID, BaseDamage, FinalDamage) :-
    isDefending(TargetID),
    FinalDamage is round(BaseDamage * 0.7),
    retract(isDefending(TargetID)), !.

calculateDamage(_, _, BaseDamage, BaseDamage).