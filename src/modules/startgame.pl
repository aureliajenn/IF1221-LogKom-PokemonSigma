initPlayer(Name) :-
    retractall(player_name(_)),
    assertz(player_name(Name)).

startGame :-
    write('Masukkan nama pemain: '), nl,
    read(Name),
    initPlayer(Name),
    generateMap,
    setPlayer,
    setBag,
    write('Permainan dimulai! Selamat bermain, '), write(Name), write('!'), nl.