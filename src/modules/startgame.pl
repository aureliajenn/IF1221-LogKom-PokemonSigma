chooseStarterPokemon :-
    write('Pilih 2 starter Pokémon (hanya common, level 1):'), nl,
    findall(Name, pokemon(Name, common, _, _, _, _, _, _), Commons),
    display_list_with_index(Commons, 0),
    chooseStarterPokemon_input(Commons).

chooseStarterPokemon_input(Commons) :-
    write('Masukkan indeks starter pertama: '), nl,
    read(Idx1), nth(Idx1, Commons, Poke1),
    write('Masukkan indeks starter kedua: '), nl,
    read(Idx2), nth(Idx2, Commons, Poke2),
    initStarterPokemon(Poke1, ID1),
    initStarterPokemon(Poke2, ID2),
    assertz(party([ID1, ID2])),
    player_name(Name),
    write('Permainan dimulai! Selamat bermain, '), write(Name), write('!'), nl.

display_list_with_index([], _).
display_list_with_index([H|T], N) :-
    format('~d. ~w~n', [N, H]),
    N1 is N + 1,
    display_list_with_index(T, N1).

initStarterPokemon(Species, ID) :-
    pokemon(Species, Rarity, _, BaseHP, BaseATK, BaseDEF, _, _),
    Level = 1,
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
    write('DEBUG: Nama diterima'), nl,
    initPlayer(Name),
    write('DEBUG: Player di-init'), nl,
    generateMap,
    write('DEBUG: Map dibuat'), nl,
    setBag,
    write('DEBUG: Bag di-set'), nl.