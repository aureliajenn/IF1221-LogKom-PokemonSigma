%  Tambahan fakta
:- dynamic(isDefending/1).  % isDefending(ID)

% Aturan defend: memberikan efek defend ke pokemon player
defend :-
    inBattle(PlayerID, _),
    \+ isDefending(PlayerID),  % Cegah defend berulang-ulang dalam satu giliran
    assertz(isDefending(PlayerID)),
    write('Pokemon kamu dalam posisi bertahan! Defense naik 30% untuk 1 turn.'), nl,
    % Lanjut ke giliran musuh (misalnya call rule enemyTurn/0)
    enemyTurn,
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

% mengecek apakah target sedang defend
calculateDamage(AttackerID, TargetID, BaseDamage, FinalDamage) :-
    isDefending(TargetID),
    FinalDamage is round(BaseDamage * 0.7),  % Reduksi 30%
    retract(isDefending(TargetID)),  % Hanya 1 turn!
    !.

calculateDamage(_, _, BaseDamage, BaseDamage).  % Tidak defend
