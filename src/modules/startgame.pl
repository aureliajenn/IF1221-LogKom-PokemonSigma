:- dynamic(move_left/1).

chooseStarterPokemon :- 
    write('Pilih 2 starter Pokémon (hanya common, level 1):'), nl,
    findall(Name, pokemon(Name, common, _, _, _, _, _, _), Commons),
    display_list_with_index(Commons, 1),  % Mulai dari 1
    chooseStarterPokemon_input(Commons).

chooseStarterPokemon_input(Commons) :-
    write('Masukkan indeks starter pertama: '), nl,
    read(Idx1),
    write('Masukkan indeks starter kedua: '), nl,
    read(Idx2),
    Index1 is Idx1 - 1,
    Index2 is Idx2 - 1,
    nth0(Index1, Commons, Poke1),
    nth0(Index2, Commons, Poke2),
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
    generate_pokemon_id(ID),
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)).

initPlayer(Name) :-
    retractall(player_name(_)),
    assertz(player_name(Name)).

startGame :-
    write('Masukkan nama pemain: '),
    read(Name),
    assertz(player_name(Name)),
    assertz(move_left(20)),  % inisialisasi langkah
    setBag,                  % ← ganti dari initBag ke setBag
    chooseStarterPokemon,
    ( generateMap -> 
        write('Game berhasil dimulai untuk pemain '), write(Name), nl
    ; write('Gagal menginisialisasi peta!'), nl
    ).

