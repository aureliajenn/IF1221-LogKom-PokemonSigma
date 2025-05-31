chooseStarterPokemon :-
    write('Pilih 2 starter Pokémon (hanya common):'), nl,
    findall(Name, pokemon(Name, common, _, _, _, _, _, _), Commons),
    display_list_with_index(Commons, 0),
    read(Idx1), nth0(Idx1, Commons, Poke1),
    read(Idx2), nth0(Idx2, Commons, Poke2),
    initStarterPokemon(Poke1, ID1),
    initStarterPokemon(Poke2, ID2),
    assertz(party([ID1, ID2])).

display_list_with_index([], _).
display_list_with_index([H|T], N) :-
    format('~d. ~w~n', [N, H]),
    N1 is N + 1,
    display_list_with_index(T, N1).

initStarterPokemon(Species, ID) :-
    pokemon(Species, Rarity, _, BaseHP, BaseATK, BaseDEF, _, _),
    Level = 5,
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is BaseDEF + Level,
    gensym(Species, ID),
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)).

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
    chooseStarterPokemon,
    write('Permainan dimulai! Selamat bermain, '), write(Name), write('!'), nl.