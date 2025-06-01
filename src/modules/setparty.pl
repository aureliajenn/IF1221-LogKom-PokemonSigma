setParty(IdxParty, IdxBag) :-
    inBattle(_, _),
    write('Tidak bisa menukar pokemon saat dalam pertarungan!'), nl, !, fail.

setParty(IdxParty, IdxBag) :-
    integer(IdxParty), integer(IdxBag),
    IdxParty >= 0, IdxBag >= 0, IdxBag =< 39,
    party(PokemonList),
    length(PokemonList, PartySize),
    IdxParty < PartySize,
    bag(IdxBag, pokeball(filled(PokemonID))),
    nth(IdxParty, PokemonList, CurrentPokemon),
    swap_pokemon(IdxParty, IdxBag, CurrentPokemon, PokemonID),
    showParty.

setParty(_, _) :-
    write('Indeks tidak valid atau slot tas tidak berisi pokemon!'), nl, fail.

swap_pokemon(IdxParty, IdxBag, PartyPokemon, BagPokemon) :-
    retract(party(PokemonList)),
    replace_in_list(IdxParty, BagPokemon, PokemonList, NewPartyList),
    assertz(party(NewPartyList)),
    retract(bag(IdxBag, pokeball(filled(BagPokemon)))),
    assertz(bag(IdxBag, pokeball(filled(PartyPokemon)))).

replace_in_list(0, New, [_|T], [New|T]) :- !.
replace_in_list(I, New, [H|T], [H|R]) :-
    I1 is I - 1,
    replace_in_list(I1, New, T, R).

showParty :-
    party(PokemonList),
    write('=== Party ==='), nl,
    show_party_members(PokemonList, 1).

show_party_members([], _).
show_party_members([PokemonID|T], N) :-
    pokemonInstance(PokemonID, Species, Level, HP, ATK, DEF),
    format('~d. ~w (Lv.~d) HP:~d ATK:~d DEF:~d~n', [N, Species, Level, HP, ATK, DEF]),
    N1 is N + 1,
    show_party_members(T, N1).