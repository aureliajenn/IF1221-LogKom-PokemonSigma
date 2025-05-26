
move(Direction) :-
    inBattle(_, _),
    write('Anda sedang dalam pertarungan! Tidak bisa bergerak.'), nl, !, fail.

move(Direction) :-
    move_left(Moves),
    Moves =< 0,
    write('Permainan sudah berakhir!'), nl, !, fail.

move(Direction) :-
    player_pos(X, Y),
    calculate_new_pos(X, Y, Direction, NewX, NewY),
    (validate_move(NewX, NewY) ->
        update_player_position(X, Y, NewX, NewY),
        heal_party_pokemon,
        decrement_move,
        check_cell_content(NewX, NewY)
    ;
        write('Gagal bergerak! Kamu berada di ujung map.'), nl, fail
    ).

calculate_new_pos(X, Y, up, X, NewY) :- NewY is Y - 1.
calculate_new_pos(X, Y, down, X, NewY) :- NewY is Y + 1.
calculate_new_pos(X, Y, left, NewX, Y) :- NewX is X - 1.
calculate_new_pos(X, Y, right, NewX, Y) :- NewX is X + 1.

validate_move(X, Y) :-
    size_of_map(MaxX, MaxY),
    X >= 1, X =< MaxX,
    Y >= 1, Y =< MaxY.

update_player_position(OldX, OldY, NewX, NewY) :-
    retract(player_pos(OldX, OldY)),
    retract(cell(OldX, OldY, player)),
    assertz(player_pos(NewX, NewY)),
    assertz(cell(NewX, NewY, player)),
    assertz(cell(OldX, OldY, empty)).

heal_party_pokemon :-
    write('HP Pokemon dipulihkan sebanyak 20% dari total max HP masing-masing.'), nl,
    forall(party(PokemonID), heal_pokemon(PokemonID, 0.2)).

heal_pokemon(PokemonID, Factor) :-
    pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF),
    pokemon(Species, _, _, BaseHP, _, _, _, _),
    MaxHP is BaseHP + (Level * 2),
    HealAmount is floor(MaxHP * Factor),
    NewHP is min(MaxHP, CurrentHP + HealAmount),
    retract(pokemonInstance(PokemonID, Species, Level, _, ATK, DEF)),
    assertz(pokemonInstance(PokemonID, Species, Level, NewHP, ATK, DEF)).

decrement_move :-
    retract(move_left(Moves)),
    NewMoves is Moves - 1,
    assertz(move_left(NewMoves)).

check_cell_content(X, Y) :-
    cell(X, Y, grass),
    random(0, 100, Chance),
    (Chance < 30 ->
        random_species_by_rarity(common, Species),
        random_between(1, 15, Level),
        write('Kamu menemukan Pokemon liar!'), nl,
        assertz(pokemon_liar(X, Y, Species, Level)),
        interact
    ;
        write('Kamu memasuki semak-semak!'), nl,
        write('Sepertinya tidak ada tanda-tanda kehidupan disini...'), nl
    ).

check_cell_content(X, Y) :-
    cell(X, Y, common),
    write('Kamu menemukan Pokemon common di luar rumput!'), nl,
    interact.

check_cell_content(X, Y) :-
    cell(X, Y, 'H'),
    write('Kamu menemukan PokeCenter! Gunakan command heal/0 untuk memulihkan HP.'), nl.

check_cell_content(_, _).